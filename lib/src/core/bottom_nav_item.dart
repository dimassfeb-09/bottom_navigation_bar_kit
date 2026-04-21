import 'package:flutter/widgets.dart';

/// Represents a single item in the bottom navigation bar.
class BottomNavItem {
  /// The icon to display when the item is strictly inactive.
  final Widget icon;

  /// The icon to display when the item is active.
  final Widget activeIcon;

  /// The text label for the item.
  final String label;

  /// Optional text to display inside a badge (e.g., "3", "NEW").
  final String? badge;

  /// Optional background color for the badge. Overrides the theme's badge color if provided.
  final Color? badgeColor;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
    this.badgeColor,
  });
}
