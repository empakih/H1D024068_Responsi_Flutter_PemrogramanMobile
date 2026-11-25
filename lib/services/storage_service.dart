import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// Local storage service using SharedPreferences to persist favorite
/// locations and the last selected location.
class StorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _selectedLocationKey = 'selected_location';

  Future<List<LocationModel>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_favoritesKey) ?? [];
    return rawList
        .map(
          (item) => LocationModel.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = favorites.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  Future<LocationModel?> loadSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_selectedLocationKey);
    if (raw == null || raw.isEmpty) return null;
    return LocationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedLocationKey, jsonEncode(location.toJson()));
  }
}
