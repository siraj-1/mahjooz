import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/mock/mock_venues.dart';
import '../../../shared/models/venue.dart';
import '../data/demo_booking_api.dart';
import '../data/demo_booking_registry.dart';

const _green = Color(0xFF187E58);

class SelectResourceScreen extends StatefulWidget {
  const SelectResourceScreen({
    super.key,
    required this.venueId,
    required this.category,
  });

  final String venueId;
  final String category;

  @override
  State<SelectResourceScreen> createState() => _SelectResourceScreenState();
}

class _SelectResourceScreenState extends State<SelectResourceScreen> {
  final _api = DemoBookingApi();
  late DateTime _date;
  late int _hour;
  Map<String, bool> _availability = {};
  String? _selectedId;
  String? _error;
  bool _loading = false;
  bool _reserving = false;
  int _requestVersion = 0;

  Venue? get _venue =>
      mockVenues.where((venue) => venue.id == widget.venueId).firstOrNull;

  List<Resource> get _resources =>
      _venue?.branches
          .expand((branch) => branch.resources)
          .where((resource) =>
              resource.isActive && resource.category == widget.category)
          .toList() ??
      [];

  String get _dateValue =>
      '${_date.year.toString().padLeft(4, '0')}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
  String get _timeValue => '${_hour.toString().padLeft(2, '0')}:00';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // The browser may use a different time zone from the venue (Damascus).
    // Start on tomorrow at 10 rather than guessing whether today's hour has
    // already elapsed there; the user can still select today explicitly.
    _date = DateTime(now.year, now.month, now.day + 1);
    _hour = 10;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAvailability());
  }

  Future<void> _loadAvailability() async {
    final version = ++_requestVersion;
    final resources = _resources;
    setState(() {
      _loading = true;
      _availability = {};
      _selectedId = null;
      _error = null;
    });
    try {
      final statuses = await Future.wait(resources
          .map((resource) => _api.check(resource.id, _dateValue, _timeValue)));
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _availability = {
          for (var i = 0; i < resources.length; i++)
            resources[i].id: statuses[i],
        };
      });
    } on DioException catch (error) {
      if (!mounted || version != _requestVersion) return;
      final data = error.response?.data;
      setState(() => _error = data is Map && data['error'] is String
          ? data['error'] as String
          : 'تعذّر فحص التوفر. حاول مرة ثانية.');
    } catch (_) {
      if (!mounted || version != _requestVersion) return;
      setState(() => _error = 'تعذّر فحص التوفر. حاول مرة ثانية.');
    } finally {
      if (mounted && version == _requestVersion) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _reserve() async {
    final id = _selectedId;
    if (id == null || _availability[id] != true || _reserving) return;
    setState(() => _reserving = true);
    try {
      final confirmation = await _api.reserve(id, _dateValue, _timeValue);
      if (!mounted) return;
      try {
        await DemoBookingRegistry.record(confirmation);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'تم الحجز، لكن تعذّر حفظ المرجع على هذا الجهاز. احتفظ به: $confirmation')));
        await _loadAvailability();
        return;
      }
      if (mounted) context.go('/bookings');
    } on DioException catch (error) {
      if (!mounted) return;
      final data = error.response?.data;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(data is Map && data['error'] is String
              ? data['error'] as String
              : 'لم يكتمل الحجز التجريبي. تحقق من التوفر مرة ثانية.')));
      await _loadAvailability();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('لم يكتمل الحجز التجريبي. حاول مرة ثانية.')));
    } finally {
      if (mounted) setState(() => _reserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venue = _venue;
    final resources = _resources;
    final isDesk = widget.category == 'desk';
    if (venue == null ||
        !venue.id.startsWith('demo-space-') ||
        !['desk', 'office'].contains(widget.category)) {
      return const Scaffold(body: Center(child: Text('المساحة غير متاحة')));
    }
    final start = DateTime.now();
    final today = DateTime(start.year, start.month, start.day);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Column(children: [
            Text(isDesk ? 'اختيار مقعد' : 'اختيار مكتب',
                style: const TextStyle(fontSize: 18)),
            Text(venue.name,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          children: [
            const Text('حجز تجريبي · هذه ليست مقاعد مؤكدة في مكان فعلي.',
                style: TextStyle(color: Color(0xFF6B746E))),
            const SizedBox(height: 18),
            SizedBox(
              height: 45,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final day = today.add(Duration(days: index));
                  final active = DateUtils.isSameDay(day, _date);
                  final label = index == 0
                      ? 'اليوم'
                      : index == 1
                          ? 'غداً'
                          : '${day.day}/${day.month}';
                  return ChoiceChip(
                    label: Text(label),
                    selected: active,
                    selectedColor: _green,
                    labelStyle: TextStyle(
                        color: active ? Colors.white : Colors.black87),
                    onSelected: _reserving
                        ? null
                        : (_) {
                            setState(() => _date = day);
                            _loadAvailability();
                          },
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _hour,
                  decoration: const InputDecoration(
                    labelText: 'من الساعة',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var hour = 10; hour < 18; hour++)
                      DropdownMenuItem(
                        value: hour,
                        child: Text('${hour > 12 ? hour - 12 : hour}:00 '
                            '${hour < 12 ? 'ص' : 'م'}'),
                      ),
                  ],
                  onChanged: _reserving
                      ? null
                      : (hour) {
                          if (hour == null) return;
                          setState(() => _hour = hour);
                          _loadAvailability();
                        },
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: InputDecorator(
                  decoration: InputDecoration(
                      labelText: 'المدة', border: OutlineInputBorder()),
                  child: Text('ساعة واحدة'),
                ),
              ),
            ]),
            const SizedBox(height: 10),
            const Text('ساعات الحجز 10:00 ص – 6:00 م · آخر بداية 5:00 م',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B746E))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFBF9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(children: [
                Text(
                    isDesk
                        ? 'المقاعد (ترتيب توضيحي)'
                        : 'المكاتب (ترتيب توضيحي)',
                    style: const TextStyle(color: Color(0xFF68766D))),
                const SizedBox(height: 18),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else if (_error != null)
                  Column(children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(
                        onPressed: _loadAvailability,
                        child: const Text('إعادة المحاولة')),
                  ])
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: resources.length >= 4
                          ? 4
                          : resources.length == 1
                              ? 1
                              : 2,
                      crossAxisSpacing: 9,
                      mainAxisSpacing: 9,
                      childAspectRatio: resources.length == 1 ? 4.5 : 1.15,
                    ),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      final resource = resources[index];
                      final available = _availability[resource.id] == true;
                      final selected = _selectedId == resource.id;
                      return Material(
                        color: selected
                            ? _green
                            : available
                                ? Colors.white
                                : const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                          side: BorderSide(
                            color: selected
                                ? _green
                                : available
                                    ? const Color(0xFFBCC7BF)
                                    : const Color(0xFFD5DAD5),
                          ),
                        ),
                        child: InkWell(
                          onTap: !available || _reserving
                              ? null
                              : () => setState(() => _selectedId = resource.id),
                          borderRadius: BorderRadius.circular(13),
                          child: Center(
                            child: Text(
                              '${isDesk ? 'D' : 'O'}${index + 1}',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: selected
                                      ? Colors.white
                                      : available
                                          ? Colors.black87
                                          : Colors.grey),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ]),
            ),
            const SizedBox(height: 16),
            Wrap(spacing: 15, runSpacing: 8, children: [
              _Legend(color: Colors.white, label: 'متاح'),
              const _Legend(
                  color: Color(0xFFF0F0F0), label: 'محجوز أو غير متاح'),
              const _Legend(color: _green, label: 'محدد'),
            ]),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Row(children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedId == null
                        ? 'اختر ${isDesk ? 'مقعداً' : 'مكتباً'} متاحاً'
                        : '${isDesk ? 'مقعد' : 'مكتب'} ${resources.indexWhere((r) => r.id == _selectedId) + 1} · $_dateValue'),
                    const Text('ساعة واحدة · حجز تجريبي',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _selectedId != null && !_loading && !_reserving
                    ? _reserve
                    : null,
                style: FilledButton.styleFrom(backgroundColor: _green),
                child: Text(_reserving
                    ? 'جارٍ الحجز...'
                    : isDesk
                        ? 'حجز المقعد'
                        : 'حجز المكتب'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color,
              border: Border.all(color: const Color(0xFFBCC7BF)),
              borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]);
}
