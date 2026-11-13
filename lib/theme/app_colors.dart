import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF174D3A);
  static const Color secondary = Color(0xFF75A88A);
  static const Color lightGreenBg = Color(0xFFEAF1EB);

  // Backgrounds
  static const Color pageBg = Color(0xFFF8F8F5);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF202522);
  static const Color textSecondary = Color(0xFF858B86);

  // Divider
  static const Color divider = Color(0xFFE8EBE6);

  // Status
  static const Color warmOrange = Color(0xFFE5A85B);
  static const Color error = Color(0xFFC65B52);

  // Translucent
  static Color whiteOverlay = Colors.white.withValues(alpha: 0.85);
  static Color blackOverlay = Colors.black.withValues(alpha: 0.45);
}
