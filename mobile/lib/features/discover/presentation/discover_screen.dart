import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';
import '../../../shared/mock/mock_venues.dart';
import '../amenities.dart';
import 'widgets/venue_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final Set<String> _selectedAmenities = {};

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
                Text('Filter amenities',
                    style: Theme.of(sheetContext).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Demo cafés have sample amenities. WorkHub amenities are not confirmed.'),
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
                      child: const Text('Clear'),
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
                      child: const Text('Show venues'),
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
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Filter venues',
            onPressed: _openFilters,
            icon: Badge.count(
              count: _selectedAmenities.length,
              isLabelVisible: _selectedAmenities.isNotEmpty,
              child: const Icon(Icons.filter_list_rounded),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_selectedAmenities.isNotEmpty) ...[
            Text(
              'Showing venues with ${_selectedAmenities.map(amenityLabel).join(', ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],
          if (venues.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Text(
                    _selectedAmenities.isEmpty
                        ? 'No venues are listed yet.'
                        : 'No venues have confirmed amenities matching these filters.',
                    textAlign: TextAlign.center,
                  ),
                  if (_selectedAmenities.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(_selectedAmenities.clear),
                      child: const Text('Clear filters'),
                    ),
                ],
              ),
            )
          else
            for (final venue in venues)
              VenueCard(
                venue: venue,
                onTap: () => context.push('/venue/${venue.id}'),
              ),
        ],
      ),
      bottomNavigationBar: const MahjoozBottomNav(currentIndex: 0),
    );
  }
}
