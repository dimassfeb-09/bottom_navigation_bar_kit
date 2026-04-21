import 'package:flutter/material.dart';

/// Defines the visual styling for the bottom navigation bar styles.
class NavTheme {
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final TextStyle labelStyle;
  final TextStyle? activeLabelStyle;
  final double height;
  final EdgeInsets padding;
  final double iconSize;
  final Duration animationDuration;
  final Curve animationCurve;

  const NavTheme({
    this.backgroundColor = Colors.white,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.labelStyle = const TextStyle(fontSize: 12),
    this.activeLabelStyle,
    this.height = 64.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    this.iconSize = 24.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  /// Creates a copy of this [NavTheme] but with the given fields replaced with the new values.
  NavTheme copyWith({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    TextStyle? labelStyle,
    TextStyle? activeLabelStyle,
    double? height,
    EdgeInsets? padding,
    double? iconSize,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return NavTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      labelStyle: labelStyle ?? this.labelStyle,
      activeLabelStyle: activeLabelStyle ?? this.activeLabelStyle,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }

  /// Factory for a standard dark mode theme.
  factory NavTheme.dark({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    double? height,
    double? iconSize,
    Duration? animationDuration,
  }) {
    return NavTheme(
      backgroundColor: backgroundColor ?? const Color(0xFF1E1E1E),
      activeColor: activeColor ?? Colors.tealAccent,
      inactiveColor: inactiveColor ?? Colors.grey.shade600,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.white70),
      height: height ?? 64.0,
      iconSize: iconSize ?? 24.0,
      animationDuration: animationDuration ?? const Duration(milliseconds: 300),
    );
  }

  /// Factory for a standard light mode theme.
  factory NavTheme.light({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
  }) {
    return NavTheme(
      backgroundColor: backgroundColor ?? Colors.white,
      activeColor: activeColor ?? Colors.blue,
      inactiveColor: inactiveColor ?? Colors.black54,
    );
  }

  /// Factory mimicking Material 3 specifications.
  factory NavTheme.material3() {
    return const NavTheme(
      backgroundColor: Color(0xFFF3EDF7), // M3 Surface Container
      activeColor: Color(0xFF1D192B), // M3 On Secondary Container
      inactiveColor: Color(0xFF49454F),
      height: 80.0,
      padding: EdgeInsets.symmetric(horizontal: 0.0),
    );
  }

  /// Factory mimicking standard Cupertino styling.
  factory NavTheme.cupertino() {
    return const NavTheme(
      backgroundColor: Color(0xCCF8F8F8),
      activeColor: Color(0xFF007AFF),
      inactiveColor: Color(0xFF999999),
      height: 50.0,
      labelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
      iconSize: 28.0,
      animationDuration:
          Duration.zero, // Cupertino typically lacks heavy tab animations
    );
  }
}

class BubbleNavTheme {
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final Color bubbleColor;
  final double height;
  final double iconSize;
  final TextStyle labelStyle;
  final Duration animationDuration;
  final BorderRadius? containerRadius;
  final List<BoxShadow>? shadows;

  const BubbleNavTheme({
    required this.backgroundColor,
    required this.activeColor,
    required this.inactiveColor,
    required this.bubbleColor,
    this.height = 72.0,
    this.iconSize = 24.0,
    this.labelStyle = const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    this.animationDuration = const Duration(milliseconds: 320),
    this.containerRadius,
    this.shadows,
  });

  /// Light mode preset
  factory BubbleNavTheme.light({Color? seed}) {
    final active = seed ?? const Color(0xFF5C6BC0);
    return BubbleNavTheme(
      backgroundColor: Colors.white,
      activeColor: active,
      inactiveColor: const Color(0xFFB0B7C3),
      bubbleColor: active.withValues(alpha: 0.12),
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    );
  }

  /// Dark mode preset
  factory BubbleNavTheme.dark({Color? seed}) {
    final active = seed ?? const Color(0xFF9FA8DA);
    return BubbleNavTheme(
      backgroundColor: const Color(0xFF1A1C2A),
      activeColor: active,
      inactiveColor: const Color(0xFF4A5066),
      bubbleColor: active.withValues(alpha: 0.15),
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 24,
          offset: const Offset(0, -6),
        ),
      ],
    );
  }

  BubbleNavTheme copyWith({
    Color? backgroundColor,
    Color? activeColor,
    Color? inactiveColor,
    Color? bubbleColor,
    double? height,
    double? iconSize,
    TextStyle? labelStyle,
    Duration? animationDuration,
    BorderRadius? containerRadius,
    List<BoxShadow>? shadows,
  }) {
    return BubbleNavTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inactiveColor: inactiveColor ?? this.inactiveColor,
      bubbleColor: bubbleColor ?? this.bubbleColor,
      height: height ?? this.height,
      iconSize: iconSize ?? this.iconSize,
      labelStyle: labelStyle ?? this.labelStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      containerRadius: containerRadius ?? this.containerRadius,
      shadows: shadows ?? this.shadows,
    );
  }
}
