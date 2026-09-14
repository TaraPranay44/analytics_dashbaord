import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'delta_badge.dart';
import 'sparkline_chart.dart';

/// One dashboard header tile (mirrors web/src/components/OrgStatTile.vue and
/// the mobile mockup's `.stat-tile`).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.dotColor,
    this.delta,
    this.deltaUnit,
    this.sparklineValues,
  });

  final String label;
  final String value;
  final Color dotColor;
  final double? delta;
  final String? deltaUnit;
  final List<double>? sparklineValues;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x1417153D), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.ink500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (delta != null) ...[
                const SizedBox(width: 6),
                DeltaBadge(value: delta!, unit: deltaUnit ?? '%'),
              ],
            ],
          ),
          if (sparklineValues != null && sparklineValues!.length > 1) ...[
            const SizedBox(height: 6),
            SparklineChart(values: sparklineValues!, color: dotColor),
          ],
        ],
      ),
    );
  }
}
