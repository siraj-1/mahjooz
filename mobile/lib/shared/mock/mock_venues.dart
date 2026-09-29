import '../models/venue.dart';

/// UI-only samples. WorkHub is the original product example and has no
/// confirmed amenities. The clearly named demo cafés have invented amenities
/// solely to demonstrate filtering; none of these are live listings.
final List<Venue> mockVenues = [
  Venue(
    id: 'venue-workhub',
    name: 'WorkHub',
    description: 'Coworking spaces across Aleppo.',
    city: 'Aleppo',
    country: 'Syria',
    contactPhone: '+963 21 000 0000',
    branches: [
      Branch(
        id: 'branch-university',
        venueId: 'venue-workhub',
        name: 'University Branch',
        city: 'Aleppo',
        resources: [
          Resource(
            id: 'res-open-workspace',
            branchId: 'branch-university',
            name: 'Open Workspace',
            type: 'pooled',
            capacity: 30,
          ),
          Resource(
            id: 'res-meeting-a',
            branchId: 'branch-university',
            name: 'Meeting Room A',
            type: 'specific',
          ),
          Resource(
            id: 'res-meeting-b',
            branchId: 'branch-university',
            name: 'Meeting Room B',
            type: 'specific',
          ),
          Resource(
            id: 'res-private-1',
            branchId: 'branch-university',
            name: 'Private Office 1',
            type: 'specific',
          ),
          Resource(
            id: 'res-study-room',
            branchId: 'branch-university',
            name: 'Study Room',
            type: 'pooled',
            capacity: 10,
          ),
        ],
      ),
      Branch(
        id: 'branch-mogambo',
        venueId: 'venue-workhub',
        name: 'Mogambo Branch',
        city: 'Aleppo',
      ),
      Branch(
        id: 'branch-new-aleppo',
        venueId: 'venue-workhub',
        name: 'New Aleppo Branch',
        city: 'Aleppo',
      ),
    ],
  ),
  const Venue(
    id: 'demo-cafe-cedar',
    name: 'Demo Cedar Café',
    description: 'Sample café for previewing the venue filters. Not a live listing.',
    city: 'Aleppo',
    country: 'Syria',
    amenities: ['wifi', 'coffee'],
  ),
  const Venue(
    id: 'demo-cafe-mosaic',
    name: 'Demo Mosaic Café',
    description: 'Sample café for previewing the venue filters. Not a live listing.',
    city: 'Aleppo',
    country: 'Syria',
    amenities: ['wifi', 'parking', 'tv'],
  ),
  const Venue(
    id: 'demo-cafe-lantern',
    name: 'Demo Lantern Café',
    description: 'Sample café for previewing the venue filters. Not a live listing.',
    city: 'Aleppo',
    country: 'Syria',
    amenities: ['coffee', 'tv', 'starlink'],
  ),
];
