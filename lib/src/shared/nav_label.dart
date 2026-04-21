import 'package:flutter/material.dart';

/// A shared animated label widget that transitions between active and inactive styles.
class NavLabel extends StatelessWidget {
  final String text;
  final bool isActive;
  final TextStyle inactiveStyle;
  final TextStyle? activeStyle;
  final Duration duration;
  final Curve curve;

  const NavLabel({
    super.key,
    required this.text,
    required this.isActive,
    required this.inactiveStyle,
    this.activeStyle,
    required this.duration,
    required this.curve,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: duration,
      curve: curve,
      style: isActive
          ? (activeStyle ??
              inactiveStyle.copyWith(fontWeight: FontWeight.bold))
          : inactiveStyle,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
