import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 9: An indicator that squeezes and stretches dynamically upon selection.
class SqueezeStretchBottomNav extends BaseBottomNav {
  final Color? indicatorColor;
  final double squeezeWidth;
  final double stretchWidth;
  final double indicatorHeight;
  final Curve? animationCurve;

  const SqueezeStretchBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.indicatorColor,
    this.squeezeWidth = 20.0,
    this.stretchWidth = 60.0,
    this.indicatorHeight = 3.0,
    this.animationCurve,
  });

  @override
  State<SqueezeStretchBottomNav> createState() =>
      _SqueezeStretchBottomNavState();
}

class _SqueezeStretchBottomNavState extends State<SqueezeStretchBottomNav>
    with BaseBottomNavStateMixin, TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _widthAnimations;
  late List<Animation<double>> _heightAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        vsync: this,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var controller in _controllers) {
      controller.duration = effectiveDuration;
    }
    _setupAnimations();

    if (!reduceMotion) {
      _controllers[widget.currentIndex].value = 1.0;
    }
  }

  void _setupAnimations() {
    final curve = _ClampedCurve(widget.animationCurve ?? Curves.easeInOutBack);

    // Width animations for all items
    _widthAnimations = _controllers
        .map((c) => TweenSequence<double>([
              TweenSequenceItem(
                  tween: Tween(begin: 0.0, end: widget.squeezeWidth),
                  weight: 30),
              TweenSequenceItem(
                  tween: Tween(
                      begin: widget.squeezeWidth, end: widget.stretchWidth),
                  weight: 70),
            ]).animate(CurvedAnimation(
              parent: c,
              curve: curve,
            )))
        .toList();

    // Height animations for all items
    _heightAnimations = _controllers
        .map((c) => TweenSequence<double>([
              TweenSequenceItem(
                  tween: Tween(begin: 0.0, end: widget.indicatorHeight * 1.5),
                  weight: 30),
              TweenSequenceItem(
                  tween: Tween(
                      begin: widget.indicatorHeight * 1.5,
                      end: widget.indicatorHeight),
                  weight: 70),
            ]).animate(CurvedAnimation(
              parent: c,
              curve: curve,
            )))
        .toList();
  }

  @override
  void didUpdateWidget(covariant SqueezeStretchBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      if (reduceMotion) {
        _controllers[oldWidget.currentIndex].value = 0.0;
        _controllers[widget.currentIndex].value = 1.0;
      } else {
        _controllers[oldWidget.currentIndex].reverse();
        _controllers[widget.currentIndex].forward(from: 0.0);
      }
    } else if (oldWidget.theme.animationDuration !=
        widget.theme.animationDuration) {
      for (var controller in _controllers) {
        controller.duration = effectiveDuration;
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSafeArea(
      child: Container(
        height: widget.theme.height,
        padding: widget.theme.padding,
        color: widget.theme.backgroundColor,
        child: Row(
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final isActive = index == widget.currentIndex;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => handleTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NavBadge(
                      badgeText: item.badge,
                      badgeColor: item.badgeColor,
                      child: IconTheme(
                        data: IconThemeData(
                          size: widget.theme.iconSize,
                          color: isActive
                              ? widget.theme.activeColor
                              : widget.theme.inactiveColor,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isActive ? item.activeIcon : item.icon,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.label,
                      style: isActive
                          ? (widget.theme.activeLabelStyle ??
                              widget.theme.labelStyle.copyWith(
                                color: widget.theme.activeColor,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ))
                          : widget.theme.labelStyle.copyWith(
                              color: widget.theme.inactiveColor,
                              height: 1.1,
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    // Squeeze & Stretch Indicator
                    AnimatedBuilder(
                      animation: _controllers[index],
                      builder: (context, child) {
                        return Container(
                          width: math.max(0.0, _widthAnimations[index].value),
                          height: math.max(0.0, _heightAnimations[index].value),
                          decoration: BoxDecoration(
                            color: widget.indicatorColor ??
                                widget.theme.activeColor,
                            borderRadius: BorderRadius.circular(
                                widget.indicatorHeight), // Fully rounded
                          ),
                        );
                      },
                    )
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

class _ClampedCurve extends Curve {
  final Curve curve;
  const _ClampedCurve(this.curve);

  @override
  double transform(double t) => curve.transform(t).clamp(0.0, 1.0);
}
