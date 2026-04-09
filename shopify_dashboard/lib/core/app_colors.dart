import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF1E293B);
  static const Color accent = Color(0xFF22C55E);
  static const Color background = Color(0xFF020617);
  static const Color textBody = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color cardBg = Color(0x33FFFFFF); // Semi-transparent for glass effect
  static const Color border = Color(0x33FFFFFF);
  
  // Gradients for vibrancy
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glassGradient = LinearGradient(
    colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
