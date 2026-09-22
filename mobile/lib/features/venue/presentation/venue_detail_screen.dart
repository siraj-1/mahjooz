import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/mock/mock_venues.dart';
import '../../../shared/models/venue.dart';

class VenueDetailScreen extends StatelessWidget {
  const VenueDetailScreen({super.key, required this.venueId});

  final String venueId;

  @override
  Widget build(BuildContext context) {
    // TODO: replace with GET /venues/:id once Catalog is wired.
    final venue = mockVenues.firstWhere(
      (v) => v.id == venueId,
      orElse: () => mockVenues.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text(venue.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (venue.description != null) Text(venue.description!),
          const SizedBox(height: 16),
          for (final branch in venue.branches) _BranchSection(branch: branch),
        ],
      ),
    );
  }
}

class _BranchSection extends StatelessWidget {
  const _BranchSection({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(branch.name, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final resource in branch.resources)
          Card(
            child: ListTile(
              title: Text(resource.name),
              subtitle: Text(
                resource.type == 'pooled'
                    ? 'Shared · capacity ${resource.capacity ?? '-'}'
                    : 'Private resource',
              ),
              trailing: TextButton(
                onPressed: () => context.push(
                  '/venue/${branch.venueId}/book/${resource.id}',
                ),
                child: const Text('Book'),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
