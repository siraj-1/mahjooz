import 'package:flutter/material.dart';

import '../../../../shared/models/venue.dart';
import '../../amenities.dart';

class VenueCard extends StatelessWidget {
  const VenueCard({super.key, required this.venue, this.onTap});

  final Venue venue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(venue.name),
        subtitle: Text(
          [
            venue.city,
            if (venue.branches.isNotEmpty)
              '${venue.branches.length} branch${venue.branches.length == 1 ? '' : 'es'}',
            if (venue.amenities.isEmpty)
              'Amenities not confirmed'
            else
              venue.amenities.map(amenityLabel).join(', '),
          ].whereType<String>().join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
