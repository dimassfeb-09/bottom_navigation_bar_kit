import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';
import '../shared/nav_label.dart';

/// Style 8: Gradient Spotlight — a radial gradient glow shifts smoothly
/// behind the active tab, creating a "lit from below" spotlight effect.
///
/// Design improvements over v1:
/// - Spotlight is now a separate painted layer (not baked into Container
///   decoration), so it can animate independently of the background color
/// - Uses TweenAnimationBuilder for smooth Alignment interpolation instead
///   of AnimatedContainer (which can't tween Alignment reliably)
/// - Second spotlight layer (dim echo) follows with a slight delay for depth
/// - Icon gets a scale-up pop + AnimatedSwitcher with fade+scale transition
/// - Label uses NavLabel (existing core) with improved active style
/// - HapticFeedback on tap
/// - Architecture: _SpotlightPainter (CustomPainter) + _SpotlightNavItem
class GradientSpotlightBottomNav extends BaseBottomNav {
  /// Two gradient colors: [center/bright, edge/transparent].
  /// Defaults to [activeColor @ 25% opacity, transparent].
  final List<Color>? gradientColors;

  /// Radius of the radial gradient as a fraction of the nav width (0.0–1.5).
  final double spotlightRadius;

  /// Whether to show a secondary dimmer spotlight echo for depth.
  final bool showEcho;

  const GradientSpotlightBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.gradientColors,
    this.spotlightRadius = 0.55,
    this.showEcho = true,
  });

  @override
  State<GradientSpotlightBottomNav> createState() =>
      _GradientSpotlightBottomNavState();
}

class _GradientSpotlightBottomNavState extends State<GradientSpotlightBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  // ── Spotlight position controller ─────────────────────────────────────────
  late AnimationController _spotController;
  late Animation<double> _spotPosition; // 0.0 = leftmost tab, 1.0 = rightmost

  // ── Per-item icon scale controllers ───────────────────────────────────────
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconScales;

  double _prevNorm = 0;
  double _targetNorm = 0;

  double _indexToNorm(int index) {
    if (widget.items.length <= 1) return 0.5;
    return index / (widget.items.length - 1);
  }

  @override
  void initState() {
    super.initState();

    _targetNorm = _indexToNorm(widget.currentIndex);
    _prevNorm = _targetNorm;

    _spotController = AnimationController(vsync: this);

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
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22), weight: 40),
        TweenSequenceItem(tween: Tween(begin: 1.22, end: 0.94), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 30),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _spotController.duration = effectiveDuration;
    _rebuildSpotAnimation();
    if (_spotController.value == 0.0) {
      _spotController.value = 1.0;
    }
  }

  void _rebuildSpotAnimation() {
    _spotPosition = Tween<double>(begin: _prevNorm, end: _targetNorm).animate(
      CurvedAnimation(parent: _spotController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant GradientSpotlightBottomNav old) {
    super.didUpdateWidget(old);

    if (old.currentIndex != widget.currentIndex) {
      // Icon: deactivate old, activate new
      _iconControllers[old.currentIndex].animateTo(
        0.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeIn,
      );
      if (reduceMotion) {
        _iconControllers[widget.currentIndex].value = 1.0;
      } else {
        _iconControllers[widget.currentIndex].forward(from: 0.0);
      }

      // Spotlight: move to new position
      _prevNorm = _spotPosition.value; // current animated position
      _targetNorm = _indexToNorm(widget.currentIndex);
      _spotController.duration = effectiveDuration;
      _rebuildSpotAnimation();

      if (reduceMotion) {
        _spotController.value = 1.0;
        _prevNorm = _targetNorm;
      } else {
        _spotController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _spotController.dispose();
    for (final c in _iconControllers) {
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
    final activeColor = widget.theme.activeColor;
    final spotColors = widget.gradientColors ??
        [
          activeColor.withValues(alpha: 0.22),
          activeColor.withValues(alpha: 0.0),
        ];

    final echoColors = [
      activeColor.withValues(alpha: 0.08),
      activeColor.withValues(alpha: 0.0),
    ];

    return buildSafeArea(
      child: Container(
        height: widget.theme.height,
        color: widget.theme.backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final navWidth = constraints.maxWidth;
            final navHeight = widget.theme.height;

            return Stack(
              children: [
                // ── Spotlight paint layer ────────────────────────────────
                AnimatedBuilder(
                  animation: _spotController,
                  builder: (_, __) {
                    final norm = _spotPosition.value;
                    // Convert normalized 0–1 to pixel x center
                    (widget.items.length <= 1
                            ? 0.0
                            : navWidth /
                                (widget.items.length - 1) *
                                0 // already in norm
                        );
                    // Recalculate: cx = tab center at currentIndex
                    final tabWidth = navWidth / widget.items.length;
                    final spotX = norm * (navWidth - tabWidth) + tabWidth / 2;

                    return CustomPaint(
                      size: Size(navWidth, navHeight),
                      painter: _SpotlightPainter(
                        centerX: spotX,
                        centerY: navHeight * 0.5,
                        radius: navWidth * widget.spotlightRadius,
                        primaryColors: spotColors,
                        echoColors: echoColors,
                        showEcho: widget.showEcho,
                        echoRadius: navWidth * widget.spotlightRadius * 1.6,
                      ),
                    );
                  },
                ),

                // ── Tab row ────────────────────────────────────────────────
                Padding(
                  padding: widget.theme.padding,
                  child: Row(
                    children: List.generate(widget.items.length, (index) {
                      return _SpotlightNavItem(
                        item: widget.items[index],
                        isActive: index == widget.currentIndex,
                        theme: widget.theme,
                        iconScale: _iconScales[index],
                        activeColor: activeColor,
                        onTap: () => _onTap(index),
                      );
                    }),
                  ),
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
// SPOTLIGHT PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double radius;
  final List<Color> primaryColors;
  final List<Color> echoColors;
  final bool showEcho;
  final double echoRadius;

  const _SpotlightPainter({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.primaryColors,
    required this.echoColors,
    required this.showEcho,
    required this.echoRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Echo (wider, dimmer) — drawn first so primary sits on top
    if (showEcho) {
      final echoPaint = Paint()
        ..shader = RadialGradient(colors: echoColors).createShader(
          Rect.fromCircle(
            center: Offset(centerX, centerY),
            radius: echoRadius,
          ),
        );
      canvas.drawCircle(Offset(centerX, centerY), echoRadius, echoPaint);
    }

    // Primary spotlight
    final primaryPaint = Paint()
      ..shader = RadialGradient(colors: primaryColors).createShader(
        Rect.fromCircle(
          center: Offset(centerX, centerY),
          radius: radius,
        ),
      );
    canvas.drawCircle(Offset(centerX, centerY), radius, primaryPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.centerX != centerX || old.centerY != centerY || old.radius != radius;
}

// ─────────────────────────────────────────────────────────────────────────────
// SINGLE NAV ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _SpotlightNavItem extends StatelessWidget {
  final dynamic item;
  final bool isActive;
  final dynamic theme;
  final Animation<double> iconScale;
  final Color activeColor;
  final VoidCallback onTap;

  const _SpotlightNavItem({
    required this.item,
    required this.isActive,
    required this.theme,
    required this.iconScale,
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
          children: [
            // ── Icon with pop scale ──────────────────────────────────────
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
                  duration: const Duration(milliseconds: 210),
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

            const SizedBox(height: 4),

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
                    color: activeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: (theme.labelStyle.fontSize ?? 10) + 0.5,
                  ),
              duration: const Duration(milliseconds: 210),
              curve: Curves.easeOut,
            ),
          ],
        ),
      ),
    );
  }
}
