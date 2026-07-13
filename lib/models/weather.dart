/// Modèle de données météo (source : Open-Meteo)
class Weather {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;

  Weather({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
  });

  /// Description textuelle du code météo WMO
  String get description {
    if (weatherCode == 0) return 'Ciel dégagé';
    if (weatherCode <= 2) return 'Partiellement nuageux';
    if (weatherCode == 3) return 'Couvert';
    if (weatherCode <= 49) return 'Brouillard';
    if (weatherCode <= 59) return 'Bruine';
    if (weatherCode <= 69) return 'Pluie';
    if (weatherCode <= 79) return 'Neige';
    if (weatherCode <= 84) return 'Averses';
    if (weatherCode <= 94) return 'Orage';
    return 'Orage violent';
  }

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
    );
  }
}