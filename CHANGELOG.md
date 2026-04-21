## 1.0.0

**Initial stable release.**

### New Styles
- **Style 1 — Sliding Pill**: A pill-shaped background slides smoothly between tabs with configurable color, radius, and icon colors.
- **Style 2 — Underline Worm**: An elastic gradient underline stretches and snaps between tabs with a staggered leading/trailing animation and icon bounce.
- **Style 3 — Bubble Pop**: A circular soft-tinted bubble expands behind the active icon with an overshoot bounce. Redesigned with the dedicated `BubbleNavTheme`.
- **Style 4 — Top Bar Sweep**: A bold indicator bar sweeps along the top edge with an elastic overshoot, column tint, and icon scale pop.
- **Style 5 — Ink Drop**: A two-layer radial ripple expands on tap with a persistent ambient glow behind the active tab.
- **Style 6 — Morphing Icon**: Seamless crossfade between outline and filled icon variants with a scale pop and animated dot indicator.
- **Style 7 — Floating Dot**: A dot arcs in a parabolic trajectory between tabs, squishing at peak and triggering an icon bounce on landing.
- **Style 8 — Gradient Spotlight**: A radial gradient spotlight shifts to the active tab via `CustomPainter`, with an optional dim echo layer for depth.
- **Style 9 — Squeeze & Stretch**: A bottom indicator bar squeezes narrow then stretches wide on selection, driven by `easeInOutBack`.
- **Style 10 — Neon Pulse**: A continuously pulsing neon glow radiates from the active tab icon with per-tab custom colors.

### Core Architecture
- `BaseBottomNav` abstract class and `BaseBottomNavStateMixin` for consistent reduce-motion and safe-area handling across all styles.
- `BottomNavItem` model with `icon`, `activeIcon`, `label`, `badge`, and `badgeColor` fields.
- `NavTheme` with factory presets: `light()`, `dark()`, `material3()`, `cupertino()`.
- `BubbleNavTheme` with factory presets: `light(seed)`, `dark(seed)`.

### Features
- Full **light & dark mode** support across all styles.
- **Reduce Motion** accessibility compliance — all animations snap to final state when system setting is enabled.
- **Badge** support with custom text and colors.
- **HapticFeedback** on tap across all redesigned styles.
- **Zero external dependencies** — pure Flutter SDK only.
- Animation safety via `_ClampedCurve` wrapper to prevent `TweenSequence` assertion errors from overshooting curves like `easeOutBack`.
- Global `ClipRect` via `buildSafeArea` to prevent visual overflow outside bar bounds.
