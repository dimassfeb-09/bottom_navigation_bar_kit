import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 4: Top Bar Sweep — a bold indicator bar at the top edge that sweeps
/// with an elastic overshoot to the active tab.
///
/// Design improvements over v1:
/// - Bar has rounded bottom corners + gradient fill for depth
/// - Bar width animates (stretches wide mid-travel, snaps to normal on arrival)
/// - Active tab gets a subtle full-height tint column behind it
/// - Icon has a slight scale-up on activation via AnimatedScale
/// - Label uses AnimatedDefaultTextStyle for smooth weight/color transition
/// - Top divider line separates nav from content cleanly
/// - HapticFeedback on tap
class TopBarSweepBottomNav extends BaseBottomNav {
  /// Color of the sweep bar. Defaults to theme.activeColor.
  final Color? barColor;

  /// Thickness of the top indicator bar.
  final double barHeight;

  /// Width of bar as a fraction of tabWidth (0.0–1.0). Defaults to 0.55.
  final double barWidthFactor;

  /// ElasticOutCurve tension. Higher = more overshoot.
  final double overshootFactor;

  /// Whether to show the full-height column tint behind the active tab.
  final bool showColumnTint;

  /// Whether to show a hairline divider at the top of the nav bar.
  final bool showTopDivider;

  const TopBarSweepBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.barColor,
    this.barHeight = 3.0,
    this.barWidthFactor = 0.55,
    this.overshootFactor = 0.6,
    this.showColumnTint = true,
    this.showTopDivider = true,
  }) : assert(
          barWidthFactor > 0.0 && barWidthFactor <= 1.0,
          'barWidthFactor must be between 0.0 and 1.0',
        );

  @override
  State<TopBarSweepBottomNav> createState() => _TopBarSweepBottomNavState();
}

class _TopBarSweepBottomNavState extends State<TopBarSweepBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  // ── Per-item icon scale controllers ───────────────────────────────────────
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconScales;

  // ── Per-item column tint controllers ──────────────────────────────────────
  late List<AnimationController> _tintControllers;
  late List<Animation<double>> _tintOpacities;

  @override
  void initState() {
    super.initState();

    _iconControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _iconScales = _iconControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 45),
        TweenSequenceItem(tween: Tween(begin: 1.22, end: 0.95), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 25),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    _tintControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 240),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _tintOpacities = _tintControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    }).toList();
  }

  @override
  void didUpdateWidget(covariant TopBarSweepBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      // Deactivate old
      _iconControllers[old.currentIndex].reverse();
      _tintControllers[old.currentIndex].reverse();

      // Activate new
      if (reduceMotion) {
        _iconControllers[widget.currentIndex].value = 1.0;
        _tintControllers[widget.currentIndex].value = 1.0;
      } else {
        _iconControllers[widget.currentIndex].forward(from: 0.0);
        _tintControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _iconControllers) {
      c.dispose();
    }
    for (final c in _tintControllers) {
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
    final effectiveBarColor = widget.barColor ?? widget.theme.activeColor;

    return buildSafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top divider ─────────────────────────────────────────────────
          if (widget.showTopDivider)
            Divider(
              height: 1,
              thickness: 0.5,
              color: widget.theme.inactiveColor.withValues(alpha: 0.15),
            ),

          Container(
            height: widget.theme.height,
            padding: widget.theme.padding,
            color: widget.theme.backgroundColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / widget.items.length;
                final barWidth = tabWidth * widget.barWidthFactor;
                final barInset = (tabWidth - barWidth) / 2;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Column tints (per tab, behind everything) ──────────
                    if (widget.showColumnTint)
                      Row(
                        children: List.generate(widget.items.length, (index) {
                          return Expanded(
                            child: FadeTransition(
                              opacity: _tintOpacities[index],
                              child: Container(
                                color:
                                    effectiveBarColor.withValues(alpha: 0.07),
                              ),
                            ),
                          );
                        }),
                      ),

                    // ── Sweep bar (AnimatedPositioned) ─────────────────────
                    AnimatedPositioned(
                      duration:
                          reduceMotion ? Duration.zero : effectiveDuration,
                      curve: reduceMotion
                          ? Curves.linear
                          : ElasticOutCurve(widget.overshootFactor),
                      left: widget.currentIndex * tabWidth + barInset,
                      top: 0,
                      width: barWidth,
                      height: widget.barHeight,
                      child: _SweepBar(
                        color: effectiveBarColor,
                        height: widget.barHeight,
                      ),
                    ),

                    // ── Tab items ──────────────────────────────────────────
                    Row(
                      children: List.generate(widget.items.length, (index) {
                        return _TopBarNavItem(
                          item: widget.items[index],
                          isActive: index == widget.currentIndex,
                          theme: widget.theme,
                          iconScale: _iconScales[index],
                          barColor: effectiveBarColor,
                          onTap: () => _onTap(index),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SWEEP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SweepBar extends StatelessWidget {
  final Color color;
  final double height;

  const _SweepBar({required this.color, required this.height});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(height),
          bottomRight: Radius.circular(height),
        ),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.6),
            color,
            color.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _TopBarNavItem extends StatelessWidget {
  final dynamic item;
  final bool isActive;
  final dynamic theme;
  final Animation<double> iconScale;
  final Color barColor;
  final VoidCallback onTap;

  const _TopBarNavItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.iconScale,
    required this.barColor,
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
            // ── Icon + badge ───────────────────────────────────────────────
            AnimatedBuilder(
              animation: iconScale,
              builder: (_, child) => Transform.scale(
                scale: iconScale.value,
                child: child,
              ),
              child: NavBadge(
                badgeText: item.badge,
                badgeColor: item.badgeColor,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
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
                      color: isActive ? barColor : theme.inactiveColor,
                    ),
                    child: isActive ? item.activeIcon : item.icon,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Label ──────────────────────────────────────────────────────
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: isActive
                  ? (theme.activeLabelStyle ??
                      theme.labelStyle.copyWith(
                        color: barColor,
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
