import 'package:flutter/material.dart';

import '../../../../shared/models/venue.dart';

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
            '${venue.branches.length} branch${venue.branches.length == 1 ? '' : 'es'}',
          ].whereType<String>().join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
