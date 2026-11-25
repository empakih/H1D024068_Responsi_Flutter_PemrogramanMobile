import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/liquid_glass_card.dart';
import 'search_screen.dart';

/// Main screen displaying current weather and multi-day forecast for the
/// selected city with an atmospheric full-bleed background.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<Color> _backgroundColors(BuildContext context, int? weatherCode) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const [
        Color(0xFF1A2230),
        Color(0xFF141B26),
        Color(0xFF0E131B),
      ];
    }
    if (weatherCode == null || weatherCode <= 1) {
      return const [
        Color(0xFF4A78A8),
        Color(0xFF648CB5),
        Color(0xFF7B9EC2),
      ];
    }
    return const [
      Color(0xFF56667A),
      Color(0xFF66768A),
      Color(0xFF758599),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final themeVm = context.watch<ThemeViewModel>();
    final location = weatherVm.selectedLocation;
    final isFav = locationVm.isFavorite(location);
    final bgColors = _backgroundColors(
      context,
      weatherVm.weather?.current.weatherCode,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Cari Lokasi',
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SearchScreen(),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        location.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip:
                          themeVm.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                      icon: Icon(
                        themeVm.isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      onPressed: themeVm.toggleTheme,
                    ),
                    IconButton(
                      tooltip:
                          isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                      icon: Icon(
                        isFav ? Icons.star_rounded : Icons.star_border_rounded,
                        color: isFav ? Colors.amber : Colors.white,
                      ),
                      onPressed: () => locationVm.toggleFavorite(location),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: weatherVm.fetchWeather,
                  child: _buildBody(context, weatherVm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    if (vm.isLoading && vm.weather == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (vm.errorMessage != null && vm.weather == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          const Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: Colors.white70,
          ),
          const SizedBox(height: 16),
          const Text(
            'Terjadi Kesalahan',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: vm.fetchWeather,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      );
    }

    final weather = vm.weather;
    if (weather == null) {
      return const Center(
        child: Text(
          'Data cuaca tidak tersedia.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final current = weather.current;
    final todayMax = weather.daily.isNotEmpty
        ? weather.daily.first.temperature2mMax.toStringAsFixed(0)
        : '--';
    final todayMin = weather.daily.isNotEmpty
        ? weather.daily.first.temperature2mMin.toStringAsFixed(0)
        : '--';
    final todayRainChance = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbabilityMax
        : 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      children: [
        if (vm.isLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(color: Colors.white),
          ),
        _HeroWeatherSection(
          current: current,
          todayMax: todayMax,
          todayMin: todayMin,
          rainChance: todayRainChance,
        ),
        const SizedBox(height: 32),
        if (weather.daily.isNotEmpty) _ForecastCard(daily: weather.daily),
        const SizedBox(height: 16),
        _WeatherDetailsGrid(
          current: current,
          rainChance: todayRainChance,
        ),
      ],
    );
  }
}

class _HeroWeatherSection extends StatelessWidget {
  final CurrentWeather current;
  final String todayMax;
  final String todayMin;
  final int rainChance;

  const _HeroWeatherSection({
    required this.current,
    required this.todayMax,
    required this.todayMin,
    required this.rainChance,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current.temperature2m.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 88,
                fontWeight: FontWeight.w300,
                height: 1.0,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '°C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${WeatherCodeHelper.description(current.weatherCode)}  $todayMax°/$todayMin°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Terasa ${current.apparentTemperature.toStringAsFixed(0)}° • Hujan $rainChance%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final List<DailyForecast> daily;

  const _ForecastCard({required this.daily});

  String _dayLabel(int index, String isoDate) {
    if (index == 0) return 'Hari ini';
    if (index == 1) return 'Besok';
    return isoDate;
  }

  @override
  Widget build(BuildContext context) {
    final items = daily.take(5).toList();

    return LiquidGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                'Ramalan ${items.length} hari',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(items.length, (index) {
            final day = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    WeatherCodeHelper.icon(day.weatherCode),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_dayLabel(index, day.date)}  ${WeatherCodeHelper.description(day.weatherCode)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${day.temperature2mMax.toStringAsFixed(0)}° / ${day.temperature2mMin.toStringAsFixed(0)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WeatherDetailsGrid extends StatelessWidget {
  final CurrentWeather current;
  final int rainChance;

  const _WeatherDetailsGrid({
    required this.current,
    required this.rainChance,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.7,
          children: [
            _DetailTile(
              icon: Icons.water_drop_outlined,
              label: 'Kelembapan',
              value: '${current.relativeHumidity2m}%',
            ),
            _DetailTile(
              icon: Icons.air_rounded,
              label: 'Kecepatan Angin',
              value: '${current.windSpeed10m.toStringAsFixed(1)} km/j',
            ),
            _DetailTile(
              icon: Icons.umbrella_outlined,
              label: 'Curah Hujan',
              value: '${current.precipitation.toStringAsFixed(1)} mm',
            ),
            _DetailTile(
              icon: Icons.grain_rounded,
              label: 'Peluang Hujan',
              value: '$rainChance%',
            ),
          ],
        );
      },
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
