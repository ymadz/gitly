import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(const GitlyApp());

class GitlyApp extends StatelessWidget {
  const GitlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gitly',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.red,
        primaryColor: const Color(0xFF800000), // Maroon
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF800000), // Maroon
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF800000),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF800000),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF400000), // Dark Maroon
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF400000),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
