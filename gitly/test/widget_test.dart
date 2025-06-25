import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitly/main.dart'; // ✅ Update this if your project has a different name

void main() {
  testWidgets('Gitly Graph renders home screen with input field', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GitlyGraphApp());

    // Verify the app title appears.
    expect(find.text('Gitly: Git Graph Visualizer'), findsOneWidget);

    // Check for the presence of the text field input
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CustomPaint), findsOneWidget);
  });
}
