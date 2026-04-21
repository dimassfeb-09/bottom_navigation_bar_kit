import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Gallery page loads properly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BottomNavKitExample());

    // Verify that the title of our gallery is there.
    expect(find.text('Navigation Styles'), findsOneWidget);
    
    // Verify that style 1 is listed
    expect(find.text('Style 1: Sliding Pill'), findsOneWidget);
  });
}
