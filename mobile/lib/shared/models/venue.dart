class Resource {
  const Resource({
    required this.id,
    required this.branchId,
    required this.name,
    required this.type,
    this.category,
    this.capacity,
    this.isActive = true,
  });

  final String id;
  final String branchId;
  final String name;

  /// 'pooled' (booked by capacity) or 'specific' (booked by exact resource).
  final String type;

  /// 'desk' or 'office' for resources shown in the Discover preview.
  final String? category;
  final int? capacity;
  final bool isActive;
}

class Branch {
  const Branch({
    required this.id,
    required this.venueId,
    required this.name,
    this.code,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.resources = const [],
  });

  final String id;
  final String venueId;
  final String name;
  final String? code;
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  final List<Resource> resources;
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.country,
    this.contactPhone,
    this.amenities = const [],
    this.branches = const [],
    this.openingHour,
    this.closingHour,
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? country;
  final String? contactPhone;

  /// Confirmed amenity codes. An empty list means no amenities are confirmed.
  final List<String> amenities;
  final List<Branch> branches;

  /// Stated booking hours; these do not imply a particular slot is free.
  final int? openingHour;
  final int? closingHour;

  int countResources(String category) => branches
      .expand((branch) => branch.resources)
      .where((resource) => resource.isActive && resource.category == category)
      .length;
}
