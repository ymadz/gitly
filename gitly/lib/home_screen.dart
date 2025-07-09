import 'package:flutter/material.dart';
import 'git_graph.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── APP TITLE ──
                Hero(
                  tag: 'gitly-logo',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Gitly',
                      style: const TextStyle(
                        fontSize: 100,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 0),
                const Text(
                  'Learn Git by Seeing It.',
                  style: TextStyle(fontSize: 20, color: Colors.white70),
                ),
                const SizedBox(height: 30),

                // ── MODE BUTTONS ──
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModeCard(
                          context,
                          title: "Simulation Mode",
                          subtitle: "Practice Git freely",
                          icon: Icons.code,
                          index: 0,
                          onTap: () {
                            Feedback.forTap(context); // 🔊 Tap sound
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GitGraphScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildModeCard(
                          context,
                          title: "Tutorial Mode",
                          subtitle: "Learn Git with guided levels",
                          icon: Icons.school,
                          index: 1,
                          onTap: () {
                            Feedback.forTap(context); // 🔊 Tap sound
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const TutorialScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
  required int index,
  required VoidCallback onTap,
}) {
  final bool isHovered = _hoveredIndex == index;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _hoveredIndex = index),
    onExit: (_) => setState(() => _hoveredIndex = -1),
    child: AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isHovered ? 1.03 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        elevation: isHovered ? 6 : 2, // Soft shadow only
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Feedback.forTap(context);
            onTap();
          },
          splashColor: const Color(0xFF800000).withOpacity(0.15),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
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
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 255, 113, 113),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

}
