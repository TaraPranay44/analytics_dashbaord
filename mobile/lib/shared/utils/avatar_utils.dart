import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';

/// Mirrors web/src/utils/avatar.ts exactly, so the same person's avatar
/// looks the same on web and mobile.

/// "Maya Chatterjee" -> "MC". Falls back to "?" for an empty name.
String initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
  final initials = parts.map((p) => p[0].toUpperCase()).join();
  return initials.isEmpty ? '?' : initials;
}

/// Deterministic gradient from a stable id/name, so the same person's avatar
/// looks the same everywhere.
List<Color> avatarGradientFor(String seed) {
  var hash = 0;
  for (final codeUnit in seed.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
  }
  return AppColors.avatarGradients[hash % AppColors.avatarGradients.length];
}
