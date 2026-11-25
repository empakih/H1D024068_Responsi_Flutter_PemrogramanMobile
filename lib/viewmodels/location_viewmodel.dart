import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/geocoding_service.dart';
import '../services/storage_service.dart';

/// ViewModel managing city search results and persisted favorite locations.
class LocationViewModel extends ChangeNotifier {
  final GeocodingService _geocodingService;
  final StorageService _storageService;

  LocationViewModel({
    GeocodingService? geocodingService,
    StorageService? storageService,
  })  : _geocodingService = geocodingService ?? GeocodingService(),
        _storageService = storageService ?? StorageService();

  List<LocationModel> _searchResults = [];
  List<LocationModel> _favorites = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _searchError;

  List<LocationModel> get searchResults => _searchResults;
  List<LocationModel> get favorites => _favorites;
  bool get isSearching => _isSearching;
  bool get hasSearched => _hasSearched;
  String? get searchError => _searchError;

  Future<void> init() async {
    _favorites = await _storageService.loadFavorites();
    notifyListeners();
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      _searchError = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _hasSearched = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _geocodingService.searchLocations(trimmed);
    } catch (e) {
      _searchError = e.toString().replaceFirst('Exception: ', '');
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  bool isFavorite(LocationModel location) {
    return _favorites.contains(location);
  }

  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites.remove(location);
    } else {
      _favorites.add(location);
    }
    notifyListeners();
    await _storageService.saveFavorites(_favorites);
  }
}
