import 'package:flutter/material.dart';

import '../utils/avatar_utils.dart';

/// Dumb, reusable initials-on-gradient avatar. Used by every screen that
/// renders a person (employee row, manager chip, direct-report chip, detail header).
class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key, required this.name, required this.seed, this.size = 36, this.fontSize = 11});

  final String name;
  final String seed;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final gradientColors = avatarGradientFor(seed);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Text(
        initialsFor(name),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: fontSize),
      ),
    );
  }
}
