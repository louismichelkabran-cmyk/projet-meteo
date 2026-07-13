import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  /// Récupère la météo d'une ville par son nom
  Future<Weather> getWeatherByCity(String cityName) async {
    // Étape 1 : convertir le nom de la ville en coordonnées (latitude/longitude)
    final geoUrl = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(cityName)}&count=1&language=fr',
    );
    final geoResponse = await http.get(geoUrl);

    if (geoResponse.statusCode != 200) {
      throw Exception('Erreur lors de la recherche de la ville');
    }

    final geoData = jsonDecode(geoResponse.body);
    if (geoData['results'] == null || geoData['results'].isEmpty) {
      throw Exception('Ville introuvable : $cityName');
    }

    final lat = geoData['results'][0]['latitude'];
    final lon = geoData['results'][0]['longitude'];

    // Étape 2 : récupérer la météo avec ces coordonnées
    // On ajoute relative_humidity_2m pour afficher l'humidité
    final weatherUrl = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m',
    );
    final weatherResponse = await http.get(weatherUrl);

    if (weatherResponse.statusCode != 200) {
      throw Exception('Erreur lors de la récupération de la météo');
    }

    final weatherData = jsonDecode(weatherResponse.body);
    return Weather.fromJson(weatherData);
  }
}