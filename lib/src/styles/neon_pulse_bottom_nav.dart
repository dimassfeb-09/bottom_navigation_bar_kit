import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 10: Features a pulsing neon glow effect behind the active tab. Enforces a dark background.
class NeonPulseBottomNav extends BaseBottomNav {
  final List<Color>? neonColors;
  final Duration pulseSpeed;
  final double glowSpread;
  final Color backgroundColor;

  /// Ensure `theme` uses a sensible animation duration, and background is forced dark
  /// unless overridden by `backgroundColor` parameter.
  const NeonPulseBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.neonColors,
    this.pulseSpeed = const Duration(milliseconds: 800),
    this.glowSpread = 12.0,
    this.backgroundColor = const Color(0xFF0D0D0D),
  });

  @override
  State<NeonPulseBottomNav> createState() => _NeonPulseBottomNavState();
}

class _NeonPulseBottomNavState extends State<NeonPulseBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    if (kDebugMode && widget.backgroundColor.computeLuminance() > 0.5) {
      debugPrint(
          'NeonPulseBottomNav warning: A light background overrides the neon effect visibility. Consider using a dark background.');
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseSpeed,
    );

    _glowAnimation = Tween<double>(
            begin: widget.glowSpread, end: widget.glowSpread * 2.5)
        .animate(
            CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void didUpdateWidget(covariant NeonPulseBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pulseSpeed != widget.pulseSpeed) {
      _pulseController.duration = widget.pulseSpeed;
      if (!reduceMotion && _pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getNeonColor(int index) {
    if (widget.neonColors != null && widget.neonColors!.isNotEmpty) {
      return widget.neonColors![index % widget.neonColors!.length];
    }
    return widget.theme.activeColor;
  }

  @override
  Widget build(BuildContext context) {
    return buildSafeArea(
      child: Container(
        height: widget.theme.height,
        padding: widget.theme.padding,
        color: widget.backgroundColor,
        child: Row(
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final isActive = index == widget.currentIndex;
            final neonColor = _getNeonColor(index);

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => handleTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Neon Glow
                        if (isActive)
                          AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Container(
                                width: widget.theme.iconSize,
                                height: widget.theme.iconSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: neonColor.withValues(alpha: 0.6),
                                      blurRadius: reduceMotion
                                          ? widget.glowSpread
                                          : _glowAnimation.value,
                                      spreadRadius: (reduceMotion
                                              ? widget.glowSpread
                                              : _glowAnimation.value) /
                                          3,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        // Icon Content
                        NavBadge(
                          badgeText: item.badge,
                          badgeColor: item.badgeColor,
                          child: IconTheme(
                            data: IconThemeData(
                              size: widget.theme.iconSize,
                              color: isActive
                                  ? neonColor
                                  : widget.theme.inactiveColor,
                              shadows: isActive && !reduceMotion
                                  ? [
                                      Shadow(
                                        color: neonColor,
                                        blurRadius: 8.0,
                                      )
                                    ]
                                  : null,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isActive ? item.activeIcon : item.icon,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: isActive
                          ? (widget.theme.activeLabelStyle ??
                              widget.theme.labelStyle.copyWith(
                                color: neonColor,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: neonColor.withValues(alpha: 0.5),
                                    blurRadius: 4.0,
                                  )
                                ],
                              ))
                          : widget.theme.labelStyle.copyWith(
                              color: widget.theme.inactiveColor,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
