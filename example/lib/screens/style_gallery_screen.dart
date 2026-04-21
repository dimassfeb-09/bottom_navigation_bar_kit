import 'package:flutter/material.dart';
import 'demo_screen.dart';

class StyleGalleryScreen extends StatelessWidget {
  const StyleGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Styles'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _styles.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final style = _styles[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              style.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(style.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DemoScreen(title: style.name, styleIndex: index + 1),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StyleMeta {
  final String name;
  final String description;
  const _StyleMeta(this.name, this.description);
}

const _styles = [
  _StyleMeta(
    'Style 1: Sliding Pill',
    'A background pill slides between inactive and active states.',
  ),
  _StyleMeta(
    'Style 2: Underline Worm',
    'An underline indicator that elegantly stretches to the active tab.',
  ),
  _StyleMeta(
    'Style 3: Bubble Pop',
    'A circle scales up delightfully behind the icon when selected.',
  ),
  _StyleMeta(
    'Style 4: Top Bar Sweep',
    'A sweeping top edge indicator with an elastic overshoot.',
  ),
  _StyleMeta(
    'Style 5: Ink Drop',
    'A classic radial ripple expanding seamlessly on tap.',
  ),
  _StyleMeta(
    'Style 6: Morphing Icon',
    'Crossfades inactive outlined icons into active filled icons.',
  ),
  _StyleMeta(
    'Style 7: Floating Dot Trail',
    'A dot physically jumps in a clean arc from one tab to the next.',
  ),
  _StyleMeta(
    'Style 8: Gradient Spotlight',
    'A shifting radial gradient acting as a spotlight on the active tab.',
  ),
  _StyleMeta(
    'Style 9: Squeeze & Stretch',
    'An indicator pill dynamically squishes and stretches as it moves.',
  ),
  _StyleMeta(
    'Style 10: Neon Pulse',
    'A striking, infinite neon glowing shadow on dark backgrounds.',
  ),
];
