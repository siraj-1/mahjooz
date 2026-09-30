import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';
import '../../../shared/mock/mock_venues.dart';
import '../amenities.dart';
import 'widgets/venue_card.dart';

const _green = Color(0xFF187E58);

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final Set<String> _selectedAmenities = {};
  String _resourceCategory = 'desk';

  void _openFilters() {
    final draft = {..._selectedAmenities};
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, updateSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تصفية الخدمات',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text(
                    'الخدمات في المقاهي التجريبية أمثلة فقط. خدمات WorkHub غير مؤكدة.'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final option in amenityOptions)
                      FilterChip(
                        avatar: Icon(option.icon, size: 18),
                        label: Text(option.label),
                        selected: draft.contains(option.code),
                        onSelected: (selected) => updateSheet(() {
                          if (selected) {
                            draft.add(option.code);
                          } else {
                            draft.remove(option.code);
                          }
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => updateSheet(draft.clear),
                      child: const Text('مسح'),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _selectedAmenities
                            ..clear()
                            ..addAll(draft);
                        });
                        Navigator.of(sheetContext).pop();
                      },
                      child: const Text('عرض الأماكن'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: replace mockVenues with a GET /venues call once Catalog is wired.
    final venues = mockVenues
        .where((venue) => venueMatchesAmenities(venue, _selectedAmenities))
        .where((venue) =>
            !venue.id.startsWith('demo-space-') ||
            venue.countResources(_resourceCategory) > 0)
        .toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          title: const Text('محجوز.',
              style: TextStyle(
                  fontSize: 26, color: _green, fontWeight: FontWeight.w600)),
          centerTitle: false,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          children: [
            Text('وين بدك تشتغل اليوم؟',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202920),
                )),
            const SizedBox(height: 4),
            const Text('مقاعد عمل ومكاتب خاصة في مكان واحد',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B746E))),
            const SizedBox(height: 27),
            Container(
              height: 60,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E6DF)),
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  _CategoryButton(
                    label: 'مقعد عمل',
                    selected: _resourceCategory == 'desk',
                    onTap: () => setState(() => _resourceCategory = 'desk'),
                  ),
                  _CategoryButton(
                    label: 'مكتب خاص',
                    selected: _resourceCategory == 'office',
                    onTap: () => setState(() => _resourceCategory = 'office'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCF1DC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text('ساعات الحجز  10 ص – 6 م',
                    style: TextStyle(
                        color: Color(0xFF236C40),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _openFilters,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF263E30),
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.tune_rounded, size: 17),
                  const SizedBox(width: 6),
                  Text(
                      _selectedAmenities.isEmpty
                          ? 'فلترة'
                          : 'فلترة (${_selectedAmenities.length})',
                      style: const TextStyle(fontSize: 12)),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Expanded(
                  child: Text('مساحات للاستكشاف',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _selectedAmenities.clear();
                    _resourceCategory = 'desk';
                  }),
                  style: TextButton.styleFrom(foregroundColor: _green),
                  child: const Text('عرض الكل', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            if (_selectedAmenities.isNotEmpty) ...[
              Text(
                  'الخدمات: ${_selectedAmenities.map(amenityLabel).join('، ')}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
            ],
            if (venues.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Text('لا توجد أماكن تطابق هذه التصفية.'),
                    TextButton(
                      onPressed: () => setState(_selectedAmenities.clear),
                      child: const Text('مسح التصفية'),
                    ),
                  ],
                ),
              )
            else
              for (final venue in venues)
                VenueCard(
                  venue: venue,
                  category: _resourceCategory,
                  onTap: () => context.push('/venue/${venue.id}'),
                ),
          ],
        ),
        bottomNavigationBar: const MahjoozBottomNav(currentIndex: 0),
      ),
    );
  }
}

class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Material(
          color: selected ? _green : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          selected ? Colors.white : const Color(0xFF2B3930))),
            ),
          ),
        ),
      );
}
