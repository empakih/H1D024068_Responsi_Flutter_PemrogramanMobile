import 'package:flutter/material.dart';

/// Current weather conditions from Open-Meteo `current` object.
class CurrentWeather {
  final double temperature2m;
  final int relativeHumidity2m;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed10m;

  const CurrentWeather({
    required this.temperature2m,
    required this.relativeHumidity2m,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed10m,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature2m: (json['temperature_2m'] as num).toDouble(),
      relativeHumidity2m: (json['relative_humidity_2m'] as num).toInt(),
      apparentTemperature: (json['apparent_temperature'] as num).toDouble(),
      precipitation: (json['precipitation'] as num).toDouble(),
      weatherCode: (json['weather_code'] as num).toInt(),
      windSpeed10m: (json['wind_speed_10m'] as num).toDouble(),
    );
  }
}

/// Daily weather forecast entry from Open-Meteo `daily` arrays.
class DailyForecast {
  final String date;
  final double temperature2mMax;
  final double temperature2mMin;
  final int precipitationProbabilityMax;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.temperature2mMax,
    required this.temperature2mMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });
}

/// Aggregated weather response combining current and daily forecast data.
class WeatherModel {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherModel({
    required this.current,
    required this.daily,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>;
    final dailyJson = json['daily'] as Map<String, dynamic>;

    final times = (dailyJson['time'] as List<dynamic>).cast<String>();
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();
    final precipProbs =
        (dailyJson['precipitation_probability_max'] as List<dynamic>)
            .map((e) => (e as num?)?.toInt() ?? 0)
            .toList();
    final codes = (dailyJson['weather_code'] as List<dynamic>)
        .map((e) => (e as num?)?.toInt() ?? 0)
        .toList();

    final dailyList = List<DailyForecast>.generate(
      times.length,
      (i) => DailyForecast(
        date: times[i],
        temperature2mMax: maxTemps[i],
        temperature2mMin: minTemps[i],
        precipitationProbabilityMax: precipProbs[i],
        weatherCode: codes[i],
      ),
    );

    return WeatherModel(
      current: CurrentWeather.fromJson(currentJson),
      daily: dailyList,
    );
  }
}

/// Maps WMO weather interpretation codes to Indonesian labels and Material icons.
class WeatherCodeHelper {
  static String description(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Deras';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
      case 96:
      case 99:
        return 'Badai Petir';
      default:
        return 'Tidak Diketahui';
    }
  }

  static IconData icon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1 || code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.grain_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.wb_sunny_rounded;
  }
}
