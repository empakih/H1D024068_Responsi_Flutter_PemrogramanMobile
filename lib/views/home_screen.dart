import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';

/// Main screen displaying current weather and multi-day forecast for the
/// selected city.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final locationVm = context.watch<LocationViewModel>();
    final location = weatherVm.selectedLocation;
    final isFav = locationVm.isFavorite(location);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.name),
            if (location.subtitle.isNotEmpty)
              Text(
                location.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isFav ? 'Hapus dari favorit' : 'Simpan ke favorit',
            icon: Icon(
              isFav ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFav ? Colors.amber : null,
            ),
            onPressed: () => locationVm.toggleFavorite(location),
          ),
          IconButton(
            tooltip: 'Cari Lokasi',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: weatherVm.fetchWeather,
        child: _buildBody(context, weatherVm),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    if (vm.isLoading && vm.weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null && vm.weather == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.cloud_off_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi Kesalahan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            vm.errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
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
      return const Center(child: Text('Data cuaca tidak tersedia.'));
    }

    final current = weather.current;
    final todayRainChance = weather.daily.isNotEmpty
        ? weather.daily.first.precipitationProbabilityMax
        : 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (vm.isLoading) const LinearProgressIndicator(),
        _CurrentWeatherCard(
          current: current,
          rainChance: todayRainChance,
        ),
        const SizedBox(height: 16),
        _WeatherDetailsGrid(
          current: current,
          rainChance: todayRainChance,
        ),
        const SizedBox(height: 24),
        Text(
          'Prakiraan Beberapa Hari ke Depan',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (weather.daily.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Data prakiraan harian kosong.'),
            ),
          )
        else
          ...weather.daily.map((day) => _DailyForecastTile(forecast: day)),
      ],
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final CurrentWeather current;
  final int rainChance;

  const _CurrentWeatherCard({
    required this.current,
    required this.rainChance,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          children: [
            Icon(
              WeatherCodeHelper.icon(current.weatherCode),
              size: 64,
              color: colorScheme.onPrimaryContainer,
            ),
            const SizedBox(height: 12),
            Text(
              '${current.temperature2m.toStringAsFixed(1)}°C',
              style: textTheme.displayLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              WeatherCodeHelper.description(current.weatherCode),
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Terasa seperti ${current.apparentTemperature.toStringAsFixed(1)}°C • Peluang hujan $rainChance%',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;

  const _DailyForecastTile({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          WeatherCodeHelper.icon(forecast.weatherCode),
          color: colorScheme.primary,
        ),
        title: Text(
          forecast.date,
          style: textTheme.titleMedium?.copyWith(fontSize: 15),
        ),
        subtitle: Text(
          '${WeatherCodeHelper.description(forecast.weatherCode)} • Hujan ${forecast.precipitationProbabilityMax}%',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${forecast.temperature2mMin.toStringAsFixed(0)}° / ${forecast.temperature2mMax.toStringAsFixed(0)}°',
          style: textTheme.titleMedium,
        ),
      ),
    );
  }
}
