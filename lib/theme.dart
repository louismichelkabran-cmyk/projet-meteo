import 'package:flutter/material.dart';

/// Centralise toutes les couleurs, styles et constantes visuelles de l'app.
/// Aucune valeur de style ne doit être codée en dur dans les widgets.
abstract final class AppTheme {
  // ── Couleurs de base ──────────────────────────────────────────────────────
  static const Color background   = Color(0xFFF7F8FA);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color searchFill   = Color(0xFFEEF0F4);
  static const Color divider      = Color(0xFFE5E7EB);

  // ── Géométrie ─────────────────────────────────────────────────────────────
  static const double cardRadius   = 16.0;
  static const double searchRadius = 12.0;

  // ── Ombres ────────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF111827).withValues(alpha: 0.07),
      blurRadius: 14,
      offset: const Offset(0, 2),
    ),
  ];

  // ── Couleur d'accent selon le code météo WMO ──────────────────────────────
  static Color accentForCode(int code) {
    if (code == 0)   return const Color(0xFF2563EB); // Ciel dégagé → bleu vif
    if (code <= 2)   return const Color(0xFF4B9EFF); // Partiellement nuageux → bleu doux
    if (code == 3)   return const Color(0xFF8B9DB5); // Couvert → gris-bleu
    if (code <= 49)  return const Color(0xFF9CA3AF); // Brouillard → gris neutre
    if (code <= 59)  return const Color(0xFF5B8DB8); // Bruine → bleu-gris
    if (code <= 69)  return const Color(0xFF3B82F6); // Pluie → bleu
    if (code <= 79)  return const Color(0xFF7BBFEA); // Neige → bleu clair
    if (code <= 84)  return const Color(0xFF3B82F6); // Averses → bleu
    return const Color(0xFF475569);                   // Orage → ardoise foncée
  }

  // ── Icône Material cohérente selon le code météo ──────────────────────────
  static IconData iconForCode(int code) {
    if (code == 0)  return Icons.wb_sunny;
    if (code <= 2)  return Icons.wb_cloudy;
    if (code == 3)  return Icons.cloud;
    if (code <= 49) return Icons.blur_on;
    if (code <= 59) return Icons.grain;
    if (code <= 69) return Icons.water_drop;
    if (code <= 79) return Icons.ac_unit;
    if (code <= 84) return Icons.water_drop;
    return Icons.bolt;
  }

  // ── ThemeData global ──────────────────────────────────────────────────────
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }
}
