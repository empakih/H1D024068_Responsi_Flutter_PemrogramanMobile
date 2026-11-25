import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/liquid_glass_card.dart';

/// Screen displaying saved favorite locations from Local Storage.
class FavoritesScreen extends StatelessWidget {
  final VoidCallback? onLocationSelected;

  const FavoritesScreen({super.key, this.onLocationSelected});

  Future<void> _selectLocation(
    BuildContext context,
    LocationModel location,
  ) async {
    await context.read<WeatherViewModel>().selectLocation(location);
    onLocationSelected?.call();
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = context.watch<LocationViewModel>();
    final favorites = locationVm.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Favorit'),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada lokasi favorit.\nCari kota di menu Cari lalu tekan ikon bintang untuk menyimpannya.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final loc = favorites[index];
                return LiquidGlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  borderRadius: 16,
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(loc.name),
                    subtitle:
                        loc.subtitle.isNotEmpty ? Text(loc.subtitle) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.star_rounded, color: Colors.amber),
                      onPressed: () => locationVm.toggleFavorite(loc),
                    ),
                    onTap: () => _selectLocation(context, loc),
                  ),
                );
              },
            ),
    );
  }
}
