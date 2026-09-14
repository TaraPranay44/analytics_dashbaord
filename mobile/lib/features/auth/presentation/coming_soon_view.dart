import 'package:flutter/material.dart';

import '../../../core/constants/string_constants.dart';
import '../../../shared/theme/app_colors.dart';

/// Placeholder for the Manager/Employee dashboards (future scope) - so the
/// login screen can ship all three role entry points now without routing
/// rework later. See docs/06_MOBILE_RULES.md §8.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.roleLabel});

  final String roleLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.space900,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roleLabel.toUpperCase(),
                  style: const TextStyle(color: AppColors.pink500, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1),
                ),
                const SizedBox(height: 14),
                const Text(
                  StringConstants.comingSoonTitle,
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                const Text(
                  StringConstants.comingSoonBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13.5, height: 1.5),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(StringConstants.backToSignIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
