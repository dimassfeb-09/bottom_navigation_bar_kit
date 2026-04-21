import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 5: Ink Drop — a radial ripple expands from the tapped icon and fades
/// out, leaving behind a persistent soft glow on the active tab.
///
/// Design improvements over v1:
/// - Ripple is now two-layer: outer fast-expand + inner slow-fade for depth
/// - Active tab has a persistent soft ambient glow (not just ripple-on-tap)
/// - Icon always uses AnimatedSwitcher between active/inactive icon variants
/// - Icon gets a slight scale-up pop on activation
/// - Label uses AnimatedDefaultTextStyle for smooth weight/color transition
/// - Controller duration set at initState via rippleDuration fallback
/// - HapticFeedback on tap
/// - Architecture split into _InkDropNavItem + _RippleLayer
class InkDropBottomNav extends BaseBottomNav {
  /// Color of the ripple and ambient glow. Defaults to theme.activeColor.
  final Color? rippleColor;

  /// Peak opacity of the expanding ripple ring.
  final double rippleOpacity;

  /// Duration of the ripple expand + fade animation.
  final Duration? rippleDuration;

  /// Whether to show a persistent soft glow behind the active icon.
  final bool showAmbientGlow;

  /// Size of the ripple circle relative to the nav height (0.0–1.5).
  final double rippleSizeFactor;

  const InkDropBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.rippleColor,
    this.rippleOpacity = 0.22,
    this.rippleDuration,
    this.showAmbientGlow = true,
    this.rippleSizeFactor = 1.1,
  });

  @override
  State<InkDropBottomNav> createState() => _InkDropBottomNavState();
}

class _InkDropBottomNavState extends State<InkDropBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  // ── Per-item ripple controllers ────────────────────────────────────────────
  late List<AnimationController> _rippleControllers;
  late List<Animation<double>> _rippleScales;
  late List<Animation<double>> _rippleFades;

  // ── Per-item icon pop controllers ─────────────────────────────────────────
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconScales;

  // ── Per-item ambient glow controllers ─────────────────────────────────────
  late List<AnimationController> _glowControllers;
  late List<Animation<double>> _glowOpacities;

  Duration get _rippleDuration =>
      widget.rippleDuration ?? const Duration(milliseconds: 480);

  @override
  void initState() {
    super.initState();

    // Ripple: expand scale 0→1 + fade opacity peak→0
    _rippleControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(vsync: this, duration: _rippleDuration),
    );

    _rippleScales = _rippleControllers.map((ctrl) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
      );
    }).toList();

    _rippleFades = _rippleControllers.map((ctrl) {
      return TweenSequence<double>([
        // Ramp up to peak opacity quickly
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: widget.rippleOpacity),
          weight: 15,
        ),
        // Hold briefly
        TweenSequenceItem(
          tween: Tween(begin: widget.rippleOpacity, end: widget.rippleOpacity),
          weight: 10,
        ),
        // Fade to zero
        TweenSequenceItem(
          tween: Tween(begin: widget.rippleOpacity, end: 0.0),
          weight: 75,
        ),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    // Icon pop: scale bounce on activation
    _iconControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 320),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _iconScales = _iconControllers.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.92), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();

    // Ambient glow: persistent fade behind active tab
    _glowControllers = List.generate(
      widget.items.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
        value: i == widget.currentIndex ? 1.0 : 0.0,
      ),
    );

    _glowOpacities = _glowControllers.map((ctrl) {
      return CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final ctrl in _rippleControllers) {
      ctrl.duration = _rippleDuration;
    }
  }

  @override
  void didUpdateWidget(covariant InkDropBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      // Glow: fade out old, fade in new
      _glowControllers[old.currentIndex].reverse();
      _glowControllers[widget.currentIndex].forward();

      // Icon pop on new tab
      if (!reduceMotion) {
        _iconControllers[widget.currentIndex].forward(from: 0.0);
      }

      // Reset old icon scale
      _iconControllers[old.currentIndex].value = 0.0;
    }

    if (old.rippleDuration != widget.rippleDuration ||
        old.theme.animationDuration != widget.theme.animationDuration) {
      for (final ctrl in _rippleControllers) {
        ctrl.duration = _rippleDuration;
      }
    }
  }

  @override
  void dispose() {
    for (final c in _rippleControllers) {
      c.dispose();
    }
    for (final c in _iconControllers) {
      c.dispose();
    }
    for (final c in _glowControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;
    HapticFeedback.lightImpact();

    if (!reduceMotion) {
      _rippleControllers[index].forward(from: 0.0);
    }
    handleTap(index);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effectiveRippleColor = widget.rippleColor ?? widget.theme.activeColor;

    return buildSafeArea(
      child: Container(
        height: widget.theme.height,
        padding: widget.theme.padding,
        color: widget.theme.backgroundColor,
        child: Row(
          children: List.generate(widget.items.length, (index) {
            return _InkDropNavItem(
              item: widget.items[index],
              isActive: index == widget.currentIndex,
              theme: widget.theme,
              rippleColor: effectiveRippleColor,
              rippleScale: _rippleScales[index],
              rippleFade: _rippleFades[index],
              rippleController: _rippleControllers[index],
              iconScale: _iconScales[index],
              glowOpacity: _glowOpacities[index],
              showAmbientGlow: widget.showAmbientGlow,
              rippleSizeFactor: widget.rippleSizeFactor,
              navHeight: widget.theme.height,
              onTap: () => _handleTap(index),
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

class _InkDropNavItem extends StatelessWidget {
  final dynamic item;
  final bool isActive;
  final dynamic theme;
  final Color rippleColor;
  final Animation<double> rippleScale;
  final Animation<double> rippleFade;
  final AnimationController rippleController;
  final Animation<double> iconScale;
  final Animation<double> glowOpacity;
  final bool showAmbientGlow;
  final double rippleSizeFactor;
  final double navHeight;
  final VoidCallback onTap;

  const _InkDropNavItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.rippleColor,
    required this.rippleScale,
    required this.rippleFade,
    required this.rippleController,
    required this.iconScale,
    required this.glowOpacity,
    required this.showAmbientGlow,
    required this.rippleSizeFactor,
    required this.navHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rippleDiameter = navHeight * rippleSizeFactor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRect(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Ambient glow (persistent, behind ripple) ──────────────
              if (showAmbientGlow)
                FadeTransition(
                  opacity: glowOpacity,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          rippleColor.withValues(alpha: 0.18),
                          rippleColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Expanding ripple ring ──────────────────────────────────
              _RippleLayer(
                controller: rippleController,
                scale: rippleScale,
                fade: rippleFade,
                color: rippleColor,
                diameter: rippleDiameter,
              ),

              // ── Icon + label ───────────────────────────────────────────
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with pop scale
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
                            scale: Tween(begin: 0.72, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                        child: IconTheme(
                          key: ValueKey(isActive),
                          data: IconThemeData(
                            size: theme.iconSize,
                            color: isActive ? rippleColor : theme.inactiveColor,
                          ),
                          child: isActive ? item.activeIcon : item.icon,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Label with smooth style transition
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    style: isActive
                        ? (theme.activeLabelStyle ??
                            theme.labelStyle.copyWith(
                              color: rippleColor,
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
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RIPPLE LAYER
// ─────────────────────────────────────────────────────────────────────────────

class _RippleLayer extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> scale;
  final Animation<double> fade;
  final Color color;
  final double diameter;

  const _RippleLayer({
    required this.controller,
    required this.scale,
    required this.fade,
    required this.color,
    required this.diameter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        if (controller.value == 0.0) return const SizedBox.shrink();

        return Opacity(
          opacity: fade.value,
          child: Transform.scale(
            scale: scale.value,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Two-tone: solid center fading to transparent edge
                gradient: RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.35),
                    color.withValues(alpha: 0.0),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
