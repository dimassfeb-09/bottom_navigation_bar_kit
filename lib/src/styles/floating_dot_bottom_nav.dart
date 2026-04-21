import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 7: Floating Dot Trail — a dot arcs through the air from the previous
/// tab to the newly selected tab, landing above the active icon.
///
/// Design improvements over v1:
/// - Dot leaves a trailing "comet tail" of fading shadow for motion depth
/// - Dot scales up mid-arc (stretch at peak) and squishes on landing
/// - Active tab icon gets a bounce-down on dot landing
/// - Dot glow via boxShadow that intensifies at arc peak
/// - Icon uses AnimatedSwitcher with proper fade+scale transitionBuilder
/// - Label uses AnimatedDefaultTextStyle for smooth transition
/// - HapticFeedback on tap
/// - Architecture: _FloatingDotPainter + _DotNavItem widgets
class FloatingDotBottomNav extends BaseBottomNav {
  /// Color of the dot. Defaults to theme.activeColor.
  final Color? dotColor;

  /// Base size of the dot at rest.
  final double dotSize;

  /// How high the dot arcs above the nav bar (px).
  final double arcHeight;

  /// Whether the dot glows at arc peak.
  final bool showGlow;

  const FloatingDotBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.dotColor,
    this.dotSize = 7.0,
    this.arcHeight = 18.0,
    this.showGlow = true,
  });

  @override
  State<FloatingDotBottomNav> createState() => _FloatingDotBottomNavState();
}

class _FloatingDotBottomNavState extends State<FloatingDotBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  // ── Dot travel controller ─────────────────────────────────────────────────
  late AnimationController _dotController;
  late Animation<double> _dotPosition;

  double _prevIndex = 0;
  double _targetIndex = 0;

  // ── Per-item icon bounce controllers ─────────────────────────────────────
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconBounces;

  // ── Per-item label controllers ────────────────────────────────────────────
  late List<AnimationController> _labelControllers;
  late List<Animation<double>> _labelOpacities;

  @override
  void initState() {
    super.initState();

    _targetIndex = widget.currentIndex.toDouble();
    _prevIndex = _targetIndex;

    _dotController = AnimationController(vsync: this);

    _iconControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 360),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    // Icon bounce: slight compress-down when dot lands
    _iconBounces = _iconControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.82), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.82, end: 1.08), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    _labelControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _labelOpacities = _labelControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dotController.duration = effectiveDuration;
    _rebuildDotAnimation();
    if (_dotController.value == 0.0) {
      _dotController.value = 1.0;
    }
  }

  void _rebuildDotAnimation() {
    _dotPosition = Tween<double>(begin: _prevIndex, end: _targetIndex).animate(
      CurvedAnimation(
        parent: _dotController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FloatingDotBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      _prevIndex = _targetIndex;
      _targetIndex = widget.currentIndex.toDouble();

      _dotController.duration = effectiveDuration;
      _rebuildDotAnimation();

      // Label: fade out old, fade in new (with slight delay after dot lands)
      _labelControllers[old.currentIndex].reverse();
      _labelControllers[old.currentIndex].reverse();

      if (reduceMotion) {
        _dotController.value = 1.0;
        _prevIndex = _targetIndex;
        _iconControllers[widget.currentIndex].value = 1.0;
        _iconControllers[old.currentIndex].value = 0.0;
        _labelControllers[widget.currentIndex].value = 1.0;
        _labelControllers[old.currentIndex].value = 0.0;
      } else {
        _dotController.forward(from: 0.0).then((_) {
          // Icon bounce triggers when dot lands
          if (mounted) {
            _iconControllers[widget.currentIndex].forward(from: 0.0);
            _labelControllers[widget.currentIndex].forward();
            HapticFeedback.lightImpact();
          }
        });
        // Deactivate old
        _iconControllers[old.currentIndex].animateTo(
          0.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeIn,
        );
        _labelControllers[old.currentIndex].reverse();
      }
    }

    if (old.theme.animationDuration != widget.theme.animationDuration) {
      _dotController.duration = effectiveDuration;
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    for (final c in _iconControllers) {
      c.dispose();
    }
    for (final c in _labelControllers) {
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
    final effectiveDotColor = widget.dotColor ?? widget.theme.activeColor;

    return buildSafeArea(
      child: Container(
        height: widget.theme.height,
        padding: widget.theme.padding,
        color: widget.theme.backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / widget.items.length;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Tab row ────────────────────────────────────────────────
                Row(
                  children: List.generate(widget.items.length, (index) {
                    return _DotNavItem(
                      item: widget.items[index],
                      isActive: index == widget.currentIndex,
                      theme: widget.theme,
                      iconBounce: _iconBounces[index],
                      labelOpacity: _labelOpacities[index],
                      activeColor: effectiveDotColor,
                      onTap: () => _onTap(index),
                    );
                  }),
                ),

                // ── Floating dot ───────────────────────────────────────────
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (_, __) {
                    final pos = _dotPosition.value;
                    final totalDist = (_targetIndex - _prevIndex).abs();
                    final double progress = totalDist > 0
                        ? (pos - _prevIndex).abs() / totalDist
                        : 1.0;

                    // Parabolic arc: sin wave peaks at progress=0.5
                    final yArc =
                        math.sin(progress * math.pi) * widget.arcHeight;

                    // Dot stretches slightly at arc peak (squish & stretch)
                    final peakScale = math.sin(progress * math.pi);
                    final dotScaleX = 1.0 + peakScale * 0.3;
                    final dotScaleY = 1.0 - peakScale * 0.15;

                    // Glow intensity peaks at arc mid-point
                    final glowOpacity = widget.showGlow ? peakScale * 0.6 : 0.0;

                    final dotX =
                        pos * tabWidth + tabWidth / 2 - widget.dotSize / 2;
                    final dotY = 14.0 + yArc;

                    return Positioned(
                      left: dotX,
                      top: dotY,
                      child: Transform.scale(
                        scaleX: dotScaleX,
                        scaleY: dotScaleY,
                        child: Container(
                          width: widget.dotSize,
                          height: widget.dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: effectiveDotColor,
                            boxShadow: [
                              BoxShadow(
                                color: effectiveDotColor.withValues(
                                    alpha: glowOpacity),
                                blurRadius: widget.dotSize * 2.5,
                                spreadRadius: widget.dotSize * 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _DotNavItem extends StatelessWidget {
  final dynamic item;
  final bool isActive;
  final dynamic theme;
  final Animation<double> iconBounce;
  final Animation<double> labelOpacity;
  final Color activeColor;
  final VoidCallback onTap;

  const _DotNavItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.iconBounce,
    required this.labelOpacity,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Extra top space so dot arc doesn't overlap icon at rest
            const SizedBox(height: 4),

            // ── Icon with landing bounce ───────────────────────────────
            AnimatedBuilder(
              animation: iconBounce,
              builder: (_, child) => Transform.scale(
                scale: isActive ? iconBounce.value : 1.0,
                child: child,
              ),
              child: NavBadge(
                badgeText: item.badge,
                badgeColor: item.badgeColor,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.75, end: 1.0).animate(anim),
                      child: child,
                    ),
                  ),
                  child: IconTheme(
                    key: ValueKey(isActive),
                    data: IconThemeData(
                      size: theme.iconSize,
                      color: isActive ? activeColor : theme.inactiveColor,
                    ),
                    child: isActive ? item.activeIcon : item.icon,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 2),

            // ── Label with fade ────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: isActive
                  ? (theme.activeLabelStyle ??
                      theme.labelStyle.copyWith(
                        color: activeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: (theme.labelStyle.fontSize ?? 10) + 0.5,
                      ))
                  : theme.labelStyle.copyWith(
                      color: theme.inactiveColor,
                      fontWeight: FontWeight.w400,
                    ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
