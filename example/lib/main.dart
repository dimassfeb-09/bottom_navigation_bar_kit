import 'package:flutter/material.dart';
import 'screens/style_gallery_screen.dart';

void main() {
  runApp(const BottomNavKitExample());
}

class BottomNavKitExample extends StatelessWidget {
  const BottomNavKitExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Nav Kit Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StyleGalleryScreen(),
    );
  }
}
