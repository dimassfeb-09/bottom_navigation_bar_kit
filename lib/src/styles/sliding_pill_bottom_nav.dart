import 'package:flutter/material.dart';
import '../core/base_bottom_nav.dart';
import '../shared/nav_badge.dart';

/// Style 1: A pill-shaped container that slides horizontally between active tabs.
class SlidingPillBottomNav extends BaseBottomNav {
  final Color? pillColor;
  final BorderRadiusGeometry? pillBorderRadius;
  final Color? activeIconColor;
  final Color? inactiveIconColor;

  const SlidingPillBottomNav({
    super.key,
    required super.items,
    required super.currentIndex,
    required super.onTap,
    super.theme,
    this.pillColor,
    this.pillBorderRadius,
    this.activeIconColor,
    this.inactiveIconColor,
  });

  @override
  State<SlidingPillBottomNav> createState() => _SlidingPillBottomNavState();
}

class _SlidingPillBottomNavState extends State<SlidingPillBottomNav>
    with BaseBottomNavStateMixin {
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
              children: [
                // Sliding Pill
                AnimatedPositioned(
                  duration: effectiveDuration,
                  curve: widget.theme.animationCurve,
                  left: widget.currentIndex * tabWidth,
                  top: 0,
                  bottom: 0,
                  width: tabWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.pillColor ??
                            widget.theme.activeColor.withValues(alpha: 0.15),
                        borderRadius: widget.pillBorderRadius ??
                            BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                // Icons & Labels
                Row(
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final isActive = index == widget.currentIndex;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => handleTap(index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NavBadge(
                              badgeText: item.badge,
                              badgeColor: item.badgeColor,
                              child: IconTheme(
                                data: IconThemeData(
                                  size: widget.theme.iconSize,
                                  color: isActive
                                      ? (widget.activeIconColor ??
                                          widget.theme.activeColor)
                                      : (widget.inactiveIconColor ??
                                          widget.theme.inactiveColor),
                                ),
                                child: AnimatedSwitcher(
                                  duration: effectiveDuration,
                                  child: isActive ? item.activeIcon : item.icon,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: isActive
                                  ? (widget.theme.activeLabelStyle ??
                                      widget.theme.labelStyle.copyWith(
                                        color: widget.activeIconColor ??
                                            widget.theme.activeColor,
                                        fontWeight: FontWeight.bold,
                                      ))
                                  : widget.theme.labelStyle.copyWith(
                                      color: widget.inactiveIconColor ??
                                          widget.theme.inactiveColor,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
