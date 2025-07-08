import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitly/main.dart'; // Make sure this path is correct

void main() {
  testWidgets('Gitly HomeScreen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GitlyApp());

    // Check for the title "Gitly"
    expect(find.text('Gitly'), findsWidgets); // findsWidgets because it's in AppBar and body

    // Check that both buttons exist
    expect(find.text('🧪 Simulation Mode'), findsOneWidget);
    expect(find.text('🎓 Tutorial Mode'), findsOneWidget);

    // Check if ElevatedButtons are present
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}
