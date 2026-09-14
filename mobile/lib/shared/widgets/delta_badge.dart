import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small up/down percentage-or-unit pill - shared by the dashboard stat
/// tiles and the employee-detail performance metrics.
class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.value, required this.unit});

  /// The raw signed change (percentage points, %, or minutes).
  final double value;

  /// Appended after the rounded magnitude, e.g. "%" or " min".
  final String unit;

  @override
  Widget build(BuildContext context) {
    final isUp = value >= 0;
    final magnitude = unit == '%' ? value.abs().toStringAsFixed(1) : value.abs().round().toString();
    final color = isUp ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(100)),
      child: Text(
        '${isUp ? '▲' : '▼'} $magnitude$unit',
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}
