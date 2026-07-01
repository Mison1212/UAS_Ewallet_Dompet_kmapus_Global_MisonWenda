import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF00796B);
  static const Color primaryLight = Color(0xFF16B39B);
  static const Color primaryDark = Color(0xFF004D45);
  static const Color brandInk = Color(0xFF062D2B);
  static const Color mint = Color(0xFF8FE3CF);
  static const Color gold = Color(0xFFE3B341);
  static const Color primarySurface = Color(0xFFE3F6F1);
  static const Color primaryBorder = Color(0xFF9ED8CD);

  // Semantic
  static const Color green = Color(0xFF15996F);
  static const Color greenSurface = Color(0xFFE3F7EE);
  static const Color amber = Color(0xFFD49A20);
  static const Color amberSurface = Color(0xFFFFF5DB);
  static const Color red = Color(0xFFE5484D);
  static const Color redSurface = Color(0xFFFDECED);
  static const Color violet = Color(0xFF5B6EE1);
  static const Color violetSurface = Color(0xFFEEF1FF);
  static const Color cyan = Color(0xFF0E91B7);
  static const Color cyanSurface = Color(0xFFE2F6FB);

  // Neutral
  static const Color ink = Color(0xFF10201E);
  static const Color slate600 = Color(0xFF526662);
  static const Color slate500 = Color(0xFF73817E);
  static const Color slate400 = Color(0xFFA6B0AD);
  static const Color slate300 = Color(0xFFD1D8D5);
  static const Color line = Color(0xFFE3EAE7);
  static const Color line2 = Color(0xFFF0F4F2);
  static const Color bg = Color(0xFFF5F8F6);
  static const Color white = Color(0xFFFFFFFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.52, 1.0],
    colors: [Color(0xFF18B79F), primary, primaryDark],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.58, 1.0],
    colors: [Color(0xFF0D5C54), Color(0xFF063D39), Color(0xFF092421)],
  );

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x1710201E),
      blurRadius: 28,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x0F10201E),
      blurRadius: 18,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x4D00796B),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 12),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [cyanSurface, cyan],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [bg, slate600],
    'teal': [primarySurface, primary],
    'gold': [amberSurface, gold],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['blue']!;
}
