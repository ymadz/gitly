import 'package:flutter/material.dart';
import 'level_screen.dart';
import 'level2_screen.dart'; // Add this import


class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> challenges = [
      {'title': 'Level 1: Initialize a Repository', 'desc': "Learn 'git init'"},
      {'title': 'Level 2: Make a Commit', 'desc': "Learn 'git commit'"},
      // Add more levels later
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Mode'),
        backgroundColor: const Color(0xFF800000),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF800000), Color(0xFFE53935)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF6B6B),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      challenge['title']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    subtitle: Text(
                      challenge['desc']!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.play_arrow, color: Colors.grey),
                    onTap: () {
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LevelScreen(
                              title: 'Level 1: Initialize a Repository',
                              expectedCommand: 'git init',
                            ),
                          ),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Level2Screen(),
                          ),
                        );
                      }else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('🚧 Challenge not yet implemented')),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
