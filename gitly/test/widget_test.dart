import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gitly/main.dart'; // Make sure this path is correct

void main() {
  testWidgets('Gitly HomeScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const GitlyApp());

    expect(find.text('Gitly'), findsOneWidget);
    expect(find.text('Learn Git by Seeing It.'), findsOneWidget);
    expect(find.text('Simulation Mode'), findsOneWidget);
    expect(find.text('Tutorial Mode'), findsOneWidget);
  });

  testWidgets('Simulation Mode opens the Git graph screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GitlyApp());

    await tester.tap(find.text('Simulation Mode'));
    await tester.pumpAndSettle();

    expect(find.text("Run 'git init' to begin"), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Tutorial Mode opens the guided levels',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GitlyApp());

    await tester.tap(find.text('Tutorial Mode'));
    await tester.pumpAndSettle();

    expect(find.text('Tutorial Mode'), findsOneWidget);
    expect(find.text('Level 1: Initialize a Repository'), findsOneWidget);
    expect(find.text('Level 4: Create and Switch Branches'), findsOneWidget);
  });
}
