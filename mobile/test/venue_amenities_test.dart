import 'package:flutter_test/flutter_test.dart';
import 'package:mahjooz/features/discover/amenities.dart';
import 'package:mahjooz/shared/mock/mock_venues.dart';
import 'package:mahjooz/shared/models/venue.dart';

void main() {
  test('unfiltered sample venue remains visible without confirmed amenities', () {
    final workHub = mockVenues.firstWhere((venue) => venue.id == 'venue-workhub');
    expect(workHub.amenities, isEmpty);
    expect(venueMatchesAmenities(workHub, {}), isTrue);
    expect(venueMatchesAmenities(workHub, {'wifi'}), isFalse);
  });

  test('three demo cafés cover every amenity filter', () {
    final cafes = mockVenues.where((venue) => venue.id.startsWith('demo-cafe-'));
    expect(cafes.length, 3);
    for (final option in amenityOptions) {
      expect(
        cafes.any((venue) => venueMatchesAmenities(venue, {option.code})),
        isTrue,
        reason: '${option.label} should match at least one demo café',
      );
    }
    expect(
      cafes.where((venue) => venueMatchesAmenities(venue, {'coffee', 'starlink'}))
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