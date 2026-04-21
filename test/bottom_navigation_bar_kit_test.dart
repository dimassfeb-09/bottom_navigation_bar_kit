import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navigation_bar_kit/bottom_navigation_bar_kit.dart';

void main() {
  group('bottom_navigation_bar_kit models test', () {
    test('BottomNavItem initializes correctly', () {
      const item = BottomNavItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
        badge: '3',
        badgeColor: Colors.red,
      );

      expect(item.label, 'Home');
      expect(item.badge, '3');
      expect(item.badgeColor, Colors.red);
    });

    test('NavTheme factories create correct default colors', () {
      final darkTheme = NavTheme.dark();
      expect(darkTheme.activeColor, Colors.tealAccent);
      expect(darkTheme.height, 64.0);

      final material3Theme = NavTheme.material3();
      expect(material3Theme.backgroundColor, const Color(0xFFF3EDF7));
      expect(material3Theme.height, 80.0);
    });

    test('NavTheme copyWith works', () {
      const theme = NavTheme();
      final overridden = theme.copyWith(height: 100.0, activeColor: Colors.red);

      expect(overridden.height, 100.0);
      expect(overridden.activeColor, Colors.red);
      expect(overridden.backgroundColor, Colors.white); // untouched
    });
  });
}
