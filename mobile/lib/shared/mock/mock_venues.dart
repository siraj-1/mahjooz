import '../models/venue.dart';

/// UI-only samples. WorkHub is the original product example and has no
/// confirmed amenities. The clearly named demo cafés have invented amenities
/// solely to demonstrate filtering; none of these are live listings. The two
/// demo spaces have separate server-owned preview reservations, not real
/// venue inventory; stated hours alone never imply availability.
final List<Venue> mockVenues = [
  const Venue(
    id: 'demo-space-rukn',
    name: 'مساحة ركن',
    description: 'مكان تجريبي غير مؤكد. الحجوزات تجريبية وليست حجوزات فعلية.',
    openingHour: 10,
    closingHour: 18,
    branches: [
      Branch(
        id: 'demo-branch-rukn',
        venueId: 'demo-space-rukn',
        name: 'مساحة ركن',
        resources: [
          Resource(
              id: 'rukn-desk-1',
              branchId: 'demo-branch-rukn',
              name: 'مقعد ١',
              type: 'specific',
              category: 'desk'),
          Resource(
              id: 'rukn-desk-2',
              branchId: 'demo-branch-rukn',
              name: 'مقعد ٢',
              type: 'specific',
              category: 'desk'),
          Resource(
              id: 'rukn-desk-3',
              branchId: 'demo-branch-rukn',
              name: 'مقعد ٣',
              type: 'specific',
              category: 'desk'),
          Resource(
              id: 'rukn-desk-4',
              branchId: 'demo-branch-rukn',
              name: 'مقعد ٤',
              type: 'specific',
              category: 'desk'),
          Resource(
              id: 'rukn-office-1',
              branchId: 'demo-branch-rukn',
              name: 'مكتب ١',
              type: 'specific',
              category: 'office'),
        ],
      ),
    ],
  ),
  const Venue(
    id: 'demo-space-hudoo',
    name: 'قاعة هدوء',
    description: 'مكان تجريبي غير مؤكد. الحجوزات تجريبية وليست حجوزات فعلية.',
    openingHour: 10,
    closingHour: 18,
    branches: [
      Branch(
        id: 'demo-branch-hudoo',
        venueId: 'demo-space-hudoo',
        name: 'قاعة هدوء',
        resources: [
          Resource(
              id: 'hudoo-desk-1',
              branchId: 'demo-branch-hudoo',
              name: 'مقعد ١',
              type: 'specific',
              category: 'desk'),
          Resource(
              id: 'hudoo-office-1',
              branchId: 'demo-branch-hudoo',
              name: 'مكتب ١',
              type: 'specific',
              category: 'office'),
          Resource(
              id: 'hudoo-office-2',
              branchId: 'demo-branch-hudoo',
              name: 'مكتب ٢',
              type: 'specific',
              category: 'office'),
        ],
      ),
    ],
  ),
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
    description:
        'Sample café for previewing the venue filters. Not a live listing.',
    city: 'Aleppo',
    country: 'Syria',
    amenities: ['wifi', 'coffee'],
  ),
  const Venue(
    id: 'demo-cafe-mosaic',
    name: 'Demo Mosaic Café',
    description:
        'Sample café for previewing the venue filters. Not a live listing.',
    city: 'Aleppo',
    country: 'Syria',
    amenities: ['wifi', 'parking', 'tv'],
  ),
  const Venue(
    id: 'demo-cafe-lantern',
    name: 'Demo Lantern Café',
    description:
        'Sample café for previewing the venue filters. Not a live listing.',
    city: 'Aleppo',
    country: 'Syria',
    amenities: ['coffee', 'tv', 'starlink'],
  ),
];
