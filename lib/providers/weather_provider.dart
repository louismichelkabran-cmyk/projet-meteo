import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

// Le service, exposé via un provider simple
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

// Un provider "family" : il prend un paramètre (le nom de la ville)
// et retourne un Future<Weather>. Riverpod gère automatiquement
// les états chargement / erreur / données pour nous.
final weatherProvider = FutureProvider.family<Weather, String>((ref, cityName) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getWeatherByCity(cityName);
});