import 'package:flutter/widgets.dart';

/// Design tokens lifted from the attached mobile mockups
/// (mobile-login/mobile-dashboard/mobile-employee-detail .html `:root` vars).
class AppColors {
  AppColors._();

  static const violet500 = Color(0xFF6C5CE7);
  static const pink500 = Color(0xFFFF5FB8);
  static const amber500 = Color(0xFFFFB020);
  static const teal500 = Color(0xFF00D9B5);
  static const red500 = Color(0xFFF5426C);

  static const space900 = Color(0xFF0B0A17);
  static const space700 = Color(0xFF1E1B3E);

  static const ink900 = Color(0xFF15142B);
  static const ink700 = Color(0xFF3A3856);
  static const ink500 = Color(0xFF6E6C8A);
  static const ink300 = Color(0xFFA7A5C2);

  static const bgPage = Color(0xFFF5F4FC);
  static const bgOuter = Color(0xFFEDEBF8);
  static const border = Color(0xFFE7E5F5);
  static const white = Color(0xFFFFFFFF);

  static const success = Color(0xFF00A187);
  static const danger = Color(0xFFD6285A);

  static const gradientBrand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [violet500, pink500],
  );

  static const avatarGradients = <List<Color>>[
    [Color(0xFF6C5CE7), Color(0xFFFF5FB8)],
    [Color(0xFF00D9B5), Color(0xFF6C5CE7)],
    [Color(0xFFFF7A85), Color(0xFFFFB020)],
    [Color(0xFF8A6BFF), Color(0xFFFF5FB8)],
    [Color(0xFFFFB020), Color(0xFFFF5FB8)],
  ];
}
