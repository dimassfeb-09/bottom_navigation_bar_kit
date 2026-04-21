import 'package:flutter/material.dart';

/// A shared badge widget to display over icons if a badge text is provided.
class NavBadge extends StatelessWidget {
  final Widget child;
  final String? badgeText;
  final Color? badgeColor;

  const NavBadge({
    super.key,
    required this.child,
    this.badgeText,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    if (badgeText == null || badgeText!.isEmpty) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor ?? Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
