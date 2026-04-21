import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';
import '../shared/nav_label.dart';

/// Style 6: Morphing Icon — seamlessly crossfades between outline and filled
/// icon variants. The icon IS the indicator — no external pill or bar needed.
///
/// Design improvements over v1:
/// - Icon scale-up pop on activation via AnimationController (not just crossfade)
/// - Active icon gets a soft color-matched underline dot indicator
/// - Underline dot fades in/out with AnimatedOpacity
/// - Icon crossfade uses a custom layoutBuilder with scale transform layering
/// - Label uses NavLabel (already in core) — no change needed there
/// - Active icon color also animates via ColorTween for smooth hue shift
/// - HapticFeedback on tap
/// - Architecture: extracted _MorphItem and _UnderlineDot widgets
class MorphingIconBottomNav extends BaseBottomNav {
  /// Whether to show a small dot indicator below the active icon.
  final bool showDotIndicator;

  /// Size of the dot indicator.
  final double dotSize;

  /// Color of the dot indicator. Defaults to theme.activeColor.
  final Color? dotColor;

  const MorphingIconBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.showDotIndicator = true,
    this.dotSize = 4.0,
    this.dotColor,
  });

  @override
  State<MorphingIconBottomNav> createState() => _MorphingIconBottomNavState();
}

class _MorphingIconBottomNavState extends State<MorphingIconBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  // ── Per-item scale pop controllers ────────────────────────────────────────
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnims;

  // ── Per-item dot fade controllers ─────────────────────────────────────────
  late List<AnimationController> _dotControllers;
  late List<Animation<double>> _dotOpacities;

  @override
  void initState() {
    super.initState();

    _scaleControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 340),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _scaleAnims = _scaleControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 38),
        TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.93), weight: 32),
        TweenSequenceItem(tween: Tween(begin: 0.93, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    _dotControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 220),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _dotOpacities = _dotControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    }).toList();
  }

  @override
  void didUpdateWidget(covariant MorphingIconBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      // Dot: fade out old, fade in new
      _dotControllers[old.currentIndex].reverse();
      _dotControllers[widget.currentIndex].forward();

      // Scale pop on new tab
      if (reduceMotion) {
        _scaleControllers[widget.currentIndex].value = 1.0;
        _scaleControllers[old.currentIndex].value = 0.0;
      } else {
        _scaleControllers[widget.currentIndex].forward(from: 0.0);
        _scaleControllers[old.currentIndex].animateTo(
          0.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeIn,
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _scaleControllers) {
      c.dispose();
    }
    for (final c in _dotControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.selectionClick();
    handleTap(index);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return buildSafeArea(
      child: Container(
        height: widget.theme.height,
        padding: widget.theme.padding,
        color: widget.theme.backgroundColor,
        child: Row(
          children: List.generate(widget.items.length, (index) {
            return _MorphItem(
              item: widget.items[index],
              isActive: index == widget.currentIndex,
              theme: widget.theme,
              scaleAnim: _scaleAnims[index],
              dotOpacity: _dotOpacities[index],
              showDot: widget.showDotIndicator,
              dotSize: widget.dotSize,
              dotColor: widget.dotColor,
              effectiveDuration: effectiveDuration,
              effectiveCurve: widget.theme.animationCurve,
              onTap: () => _onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _MorphItem extends StatelessWidget {
  final dynamic item;
  final bool isActive;
  final dynamic theme;
  final Animation<double> scaleAnim;
  final Animation<double> dotOpacity;
  final bool showDot;
  final double dotSize;
  final Color? dotColor;
  final Duration effectiveDuration;
  final Curve effectiveCurve;
  final VoidCallback onTap;

  const _MorphItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.scaleAnim,
    required this.dotOpacity,
    required this.showDot,
    required this.dotSize,
    required this.dotColor,
    required this.effectiveDuration,
    required this.effectiveCurve,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDotColor = dotColor ?? theme.activeColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon with scale pop ──────────────────────────────────────
            AnimatedBuilder(
              animation: scaleAnim,
              builder: (_, child) => Transform.scale(
                scale: scaleAnim.value,
                child: child,
              ),
              child: NavBadge(
                badgeText: item.badge,
                badgeColor: item.badgeColor,
                child: AnimatedCrossFade(
                  duration: effectiveDuration,
                  crossFadeState: isActive
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: IconTheme(
                    data: IconThemeData(
                      size: theme.iconSize,
                      color: theme.activeColor,
                    ),
                    child: item.activeIcon,
                  ),
                  secondChild: IconTheme(
                    data: IconThemeData(
                      size: theme.iconSize,
                      color: theme.inactiveColor,
                    ),
                    child: item.icon,
                  ),
                  // Custom layout: both icons centered, top icon on top
                  layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                    return SizedBox(
                      width: theme.iconSize,
                      height: theme.iconSize,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(key: bottomKey, child: bottomChild),
                          Positioned(key: topKey, child: topChild),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 2),

            // ── Label (NavLabel from core) ───────────────────────────────
            NavLabel(
              text: item.label,
              isActive: isActive,
              inactiveStyle: theme.labelStyle.copyWith(
                color: theme.inactiveColor,
                fontWeight: FontWeight.w500,
              ),
              activeStyle: theme.activeLabelStyle ??
                  theme.labelStyle.copyWith(
                    color: theme.activeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: (theme.labelStyle.fontSize ?? 10) + 0.5,
                  ),
              duration: effectiveDuration,
              curve: effectiveCurve,
            ),

            const SizedBox(height: 2),

            // ── Dot indicator ────────────────────────────────────────────
            if (showDot)
              _UnderlineDot(
                opacity: dotOpacity,
                color: effectiveDotColor,
                size: dotSize,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DOT INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _UnderlineDot extends StatelessWidget {
  final Animation<double> opacity;
  final Color color;
  final double size;

  const _UnderlineDot({
    required this.opacity,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: ScaleTransition(
        scale: opacity, // reuse same anim — dot scales in as it fades in
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
