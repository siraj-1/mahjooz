import 'package:flutter/material.dart';

import '../../shared/models/venue.dart';

class AmenityOption {
  const AmenityOption(this.code, this.label, this.icon);

  final String code;
  final String label;
  final IconData icon;
}

const amenityOptions = [
  AmenityOption('wifi', 'Wi-Fi', Icons.wifi_rounded),
  AmenityOption('coffee', 'Coffee', Icons.local_cafe_outlined),
  AmenityOption('parking', 'Parking', Icons.local_parking_rounded),
  AmenityOption('tv', 'TV', Icons.tv_outlined),
  AmenityOption('starlink', 'Starlink', Icons.satellite_alt_outlined),
];

String amenityLabel(String code) {
  for (final option in amenityOptions) {
    if (option.code == code) return option.label;
  }
  return code;
}

bool venueMatchesAmenities(Venue venue, Set<String> selected) =>
    venue.amenities.toSet().containsAll(selected);