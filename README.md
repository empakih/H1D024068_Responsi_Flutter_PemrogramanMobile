# Weather App (Responsi Flutter)

Aplikasi prakiraan cuaca berbasis Flutter menggunakan **Open-Meteo API** dengan pola arsitektur **MVVM (Model-View-ViewModel)**, state management **Provider**, dan penyimpanan lokal **SharedPreferences**.

## Struktur Aplikasi

```text
lib/
├── main.dart                     # Entry point & konfigurasi MultiProvider
├── models/
│   ├── location_model.dart       # Model data lokasi (Geocoding & Local Storage)
│   └── weather_model.dart        # Model data cuaca terkini & prakiraan harian
├── services/
│   ├── geocoding_service.dart    # HTTP GET ke Open-Meteo Geocoding API
│   ├── storage_service.dart      # Local Storage (SharedPreferences) untuk favorit
│   └── weather_service.dart      # HTTP GET ke Open-Meteo Forecast API
├── theme/
│   └── app_theme.dart            # Material Design 3 Theme & Typography
├── viewmodels/
│   ├── location_viewmodel.dart   # State pencarian kota & daftar lokasi favorit
│   └── weather_viewmodel.dart    # State cuaca aktif (loading, data, error)
└── views/
    ├── home_screen.dart          # Home / Weather Screen
    └── search_screen.dart        # Search / Location Screen
```

## Implementasi API

1. **Open-Meteo Weather Forecast API** (`https://api.open-meteo.com/v1/forecast`)
   - Parameter: `latitude`, `longitude`, `timezone=auto`, `current`, dan `daily`.
   - Data `current`: `temperature_2m`, `relative_humidity_2m`, `apparent_temperature`, `precipitation`, `weather_code`, `wind_speed_10m`.
   - Data `daily`: `weather_code`, `temperature_2m_max`, `temperature_2m_min`, `precipitation_probability_max`.
2. **Open-Meteo Geocoding API** (`https://geocoding-api.open-meteo.com/v1/search`)
   - Digunakan pada fitur pencarian kota berdasarkan nama (`name`, `count=10`, `language=id`).

## Penerapan MVVM

- **Model**: `WeatherModel`, `CurrentWeather`, `DailyForecast`, dan `LocationModel` merepresentasikan struktur data dari JSON API dan penyimpanan lokal.
- **View**: `HomeScreen` dan `SearchScreen` hanya bertugas menampilkan UI dan meneruskan aksi pengguna ke ViewModel.
- **ViewModel**: `WeatherViewModel` dan `LocationViewModel` (turunan `ChangeNotifier`) memanggil `Service`, mengelola state (`isLoading`, `errorMessage`, data), dan memanggil `notifyListeners()` agar UI otomatis ter-update.

## Screenshot Aplikasi

> Letakkan screenshot setiap screen aplikasi di bagian ini setelah menjalankan aplikasi pada emulator/perangkat.

- **Home / Weather Screen**: *(tambahkan screenshot di sini)*
- **Search / Location Screen**: *(tambahkan screenshot di sini)*
