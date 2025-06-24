import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(GitlyApp());

class GitlyApp extends StatelessWidget {
  const GitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitly: Git Visualizer',
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}
