import 'package:flutter/material.dart';

import '../../../shared/mock/mock_venues.dart';
import 'demo_venue_detail.dart';

class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final String venueId;

  @override
  Widget build(BuildContext context) {
    // TODO: replace with GET /venues/:id once Catalog is wired.
    for (final venue in mockVenues) {
      if (venue.id == venueId) return DemoVenueDetail(venue: venue);
    }
    return const Scaffold(
      body: Center(child: Text('المكان غير موجود')),
    );
  }
}
