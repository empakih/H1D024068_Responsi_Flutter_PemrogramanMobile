import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';

/// Service for searching cities via the Open-Meteo Geocoding API.
class GeocodingService {
  static const String _baseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mencari lokasi (kode ${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) {
      return [];
    }

    return results
        .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
