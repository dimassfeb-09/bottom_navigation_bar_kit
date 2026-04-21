import 'package:flutter/widgets.dart';
import 'bottom_nav_item.dart';
import 'nav_theme.dart';

/// Abstract base class for all bottom navigation styles in this kit.
abstract class BaseBottomNav extends StatefulWidget {
  /// The list of items to display.
  final List<BottomNavItem> items;

  /// The currently active index.
  final int currentIndex;

  /// Called when an item is tapped.
  final ValueChanged<int> onTap;

  /// The theme containing color, layout, and animation properties.
  final NavTheme theme;

  const BaseBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.theme = const NavTheme(),
  });
}

/// A mixin providing common utilities for [BaseBottomNav] implementations.
mixin BaseBottomNavStateMixin<T extends BaseBottomNav> on State<T> {
  /// True if the system requests reduced motion for accessibility.
  bool get reduceMotion => MediaQuery.of(context).disableAnimations;

  /// Returns the effective duration, skipping animations if [reduceMotion] is true.
  Duration get effectiveDuration =>
      reduceMotion ? Duration.zero : widget.theme.animationDuration;

  /// Handles tapping an item, ensuring the callback is only triggered if changing index.
  void handleTap(int index) {
    if (index != widget.currentIndex) {
      widget.onTap(index);
    }
  }

  /// Helper to wrap the navigation bar with proper safe area padding at the bottom.
  Widget buildSafeArea({required Widget child}) {
    return ClipRect(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: child,
      ),
    );
  }
}
