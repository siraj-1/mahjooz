import 'package:flutter_test/flutter_test.dart';
import 'package:mahjooz/features/discover/amenities.dart';
import 'package:mahjooz/shared/mock/mock_venues.dart';
import 'package:mahjooz/shared/models/venue.dart';

void main() {
  test('preview spaces have the stated desk, office, and booking hours', () {
    final rukn =
        mockVenues.firstWhere((venue) => venue.id == 'demo-space-rukn');
    final hudoo =
        mockVenues.firstWhere((venue) => venue.id == 'demo-space-hudoo');
    expect(
        [rukn.countResources('desk'), rukn.countResources('office')], [4, 1]);
    expect(
        [hudoo.countResources('desk'), hudoo.countResources('office')], [1, 2]);
    for (final venue in [rukn, hudoo]) {
      expect(venue.openingHour, 10);
      expect(venue.closingHour, 18);
      expect(
          venue.branches
              .expand((branch) => branch.resources)
              .map((resource) => resource.id)
              .toSet()
              .length,
          venue.countResources('desk') + venue.countResources('office'));
    }
  });

  test('unfiltered sample venue remains visible without confirmed amenities',
      () {
    final workHub =
        mockVenues.firstWhere((venue) => venue.id == 'venue-workhub');
    expect(workHub.amenities, isEmpty);
    expect(venueMatchesAmenities(workHub, {}), isTrue);
    expect(venueMatchesAmenities(workHub, {'wifi'}), isFalse);
  });

  test('three demo cafés cover every amenity filter', () {
    final cafes =
        mockVenues.where((venue) => venue.id.startsWith('demo-cafe-'));
    expect(cafes.length, 3);
    for (final option in amenityOptions) {
      expect(
        cafes.any((venue) => venueMatchesAmenities(venue, {option.code})),
        isTrue,
        reason: '${option.label} should match at least one demo café',
      );
    }
    expect(
      cafes
          .where(
              (venue) => venueMatchesAmenities(venue, {'coffee', 'starlink'}))
          .map((venue) => venue.name),
      ['Demo Lantern Café'],
    );
  });

  test('multiple selected amenities must all be confirmed', () {
    const venue = Venue(
      id: 'test',
      name: 'Test venue',
      amenities: ['wifi', 'coffee'],
    );
    expect(venueMatchesAmenities(venue, {'wifi', 'coffee'}), isTrue);
    expect(venueMatchesAmenities(venue, {'wifi', 'starlink'}), isFalse);
  });
}
