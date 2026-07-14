import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(
    // ProviderScope est obligatoire avec Riverpod : il stocke l'état
    // de tous les providers de l'application
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WeatherScreen(),
    );
  }
}

// ConsumerStatefulWidget : comme StatefulWidget, mais qui peut
// "écouter" les providers Riverpod
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  String? _searchedCity;

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _search() {
    // On ferme le clavier virtuel
    FocusScope.of(context).unfocus();

    // trim() : on retire les espaces avant/après pour éviter
    // que "Paris" et "Paris " soient traités comme deux villes différentes
    final city = _cityController.text.trim();

    setState(() {
      _searchedCity = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Météo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Nom de la ville',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _search,
              child: const Text('Rechercher'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _searchedCity == null || _searchedCity!.isEmpty
                  ? const Center(child: Text('Entrez une ville pour commencer'))
                  : _buildWeatherResult(_searchedCity!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherResult(String city) {
    // ref.watch sur un provider .family : on lui passe le paramètre (city)
    final weatherAsync = ref.watch(weatherProvider(city));

    // .when() gère les 3 états automatiquement : chargement, erreur, données
    return weatherAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          'Erreur : $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (weather) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${weather.temperature}°C',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Vent : ${weather.windSpeed} km/h'),
          ],
        ),
      ),
    );
  }
}