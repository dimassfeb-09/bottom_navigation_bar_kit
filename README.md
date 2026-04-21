# bottom_navigation_bar_kit

[![pub.dev](https://img.shields.io/pub/v/bottom_navigation_bar_kit.svg)](https://pub.dev/packages/bottom_navigation_bar_kit)
[![GitHub Stars](https://img.shields.io/github/stars/dimassfeb-09/bottom_navigation_bar_kit?style=social)](https://github.com/dimassfeb-09/bottom_navigation_bar_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A highly customizable Flutter bottom navigation bar package featuring **10 premium animation styles**, built-in light/dark mode, Material 3 & Cupertino presets, accessibility support, and zero external dependencies.

---

### Support the Project ☕

If you find this library helpful and want to support its development, you can buy me a coffee!

[![Support Me on Ko-fi](https://img.shields.io/badge/Support%20Me%20on%20Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/dimassfeb)

> **Enjoying this library?** Please consider giving it a ⭐ on [GitHub](https://github.com/dimassfeb-09/bottom_navigation_bar_kit) to help it grow!

---

## Visual Showcase

| Sliding Pill | Underline Worm |
|:---:|:---:|
| ![Sliding Pill](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/sliding_pill.gif) | ![Underline Worm](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/underline_worm.gif) |
| **Bubble Pop** | **Top Bar Sweep** |
| ![Bubble Pop](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/bubble_pop.gif) | ![Top Bar Sweep](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/top_bar_sweep.gif) |
| **Ink Drop** | **Morphing Icon** |
| ![Ink Drop](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/ink_drop.gif) | ![Morphing Icon](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/morphing_icon.gif) |
| **Floating Dot** | **Gradient Spotlight** |
| ![Floating Dot](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/floating_dot_trail.gif) | ![Gradient Spotlight](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/gradient_spotlight.gif) |
| **Squeeze & Stretch** | **Neon Pulse** |
| ![Squeeze & Stretch](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/squeeze_stretch.gif) | ![Neon Pulse](https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/neon_pulse.gif) |

---

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Quick Example](#quick-example)
- [All 10 Styles](#all-10-styles)
  - [Style 1 — Sliding Pill](#style-1--sliding-pill)
  - [Style 2 — Underline Worm](#style-2--underline-worm)
  - [Style 3 — Bubble Pop](#style-3--bubble-pop)
  - [Style 4 — Top Bar Sweep](#style-4--top-bar-sweep)
  - [Style 5 — Ink Drop](#style-5--ink-drop)
  - [Style 6 — Morphing Icon](#style-6--morphing-icon)
  - [Style 7 — Floating Dot](#style-7--floating-dot)
  - [Style 8 — Gradient Spotlight](#style-8--gradient-spotlight)
  - [Style 9 — Squeeze & Stretch](#style-9--squeeze--stretch)
  - [Style 10 — Neon Pulse](#style-10--neon-pulse)
- [Core API](#core-api)
  - [BottomNavItem](#bottomnavitem)
  - [NavTheme](#navtheme)
  - [BubbleNavTheme](#bubblenavtheme)
- [Theming & Customization](#theming--customization)
- [Accessibility](#accessibility)
- [License](#license)

---

## Features

- ✅ **10 unique animation styles** — all production-ready
- ✅ **Zero external dependencies** — pure Flutter SDK
- ✅ **Light & Dark mode** — automatic or manual
- ✅ **Material 3 & Cupertino** preset themes
- ✅ **Badge support** — text badges with custom colors
- ✅ **Accessibility** — respects `Reduce Motion` system setting
- ✅ **Safe Area aware** — correct bottom padding on all devices
- ✅ **Haptic feedback** — subtle, tasteful touch feedback
- ✅ **3–5 items** — flexible item count
- ✅ **Customizable** — colors, sizes, curves, durations, and more

---

## Getting Started

Add to your `pubspec.yaml`:

```yaml
dependencies:
  bottom_navigation_bar_kit: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Import the package:

```dart
import 'package:bottom_navigation_bar_kit/bottom_navigation_bar_kit.dart';
```

---

## Quick Example

```dart
import 'package:flutter/material.dart';
import 'package:bottom_navigation_bar_kit/bottom_navigation_bar_kit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Content')),
      bottomNavigationBar: SlidingPillBottomNav(
        items: _items,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
```

---

## All 10 Styles

---

### Style 1 — Sliding Pill

A smooth pill-shaped background slides horizontally to the active tab.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/sliding_pill.gif" width="320" alt="Sliding Pill">
</p>

```dart
SlidingPillBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  pillColor: Colors.blue.shade50,
  pillBorderRadius: BorderRadius.circular(24),
  activeIconColor: Colors.blue,
  inactiveIconColor: Colors.grey,
  theme: const NavTheme(
    height: 64,
    backgroundColor: Colors.white,
    activeColor: Colors.blue,
    inactiveColor: Colors.grey,
  ),
)
```

**Parameters:**

| Parameter           | Type                    | Default               | Description                   |
| ------------------- | ----------------------- | --------------------- | ----------------------------- |
| `items`             | `List<BottomNavItem>`   | _required_            | Navigation items              |
| `currentIndex`      | `int`                   | _required_            | Active tab index              |
| `onTap`             | `ValueChanged<int>`     | _required_            | Tap callback                  |
| `pillColor`         | `Color?`                | `activeColor @ 15%`   | Background color of the pill  |
| `pillBorderRadius`  | `BorderRadiusGeometry?` | `circular(24)`        | Corner radius of the pill     |
| `activeIconColor`   | `Color?`                | `theme.activeColor`   | Icon color for active state   |
| `inactiveIconColor` | `Color?`                | `theme.inactiveColor` | Icon color for inactive state |
| `theme`             | `NavTheme`              | `NavTheme()`          | Full theme override           |

---

### Style 2 — Underline Worm

An elastic underline bar stretches and snaps between tabs with a leading/trailing stagger for an organic "worm" feel. Includes a pill highlight and icon bounce on activation.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/underline_worm.gif" width="320" alt="Underline Worm">
</p>

```dart
UnderlineWormBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  wormColor: Colors.deepPurple,
  wormHeight: 3.0,
  wormBorderRadius: 8.0,
  elasticity: 0.35,
  showActivePill: true,
  pillHeight: 30.0,
  theme: NavTheme.light(),
)
```

**Parameters:**

| Parameter          | Type     | Default             | Description                            |
| ------------------ | -------- | ------------------- | -------------------------------------- |
| `wormColor`        | `Color?` | `theme.activeColor` | Color of the worm indicator            |
| `wormHeight`       | `double` | `3.0`               | Thickness of the worm bar              |
| `wormBorderRadius` | `double` | `8.0`               | Corner radius of the worm bar          |
| `elasticity`       | `double` | `0.35`              | Stretch delay between edges (0.0–0.5)  |
| `showActivePill`   | `bool`   | `true`              | Show pill highlight behind active icon |
| `pillHeight`       | `double` | `30.0`              | Height of the active pill              |

---

### Style 3 — Bubble Pop

A circular soft-tinted bubble expands behind the active icon with a satisfying bounce animation. Fully self-contained with `BubbleNavTheme`.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/bubble_pop.gif" width="320" alt="Bubble Pop">
</p>

```dart
BubblePopBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  bubbleSize: 42.0,
  showLabels: true,
  theme: BubbleNavTheme.light(seed: Colors.indigo),
)
```

**With a dark theme:**

```dart
BubblePopBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  theme: BubbleNavTheme.dark(seed: Colors.tealAccent),
)
```

**Parameters:**

| Parameter    | Type              | Default                  | Description                                               |
| ------------ | ----------------- | ------------------------ | --------------------------------------------------------- |
| `bubbleSize` | `double`          | `42.0`                   | Diameter of the bubble circle                             |
| `showLabels` | `bool`            | `true`                   | Show/hide text labels                                     |
| `theme`      | `BubbleNavTheme?` | `BubbleNavTheme.light()` | Specialized theme (see [BubbleNavTheme](#bubblenavtheme)) |

> **Note:** `BubblePopBottomNav` uses its own `BubbleNavTheme` instead of `NavTheme`.

---

### Style 4 — Top Bar Sweep

A bold indicator bar at the very top edge of the nav sweeps with an elastic overshoot to the selected tab. Supports a full-height column tint and icon scale pop.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/top_bar_sweep.gif" width="320" alt="Top Bar Sweep">
</p>

```dart
TopBarSweepBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  barColor: Colors.deepOrange,
  barHeight: 3.0,
  barWidthFactor: 0.55,
  overshootFactor: 0.6,
  showColumnTint: true,
  showTopDivider: true,
  theme: NavTheme.light(),
)
```

**Parameters:**

| Parameter         | Type     | Default             | Description                                     |
| ----------------- | -------- | ------------------- | ----------------------------------------------- |
| `barColor`        | `Color?` | `theme.activeColor` | Color of the sweep bar                          |
| `barHeight`       | `double` | `3.0`               | Thickness of the top indicator bar              |
| `barWidthFactor`  | `double` | `0.55`              | Width of bar as fraction of tab width (0.0–1.0) |
| `overshootFactor` | `double` | `0.6`               | ElasticOut tension (higher = more bounce)       |
| `showColumnTint`  | `bool`   | `true`              | Subtle tint column behind active tab            |
| `showTopDivider`  | `bool`   | `true`              | Hairline divider at top of nav bar              |

---

### Style 5 — Ink Drop

A radial ripple expands from the tapped icon and fades out, leaving a persistent ambient glow behind the active tab.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/ink_drop.gif" width="320" alt="Ink Drop">
</p>

```dart
InkDropBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  rippleColor: Colors.cyan,
  rippleOpacity: 0.22,
  rippleDuration: const Duration(milliseconds: 480),
  showAmbientGlow: true,
  rippleSizeFactor: 1.1,
  theme: NavTheme.dark(),
)
```

**Parameters:**

| Parameter          | Type        | Default             | Description                               |
| ------------------ | ----------- | ------------------- | ----------------------------------------- |
| `rippleColor`      | `Color?`    | `theme.activeColor` | Color of the ripple and glow              |
| `rippleOpacity`    | `double`    | `0.22`              | Peak opacity of the expanding ripple      |
| `rippleDuration`   | `Duration?` | `480ms`             | Duration of ripple expand + fade          |
| `showAmbientGlow`  | `bool`      | `true`              | Persistent soft glow behind active icon   |
| `rippleSizeFactor` | `double`    | `1.1`               | Ripple circle size relative to nav height |

---

### Style 6 — Morphing Icon

Seamlessly crossfades between outline and filled icon variants. The icon IS the indicator — no external pill or bar. Features a dot indicator below the active tab.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/morphing_icon.gif" width="320" alt="Morphing Icon">
</p>

```dart
MorphingIconBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  showDotIndicator: true,
  dotSize: 4.0,
  dotColor: Colors.blue,
  theme: NavTheme.light(),
)
```

**Parameters:**

| Parameter          | Type     | Default             | Description                           |
| ------------------ | -------- | ------------------- | ------------------------------------- |
| `showDotIndicator` | `bool`   | `true`              | Small dot indicator below active icon |
| `dotSize`          | `double` | `4.0`               | Diameter of the dot indicator         |
| `dotColor`         | `Color?` | `theme.activeColor` | Color of the dot indicator            |

---

### Style 7 — Floating Dot

A dot arcs through the air in a parabolic trajectory from the previous tab to the newly selected one. The dot squishes and stretches at arc peak, and the icon bounces when the dot lands.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/floating_dot_trail.gif" width="320" alt="Floating Dot">
</p>

```dart
FloatingDotBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  dotColor: Colors.amber,
  dotSize: 7.0,
  arcHeight: 18.0,
  showGlow: true,
  theme: NavTheme.light(),
)
```

**Parameters:**

| Parameter   | Type     | Default             | Description                      |
| ----------- | -------- | ------------------- | -------------------------------- |
| `dotColor`  | `Color?` | `theme.activeColor` | Color of the traveling dot       |
| `dotSize`   | `double` | `7.0`               | Base size of the dot at rest     |
| `arcHeight` | `double` | `18.0`              | Height of the parabolic arc (px) |
| `showGlow`  | `bool`   | `true`              | Glow effect at arc peak          |

---

### Style 8 — Gradient Spotlight

A radial gradient spotlight shifts smoothly behind the active tab, creating a "lit from below" atmosphere. Built with a `CustomPainter` for smooth, GPU-efficient animation.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/gradient_spotlight.gif" width="320" alt="Gradient Spotlight">
</p>

```dart
GradientSpotlightBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  gradientColors: [
    Colors.tealAccent.withOpacity(0.25),
    Colors.transparent,
  ],
  spotlightRadius: 0.55,
  showEcho: true,
  theme: NavTheme.dark(),
)
```

**Parameters:**

| Parameter         | Type           | Default                            | Description                                           |
| ----------------- | -------------- | ---------------------------------- | ----------------------------------------------------- |
| `gradientColors`  | `List<Color>?` | `[activeColor @ 22%, transparent]` | Two gradient colors: center/bright → edge/transparent |
| `spotlightRadius` | `double`       | `0.55`                             | Radius as a fraction of nav width (0.0–1.5)           |
| `showEcho`        | `bool`         | `true`                             | Dimmer spotlight echo for depth                       |

---

### Style 9 — Squeeze & Stretch

A bottom indicator bar dynamically squeezes narrow then stretches wide when a new tab is selected, with an elastic curve for a satisfying micro-interaction.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/squeeze_stretch.gif" width="320" alt="Squeeze & Stretch">
</p>

```dart
SqueezeStretchBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // Optional customization:
  indicatorColor: Colors.green,
  squeezeWidth: 20.0,
  stretchWidth: 60.0,
  indicatorHeight: 3.0,
  animationCurve: Curves.easeInOutBack,
  theme: NavTheme.light(),
)
```

**Parameters:**

| Parameter         | Type     | Default             | Description                           |
| ----------------- | -------- | ------------------- | ------------------------------------- |
| `indicatorColor`  | `Color?` | `theme.activeColor` | Color of the indicator bar            |
| `squeezeWidth`    | `double` | `20.0`              | Width at the squeeze (narrow) phase   |
| `stretchWidth`    | `double` | `60.0`              | Width at the stretch (wide) phase     |
| `indicatorHeight` | `double` | `3.0`               | Height of the indicator               |
| `animationCurve`  | `Curve?` | `easeInOutBack`     | Curve controlling the animation shape |

---

### Style 10 — Neon Pulse

A pulsing neon glow effect radiates behind the active tab icon. Each tab gets its own neon color. Best used with dark backgrounds.

<p align="center">
  <img src="https://raw.githubusercontent.com/dimassfeb-09/bottom_navigation_bar_kit/main/assets/gifs/neon_pulse.gif" width="320" alt="Neon Pulse">
</p>

```dart
NeonPulseBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  neonColors: const [
    Colors.cyanAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.greenAccent,
  ],
  pulseSpeed: const Duration(milliseconds: 800),
  glowSpread: 12.0,
  backgroundColor: const Color(0xFF0D0D0D),
  theme: NavTheme.dark(),
)
```

**Parameters:**

| Parameter         | Type           | Default             | Description                                      |
| ----------------- | -------------- | ------------------- | ------------------------------------------------ |
| `neonColors`      | `List<Color>?` | `theme.activeColor` | Per-tab neon colors (cycles if fewer than items) |
| `pulseSpeed`      | `Duration`     | `800ms`             | Speed of the pulsing glow animation              |
| `glowSpread`      | `double`       | `12.0`              | Base spread radius of the glow                   |
| `backgroundColor` | `Color`        | `Color(0xFF0D0D0D)` | Nav bar background (recommend dark)              |

---

## Core API

### BottomNavItem

Represents a single navigation tab item.

```dart
const BottomNavItem({
  required Widget icon,        // Inactive icon widget
  required Widget activeIcon,  // Active (filled) icon widget
  required String label,       // Text label
  String? badge,               // Badge text (e.g. "3", "NEW")
  Color? badgeColor,           // Badge background color
})
```

**Example:**

```dart
const BottomNavItem(
  icon: Icon(Icons.home_outlined),
  activeIcon: Icon(Icons.home),
  label: 'Home',
  badge: '5',
  badgeColor: Colors.redAccent,
)
```

---

### NavTheme

The primary theme class used by all styles except `BubblePopBottomNav`.

```dart
const NavTheme({
  Color backgroundColor,      // Bar background color
  Color activeColor,          // Active icon/indicator color
  Color inactiveColor,        // Inactive icon/label color
  TextStyle labelStyle,       // Base label style
  TextStyle? activeLabelStyle, // Active label style override
  double height,              // Bar height in logical pixels
  EdgeInsets padding,         // Internal padding
  double iconSize,            // Icon size
  Duration animationDuration, // Animation duration
  Curve animationCurve,       // Animation curve
})
```

**Factory presets:**

```dart
// Light mode
NavTheme.light(backgroundColor, activeColor, inactiveColor)

// Dark mode
NavTheme.dark(backgroundColor, activeColor, inactiveColor, height, iconSize, animationDuration)

// Material 3
NavTheme.material3()

// iOS/Cupertino
NavTheme.cupertino()
```

**Defaults table:**

| Property            | Default                                            |
| ------------------- | -------------------------------------------------- |
| `backgroundColor`   | `Colors.white`                                     |
| `activeColor`       | `Colors.blue`                                      |
| `inactiveColor`     | `Colors.grey`                                      |
| `height`            | `64.0`                                             |
| `iconSize`          | `24.0`                                             |
| `animationDuration` | `300ms`                                            |
| `animationCurve`    | `Curves.easeInOut`                                 |
| `labelStyle`        | `TextStyle(fontSize: 12)`                          |
| `padding`           | `EdgeInsets.symmetric(horizontal: 8, vertical: 8)` |

---

### BubbleNavTheme

A specialized theme for `BubblePopBottomNav` with additional bubble-specific properties.

```dart
const BubbleNavTheme({
  required Color backgroundColor,
  required Color activeColor,
  required Color inactiveColor,
  required Color bubbleColor,   // Tint color of the bubble circle
  double height,                // Bar height (default: 72.0)
  double iconSize,              // Icon size (default: 24.0)
  TextStyle labelStyle,         // Label text style
  Duration animationDuration,   // Animation duration (default: 320ms)
  BorderRadius? containerRadius, // Corner radius of the nav bar container
  List<BoxShadow>? shadows,     // Shadow(s) on the nav bar container
})
```

**Factory presets:**

```dart
// Light with optional seed color
BubbleNavTheme.light(Color? seed)

// Dark with optional seed color
BubbleNavTheme.dark(Color? seed)
```

**Example with full customization:**

```dart
BubblePopBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  theme: BubbleNavTheme(
    backgroundColor: Colors.white,
    activeColor: Colors.indigo,
    inactiveColor: Colors.grey.shade400,
    bubbleColor: Colors.indigo.withOpacity(0.12),
    height: 72,
    containerRadius: BorderRadius.circular(20),
    shadows: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 20,
        offset: Offset(0, -4),
      ),
    ],
  ),
)
```

---

## Theming & Customization

### Dark Mode

All styles support dark mode either automatically (via `Theme.of(context).brightness`) or manually:

```dart
// Manual dark theme for any style
SlidingPillBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  theme: NavTheme.dark(
    activeColor: Colors.tealAccent,
  ),
)

// Bubble Pop auto-detects dark mode via Theme
BubblePopBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  // No theme needed — auto-detects from Theme.of(context).brightness
)
```

### Custom Animation Speed

```dart
SlidingPillBottomNav(
  items: _items,
  currentIndex: _currentIndex,
  onTap: (i) => setState(() => _currentIndex = i),
  theme: const NavTheme(
    animationDuration: Duration(milliseconds: 500),
    animationCurve: Curves.elasticOut,
  ),
)
```

### Integrate with PageView

```dart
class _MyState extends State<MyPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        children: const [/* pages */],
      ),
      bottomNavigationBar: SlidingPillBottomNav(
        items: _items,
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          _pageController.jumpToPage(i);
        },
      ),
    );
  }
}
```

---

## Accessibility

The kit fully respects the system's **Reduce Motion** accessibility setting:

- All animations are **skipped** (instant snap) when the user has enabled "Reduce Motion" in system settings.
- This is handled automatically in every style via the `BaseBottomNavStateMixin.reduceMotion` getter — no additional setup required.
- Badge text is rendered as plain `Text` widgets, compatible with screen readers.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
