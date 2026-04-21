import 'package:flutter/material.dart';
import 'package:bottom_navigation_bar_kit/bottom_navigation_bar_kit.dart';

class DemoScreen extends StatefulWidget {
  final String title;
  final int styleIndex;

  const DemoScreen({super.key, required this.title, required this.styleIndex});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _currentIndex = 0;

  final List<BottomNavItem> _items = const [
    BottomNavItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavItem(
      icon: Icon(Icons.search_outlined),
      activeIcon: Icon(Icons.search),
      label: 'Search',
    ),
    BottomNavItem(
      icon: Icon(Icons.notifications_outlined),
      activeIcon: Icon(Icons.notifications),
      label: 'Alerts',
      badge: '3',
      badgeColor: Colors.redAccent,
    ),
    BottomNavItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  Widget _buildNavBar() {
    switch (widget.styleIndex) {
      case 1:
        return SlidingPillBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          pillColor: Colors.blue.shade50,
          pillBorderRadius: BorderRadius.circular(24),
        );
      case 2:
        return UnderlineWormBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          theme: NavTheme.material3(),
        );
      case 3:
        return BubblePopBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        );
      case 4:
        return TopBarSweepBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        );
      case 5:
        return InkDropBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        );
      case 6:
        return MorphingIconBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        );
      case 7:
        return FloatingDotBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        );
      case 8:
        return GradientSpotlightBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          theme: NavTheme.dark(),
        );
      case 9:
        return SqueezeStretchBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        );
      case 10:
        return NeonPulseBottomNav(
          items: _items,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          neonColors: const [
            Colors.cyanAccent,
            Colors.purpleAccent,
            Colors.pinkAccent,
            Colors.greenAccent,
          ],
          theme: NavTheme.dark(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.styleIndex == 8 || widget.styleIndex == 10;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: Center(
        child: Text(
          'Selected Tab: ${_items[_currentIndex].label}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }
}
