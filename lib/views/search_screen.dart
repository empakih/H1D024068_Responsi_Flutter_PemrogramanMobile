import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/location_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';

/// Screen for searching cities via Open-Meteo Geocoding API and managing
/// persisted favorite locations.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<LocationViewModel>().search(_controller.text);
  }

  Future<void> _selectLocation(LocationModel location) async {
    final weatherVm = context.read<WeatherViewModel>();
    Navigator.pop(context);
    await weatherVm.selectLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    final locationVm = context.watch<LocationViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                    decoration: InputDecoration(
                      hintText: 'Masukkan nama kota (misal: Bandung)',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _controller.clear();
                                locationVm.search('');
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _performSearch,
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(context, locationVm),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, LocationViewModel vm) {
    if (vm.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.searchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(vm.searchError!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (vm.hasSearched) {
      if (vm.searchResults.isEmpty) {
        return const Center(
          child: Text('Kota tidak ditemukan. Coba kata kunci lain.'),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vm.searchResults.length,
        itemBuilder: (context, index) {
          final loc = vm.searchResults[index];
          return _LocationTile(
            location: loc,
            isFavorite: vm.isFavorite(loc),
            onTap: () => _selectLocation(loc),
            onToggleFavorite: () => vm.toggleFavorite(loc),
          );
        },
      );
    }

    // Show saved favorite locations when not actively viewing search results.
    if (vm.favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Belum ada lokasi favorit.\nCari kota di atas lalu tekan ikon bintang untuk menyimpannya.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Lokasi Favorit',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...vm.favorites.map(
          (loc) => _LocationTile(
            location: loc,
            isFavorite: true,
            onTap: () => _selectLocation(loc),
            onToggleFavorite: () => vm.toggleFavorite(loc),
          ),
        ),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.location_on_outlined),
        title: Text(location.name),
        subtitle: location.subtitle.isNotEmpty ? Text(location.subtitle) : null,
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFavorite ? Colors.amber : null,
          ),
          onPressed: onToggleFavorite,
        ),
        onTap: onTap,
      ),
    );
  }
}
