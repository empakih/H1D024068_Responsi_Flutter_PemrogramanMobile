/// Model representing a geographic location from Open-Meteo Geocoding API
/// or local storage.
class LocationModel {
  final int id;
  final String name;
  final String country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.id,
    required this.name,
    required this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Human-readable subtitle combining region and country.
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          name == other.name;

  @override
  int get hashCode => Object.hash(name, latitude, longitude);
}
