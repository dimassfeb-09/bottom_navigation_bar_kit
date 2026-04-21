import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/bottom_nav_item.dart';
import '../core/nav_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MAIN WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class BubblePopBottomNav extends StatefulWidget {
  final List<BottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final BubbleNavTheme? theme;

  /// Override bubble size (default: 48)
  final double bubbleSize;

  /// Whether to show labels under icons
  final bool showLabels;

  const BubblePopBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.theme,
    this.bubbleSize = 42.0,
    this.showLabels = true,
  }) : assert(items.length >= 3 && items.length <= 5,
            'items must be between 3 and 5');

  @override
  State<BubblePopBottomNav> createState() => _BubblePopBottomNavState();
}

class _BubblePopBottomNavState extends State<BubblePopBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _bubbleControllers;
  late List<AnimationController> _iconControllers;
  late List<AnimationController> _labelControllers;

  late List<Animation<double>> _bubbleScales;
  late List<Animation<double>> _iconScales;
  late List<Animation<double>> _labelOpacities;
  late List<Animation<double>> _bubbleOpacities;

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  BubbleNavTheme get _theme {
    final brightness = Theme.of(context).brightness;
    return widget.theme ??
        (brightness == Brightness.dark
            ? BubbleNavTheme.dark()
            : BubbleNavTheme.light());
  }

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    final count = widget.items.length;

    _bubbleControllers = List.generate(
      count,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _iconControllers = List.generate(
      count,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _labelControllers = List.generate(
      count,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    // Bubble: overshoot bounce (1.0 → 1.18 → 1.0)
    _bubbleScales = _bubbleControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.18), weight: 55),
        TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.96), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 20),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    // Bubble opacity: fade in fast
    _bubbleOpacities = _bubbleControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: const Interval(0.0, 0.4));
    }).toList();

    // Icon: slight scale-up on activate
    _iconScales = _iconControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.8, end: 1.15), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(
        parent: ctrl,
        curve: const _ClampedCurve(Curves.easeOutBack),
      ));
    }).toList();

    // Label: fade + slide up
    _labelOpacities = _labelControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    }).toList();
  }

  @override
  void didUpdateWidget(covariant BubblePopBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      _animateOut(old.currentIndex);
      _animateIn(widget.currentIndex);
    }

    if (old.items.length != widget.items.length) {
      _disposeAnimations();
      _initAnimations();
    }
  }

  void _animateIn(int index) {
    if (_reduceMotion) {
      _bubbleControllers[index].value = 1.0;
      _iconControllers[index].value = 1.0;
      _labelControllers[index].value = 1.0;
    } else {
      _bubbleControllers[index].forward(from: 0.0);
      _iconControllers[index].forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 60), () {
        if (mounted) _labelControllers[index].forward(from: 0.0);
      });
    }
  }

  void _animateOut(int index) {
    if (_reduceMotion) {
      _bubbleControllers[index].value = 0.0;
      _iconControllers[index].value = 0.0;
      _labelControllers[index].value = 0.0;
    } else {
      _bubbleControllers[index].reverse();
      _labelControllers[index].reverse();
      // Icon stays at 1.0 (inactive icon shown via AnimatedSwitcher)
      _iconControllers[index].reverse();
    }
  }

  void _disposeAnimations() {
    for (final c in _bubbleControllers) {
      c.dispose();
    }
    for (final c in _iconControllers) {
      c.dispose();
    }
    for (final c in _labelControllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeAnimations();
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.lightImpact();
    widget.onTap(index);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = _theme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        boxShadow: theme.shadows,
        borderRadius: theme.containerRadius,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: theme.height + (bottomPadding > 0 ? 0 : 8),
          child: Row(
            children: List.generate(widget.items.length, (index) {
              return _NavItem(
                item: widget.items[index],
                isActive: index == widget.currentIndex,
                theme: theme,
                bubbleSize: widget.bubbleSize,
                showLabel: widget.showLabels,
                bubbleScale: _bubbleScales[index],
                bubbleOpacity: _bubbleOpacities[index],
                iconScale: _iconScales[index],
                labelOpacity: _labelOpacities[index],
                onTap: () => _handleTap(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final BubbleNavTheme theme;
  final double bubbleSize;
  final bool showLabel;
  final Animation<double> bubbleScale;
  final Animation<double> bubbleOpacity;
  final Animation<double> iconScale;
  final Animation<double> labelOpacity;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.bubbleSize,
    required this.showLabel,
    required this.bubbleScale,
    required this.bubbleOpacity,
    required this.iconScale,
    required this.labelOpacity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _BubbleIcon(
                item: item,
                isActive: isActive,
                theme: theme,
                bubbleSize: bubbleSize,
                bubbleScale: bubbleScale,
                bubbleOpacity: bubbleOpacity,
                iconScale: iconScale,
              ),
              if (showLabel) ...[
                const SizedBox(height: 2),
                _AnimatedLabel(
                  label: item.label,
                  isActive: isActive,
                  theme: theme,
                  opacity: labelOpacity,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUBBLE + ICON LAYER
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleIcon extends StatelessWidget {
  final BottomNavItem item;
  final bool isActive;
  final BubbleNavTheme theme;
  final double bubbleSize;
  final Animation<double> bubbleScale;
  final Animation<double> bubbleOpacity;
  final Animation<double> iconScale;

  const _BubbleIcon({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.bubbleSize,
    required this.bubbleScale,
    required this.bubbleOpacity,
    required this.iconScale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: bubbleSize,
      height: bubbleSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Bubble background ──
          AnimatedBuilder(
            animation: Listenable.merge([bubbleScale, bubbleOpacity]),
            builder: (_, __) => FadeTransition(
              opacity: bubbleOpacity,
              child: ScaleTransition(
                scale: bubbleScale,
                child: Container(
                  width: bubbleSize,
                  height: bubbleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.bubbleColor,
                  ),
                ),
              ),
            ),
          ),

          // ── Badge ──
          if (item.badge != null)
            Positioned(
              top: 4,
              right: 4,
              child: _Badge(text: item.badge!, color: item.badgeColor),
            ),

          // ── Icon ──
          AnimatedBuilder(
            animation: iconScale,
            builder: (_, __) => ScaleTransition(
              scale: iconScale,
              child: AnimatedSwitcher(
                duration: theme.animationDuration,
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
                    color: isActive ? theme.activeColor : theme.inactiveColor,
                  ),
                  child: isActive ? item.activeIcon : item.icon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedLabel extends StatelessWidget {
  final String label;
  final bool isActive;
  final BubbleNavTheme theme;
  final Animation<double> opacity;

  const _AnimatedLabel({
    required this.label,
    required this.isActive,
    required this.theme,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    // Active: full opacity + brand color + bold
    // Inactive: muted color, slightly smaller
    return AnimatedDefaultTextStyle(
      duration: theme.animationDuration,
      curve: Curves.easeOut,
      style: isActive
          ? theme.labelStyle.copyWith(
              color: theme.activeColor,
              fontWeight: FontWeight.w700,
              fontSize: (theme.labelStyle.fontSize ?? 10) + 0.5,
            )
          : theme.labelStyle.copyWith(
              color: theme.inactiveColor,
              fontWeight: FontWeight.w500,
            ),
      child: FadeTransition(
        opacity: isActive
            ? opacity
            : const AlwaysStoppedAnimation(1.0), // inactive always visible
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGE
// ─────────────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String text;
  final Color? color;

  const _Badge({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Helper to ensure curves like [Curves.easeOutBack] stay within [0.0, 1.0]
/// for compatibility with [TweenSequence].
class _ClampedCurve extends Curve {
  final Curve curve;
  const _ClampedCurve(this.curve);

  @override
  double transform(double t) => curve.transform(t).clamp(0.0, 1.0);
}
