import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// ViewModel managing the active location and its weather state (MVVM).
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  static const LocationModel _defaultLocation = LocationModel(
    id: 1642911,
    name: 'Jakarta',
    country: 'Indonesia',
    admin1: 'Jakarta',
    latitude: -6.2146,
    longitude: 106.8451,
  );

  WeatherViewModel({
    WeatherService? weatherService,
    StorageService? storageService,
  })  : _weatherService = weatherService ?? WeatherService(),
        _storageService = storageService ?? StorageService();

  LocationModel _selectedLocation = _defaultLocation;
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  LocationModel get selectedLocation => _selectedLocation;
  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads the last selected location from local storage and fetches weather.
  Future<void> init() async {
    final saved = await _storageService.loadSelectedLocation();
    if (saved != null) {
      _selectedLocation = saved;
    }
    await fetchWeather();
  }

  /// Updates the active location, persists it, and fetches fresh weather data.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _storageService.saveSelectedLocation(location);
    await fetchWeather();
  }

  Future<void> fetchWeather() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _weatherService.fetchWeather(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
