import 'package:flutter/material.dart';
import 'git_graph.dart';

void main() => runApp(const GitlyGraphApp());

class GitlyGraphApp extends StatelessWidget {
  const GitlyGraphApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitly Graph',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const GitGraphScreen(),
    );
  }
}
