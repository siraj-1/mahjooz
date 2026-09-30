import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';
import '../../../shared/mock/mock_venues.dart';
import '../../../shared/models/venue.dart';
import '../data/demo_booking_api.dart';
import '../data/demo_booking_registry.dart';

const _green = Color(0xFF187E58);

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _api = DemoBookingApi();
  List<DemoBooking> _bookings = [];
  bool _loading = true;
  String? _error;
  String? _cancellingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ids = await DemoBookingRegistry.readIds();
      final bookings = await Future.wait(ids.reversed.map(_api.find));
      if (!mounted) return;
      setState(() => _bookings = bookings);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'تعذّر تحميل الحجوزات المحفوظة. تحقّق من الاتصال ثم حاول مرة ثانية.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmCancel(DemoBooking booking) async {
    if (_cancellingId != null || booking.cancelled) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إلغاء الحجز التجريبي؟'),
        content: const Text(
            'سيصبح هذا الموعد متاحاً للحجز مرة أخرى. لا يمكن التراجع عن الإلغاء.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('العودة')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancellingId = booking.id);
    try {
      await _api.cancel(booking.id);
      if (!mounted) return;
      await _load();
    } on DioException catch (error) {
      if (!mounted) return;
      final message = error.response?.statusCode == 409
          ? 'لا يمكن إلغاء حجز بدأ موعده أو أُلغي مسبقاً.'
          : error.response?.statusCode == 404
              ? 'لم يعد هذا الحجز موجوداً.'
              : 'تعذّر إلغاء الحجز. حاول مرة ثانية.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر إلغاء الحجز. حاول مرة ثانية.')));
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(title: const Text('حجوزاتي')),
          body: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 10),
                            TextButton(
                                onPressed: _load,
                                child: const Text('إعادة المحاولة')),
                          ],
                        ),
                      ),
                    )
                  : _bookings.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.event_note_outlined,
                                    size: 44, color: _green),
                                const SizedBox(height: 14),
                                const Text('لا توجد حجوزات تجريبية بعد',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                const SizedBox(height: 8),
                                const Text(
                                  'الحجوزات هنا مرتبطة بهذا الجهاز فقط، وليست حجوزات في أماكن فعلية.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                TextButton(
                                  onPressed: () => context.go('/home'),
                                  child: const Text('استكشف الأماكن'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                            children: [
                              const Text(
                                'حجوزات تجريبية محفوظة على هذا الجهاز. ليست حجوزات في أماكن فعلية.',
                                style: TextStyle(
                                    fontSize: 11, color: Color(0xFF68756C)),
                              ),
                              const SizedBox(height: 15),
                              for (final booking in _bookings)
                                _BookingCard(
                                  booking: booking,
                                  cancelling: _cancellingId == booking.id,
                                  onCancel: _cancellingId == null
                                      ? () => _confirmCancel(booking)
                                      : null,
                                ),
                            ],
                          ),
                        ),
          bottomNavigationBar: const MahjoozBottomNav(currentIndex: 1),
        ),
      );
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.cancelling,
    required this.onCancel,
  });

  final DemoBooking booking;
  final bool cancelling;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    Venue? venue;
    Resource? resource;
    for (final candidate in mockVenues) {
      for (final item
          in candidate.branches.expand((branch) => branch.resources)) {
        if (item.id == booking.resourceId) {
          venue = candidate;
          resource = item;
          break;
        }
      }
      if (resource != null) break;
    }
    final isPast =
        booking.startsAt.add(const Duration(hours: 1)).isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E7E0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  venue?.name ?? 'مساحة تجريبية',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6EDD4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                    booking.cancelled
                        ? 'ملغى'
                        : isPast
                            ? 'موعد سابق'
                            : 'مؤكد تجريبياً',
                    style: const TextStyle(color: _green, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(resource?.name ?? booking.resourceId,
              style: const TextStyle(color: Color(0xFF56645B), fontSize: 12)),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
                '${booking.date}  ·  ${booking.time}–'
                '${(int.parse(booking.time.substring(0, 2)) + 1).toString().padLeft(2, '0')}:00',
                style: const TextStyle(fontSize: 12)),
          ),
          const Divider(height: 23),
          SelectableText('المرجع: ${booking.id}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF68756C))),
          if (!booking.cancelled &&
              booking.startsAt.isAfter(DateTime.now())) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: onCancel,
                style:
                    TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                child: Text(cancelling ? 'جارٍ الإلغاء...' : 'إلغاء الحجز'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
