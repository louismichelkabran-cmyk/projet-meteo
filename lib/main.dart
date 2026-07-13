import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/weather_provider.dart';
import 'models/weather.dart';
import 'theme.dart';

/// Villes affichées par défaut au démarrage
const List<String> kDefaultCities = [
  'Paris',
  'Londres',
  'New York',
  'Tokyo',
  'Dubai',
  'Sydney',
  'Moscou',
  'Montreal',
  'Dakar',
  'Alger',
];

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Météo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      home: const WeatherScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Écran principal
// ─────────────────────────────────────────────────────────────────────────────
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _cities = List.from(kDefaultCities);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final city = _controller.text.trim();
    if (city.isEmpty) return;
    setState(() {
      // Déplace la ville en première position (sans doublon)
      _cities.removeWhere((c) => c.toLowerCase() == city.toLowerCase());
      _cities.insert(0, city);
    });
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── En-tête ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 80,
            collapsedHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                'Météo',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),

          // ── Barre de recherche ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _search(),
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher une ville…',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppTheme.searchFill,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Rechercher',
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: _search,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.searchRadius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.searchRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.searchRadius),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Liste des villes ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WeatherCard(cityName: _cities[index]),
                ),
                childCount: _cities.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte météo individuelle
// ─────────────────────────────────────────────────────────────────────────────
class _WeatherCard extends ConsumerWidget {
  final String cityName;

  const _WeatherCard({required this.cityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider(cityName));

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.cardShadow,
      ),
      // AnimatedSwitcher : transition douce (250 ms) entre chargement → données
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: weatherAsync.when(
          loading: () => _LoadingState(key: ValueKey('loading_$cityName')),
          error: (_, __) => _ErrorState(
            key: ValueKey('error_$cityName'),
            cityName: cityName,
          ),
          data: (weather) => _DataState(
            key: ValueKey('data_$cityName'),
            cityName: cityName,
            weather: weather,
          ),
        ),
      ),
    );
  }
}

// ── État : chargement ────────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'Chargement…',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── État : erreur ────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String cityName;

  const _ErrorState({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cityName,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ville introuvable',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── État : données ───────────────────────────────────────────────────────────
class _DataState extends StatelessWidget {
  final String cityName;
  final Weather weather;

  const _DataState({
    super.key,
    required this.cityName,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentForCode(weather.weatherCode);
    final icon   = AppTheme.iconForCode(weather.weatherCode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne principale : icône + nom + température ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cityName,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      weather.description,
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${weather.temperature.toStringAsFixed(1)}°',
                style: GoogleFonts.manrope(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: accent,
                  height: 1,
                ),
              ),
            ],
          ),

          // ── Séparateur ───────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppTheme.divider),
          ),

          // ── Vent et humidité ─────────────────────────────────────────────
          Row(
            children: [
              _MetaItem(
                icon: Icons.air,
                label: '${weather.windSpeed.toStringAsFixed(0)} km/h',
              ),
              const SizedBox(width: 24),
              _MetaItem(
                icon: Icons.water_drop_outlined,
                label: '${weather.humidity} %',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Indicateur vent / humidité ───────────────────────────────────────────────
class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
