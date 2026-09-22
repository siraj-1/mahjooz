class Resource {
  const Resource({
    required this.id,
    required this.branchId,
    required this.name,
    required this.type,
    this.capacity,
    this.isActive = true,
  });

  final String id;
  final String branchId;
  final String name;

  /// 'pooled' (booked by capacity) or 'specific' (booked by exact resource).
  final String type;
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
    this.branches = const [],
  });

  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? country;
  final String? contactPhone;
  final List<Branch> branches;
}
