import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 2: Underline Worm — a thick elastic underline that stretches and
/// snaps between tabs with a leading/trailing stagger for a "worm" feel.
///
/// Design improvements over v1:
/// - Worm now has a gradient fill that follows the active color
/// - Icon has a subtle vertical bounce on activation
/// - Label uses AnimatedDefaultTextStyle for smooth weight/color transition
/// - Active icon gets a soft color-matched tint background (pill, not bubble)
/// - HapticFeedback on tap
/// - Clean self-contained theme with light/dark factory presets
class UnderlineWormBottomNav extends BaseBottomNav {
  /// Color of the worm indicator. Defaults to theme.activeColor.
  final Color? wormColor;

  /// Thickness of the worm bar.
  final double wormHeight;

  /// Corner radius of the worm bar.
  final double wormBorderRadius;

  /// Controls the stretch delay between leading and trailing edge (0.0–0.5).
  final double elasticity;

  /// Whether to show a subtle pill highlight behind the active icon.
  final bool showActivePill;

  /// Height of the pill behind the active icon.
  final double pillHeight;

  const UnderlineWormBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.wormColor,
    this.wormHeight = 3.0,
    this.wormBorderRadius = 8.0,
    this.elasticity = 0.35,
    this.showActivePill = true,
    this.pillHeight = 30.0,
  }) : assert(
          elasticity >= 0.0 && elasticity <= 0.5,
          'elasticity must be between 0.0 and 0.5',
        );

  @override
  State<UnderlineWormBottomNav> createState() => _UnderlineWormBottomNavState();
}

class _UnderlineWormBottomNavState extends State<UnderlineWormBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  // ── Worm position controller ──────────────────────────────────────────────
  late AnimationController _wormController;
  late Animation<double> _leadingAnim;
  late Animation<double> _trailingAnim;

  double _prevIndex = 0;
  double _targetIndex = 0;

  // ── Per-item icon bounce controllers ─────────────────────────────────────
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconBounces;

  // ── Per-item pill fade controllers ────────────────────────────────────────
  late List<AnimationController> _pillControllers;
  late List<Animation<double>> _pillOpacities;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _targetIndex = widget.currentIndex.toDouble();
    _prevIndex = _targetIndex;

    // Worm controller — duration set in didChangeDependencies
    _wormController = AnimationController(vsync: this);

    // Icon bounce per tab
    _iconControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      ),
    );

    _iconBounces = _iconControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 40),
        TweenSequenceItem(tween: Tween(begin: -6.0, end: 2.0), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 2.0, end: 0.0), weight: 30),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    // Pill fade per tab
    _pillControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _pillOpacities = _pillControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _wormController.duration = effectiveDuration;
    _rebuildWormAnimations();

    // Snap worm to current position on first build
    if (_wormController.value == 0.0) {
      _wormController.value = 1.0;
    }
  }

  void _rebuildWormAnimations() {
    // Leading edge: moves fast (reaches target before trailing)
    _leadingAnim = Tween<double>(begin: _prevIndex, end: _targetIndex).animate(
      CurvedAnimation(
        parent: _wormController,
        curve: Interval(0.0, 1.0 - widget.elasticity, curve: Curves.easeInOut),
      ),
    );

    // Trailing edge: starts delayed, snaps with elasticOut
    _trailingAnim = Tween<double>(begin: _prevIndex, end: _targetIndex).animate(
      CurvedAnimation(
        parent: _wormController,
        curve: Interval(
          widget.elasticity,
          1.0,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant UnderlineWormBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      // Pill: fade out old, fade in new
      _pillControllers[old.currentIndex].reverse();
      _pillControllers[widget.currentIndex].forward();

      // Icon: bounce the newly active tab
      _iconControllers[widget.currentIndex].forward(from: 0.0);

      // Worm: update positions and run
      _prevIndex = _targetIndex;
      _targetIndex = widget.currentIndex.toDouble();
      _wormController.duration = effectiveDuration;
      _rebuildWormAnimations();

      if (reduceMotion) {
        _wormController.value = 1.0;
        _prevIndex = _targetIndex;
      } else {
        _wormController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _wormController.dispose();
    for (final c in _iconControllers) {
      c.dispose();
    }
    for (final c in _pillControllers) {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / widget.items.length;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Tab row ──────────────────────────────────────────────
                Row(
                  children: List.generate(widget.items.length, (index) {
                    return _WormNavItem(
                      item: widget.items[index],
                      isActive: index == widget.currentIndex,
                      theme: widget.theme,
                      iconBounce: _iconBounces[index],
                      pillOpacity: _pillOpacities[index],
                      showPill: widget.showActivePill,
                      pillHeight: widget.pillHeight,
                      wormColor: widget.wormColor,
                      onTap: () => _onTap(index),
                    );
                  }),
                ),

                // ── Worm underline ────────────────────────────────────────
                AnimatedBuilder(
                  animation: _wormController,
                  builder: (_, __) {
                    final goingRight = _targetIndex >= _prevIndex;

                    final double leftNode =
                        goingRight ? _trailingAnim.value : _leadingAnim.value;
                    final double rightNode =
                        goingRight ? _leadingAnim.value : _trailingAnim.value;

                    final double inset = tabWidth * 0.25;
                    final double left = leftNode * tabWidth + inset;
                    final double right =
                        rightNode * tabWidth + tabWidth - inset;
                    final double wormWidth = math.max(0.0, right - left);

                    final effectiveColor =
                        widget.wormColor ?? widget.theme.activeColor;

                    return Positioned(
                      bottom: 0,
                      left: left,
                      width: wormWidth,
                      height: widget.wormHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(widget.wormBorderRadius),
                          // Gradient: slightly lighter at center for depth
                          gradient: LinearGradient(
                            colors: [
                              effectiveColor.withValues(alpha: 0.7),
                              effectiveColor,
                              effectiveColor.withValues(alpha: 0.7),
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

class _WormNavItem extends StatelessWidget {
  final dynamic item; // BottomNavItem from your core
  final bool isActive;
  final dynamic theme; // NavTheme from your core
  final Animation<double> iconBounce;
  final Animation<double> pillOpacity;
  final bool showPill;
  final double pillHeight;
  final Color? wormColor;
  final VoidCallback onTap;

  const _WormNavItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.iconBounce,
    required this.pillOpacity,
    required this.showPill,
    required this.pillHeight,
    required this.wormColor,
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
          children: [
            // ── Icon with bounce + optional pill ─────────────────────────
            AnimatedBuilder(
              animation: iconBounce,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, iconBounce.value),
                child: child,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pill background
                  if (showPill)
                    FadeTransition(
                      opacity: pillOpacity,
                      child: Container(
                        width: 48,
                        height: pillHeight,
                        decoration: BoxDecoration(
                          color: (wormColor ?? theme.activeColor)
                              .withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(pillHeight / 2),
                        ),
                      ),
                    ),

                  // Icon + badge
                  NavBadge(
                    badgeText: item.badge,
                    badgeColor: item.badgeColor,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.78, end: 1.0).animate(anim),
                          child: child,
                        ),
                      ),
                      child: IconTheme(
                        key: ValueKey(isActive),
                        data: IconThemeData(
                          size: theme.iconSize,
                          color: isActive
                              ? (wormColor ?? theme.activeColor)
                              : theme.inactiveColor,
                        ),
                        child: isActive ? item.activeIcon : item.icon,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 2),

            // ── Label ─────────────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: isActive
                  ? (theme.activeLabelStyle ??
                      theme.labelStyle.copyWith(
                        color: wormColor ?? theme.activeColor,
                        fontWeight: FontWeight.w700,
                        fontSize: (theme.labelStyle.fontSize ?? 10) + 0.5,
                      ))
                  : theme.labelStyle.copyWith(
                      color: theme.inactiveColor,
                      fontWeight: FontWeight.w500,
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
