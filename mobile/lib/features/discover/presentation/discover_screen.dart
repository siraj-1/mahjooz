import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/widgets/mahjooz_bottom_nav.dart';
import '../../../shared/mock/mock_venues.dart';
import 'widgets/venue_card.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: replace mockVenues with a GET /venues call once Catalog is wired.
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockVenues.length,
        itemBuilder: (context, index) {
          final venue = mockVenues[index];
          return VenueCard(
            venue: venue,
            onTap: () => context.push('/venue/${venue.id}'),
          );
        },
      ),
      bottomNavigationBar: const MahjoozBottomNav(currentIndex: 0),
    );
  }
}
