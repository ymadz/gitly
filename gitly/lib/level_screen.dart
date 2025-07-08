import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'git_graph.dart';

class LevelScreen extends StatefulWidget {
  final String title;
  final String expectedCommand;

  const LevelScreen({
    super.key,
    required this.title,
    required this.expectedCommand,
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  bool isCompleted = false;
  final TextEditingController controller = TextEditingController();
  final List<String> console = [];
  bool isRepoInitialized = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    controller.dispose();
    super.dispose();
  }

  void _handleCommand(String input) {
    final trimmed = input.trim();
    setState(() => console.insert(0, '> $trimmed'));

    if (trimmed == widget.expectedCommand) {
      setState(() {
        isCompleted = true;
        isRepoInitialized = true;
      });
      _confettiController.play();
      console.insert(0, '✅ Repository initialized successfully!');
    } else {
      console.insert(0, '❌ Invalid command for this level.');
    }

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ── EDUCATIONAL CARD ─────────────────────
                      _buildCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        '🔍 What is `git init`?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
      SizedBox(height: 6),
      Text(
        '`git init` initializes a new Git repository. It creates the hidden `.git` folder in your project to start tracking file changes and history.',
        style: TextStyle(color: Colors.black87),
      ),
      SizedBox(height: 12),
      Text(
        '📘 Why use it?',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
      SizedBox(height: 6),
      Text(
        'This command tells Git: “Start tracking changes in this directory.” Without it, Git has no idea you want to version-control the project.',
        style: TextStyle(color: Colors.black87),
      ),
      SizedBox(height: 12),
      Text(
        '✅ Task:',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
      ),
      SizedBox(height: 6),
      Text(
        'Type `git init` below to initialize your first Git repo.',
        style: TextStyle(color: Colors.black87),
      ),
    ],
  ),
),


                      const SizedBox(height: 16),

                      // ── GIT GRAPH ─────────────────────────────
                      _buildCard(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          height: 200,
                          child: Center(
                            child: isRepoInitialized
                                ? GitGraphWidget(isInitialized: true, simulateInitOnly: true)
                                : const Text(
                                    'Graph will appear after `git init`',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── INPUT + CONSOLE ──────────────────────
                      _buildCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextField(
                              controller: controller,
                              onSubmitted: _handleCommand,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'Enter Git command',
                                labelStyle: const TextStyle(color: Colors.black87),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.black87),
                                  onPressed: () => _handleCommand(controller.text),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 120),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                reverse: true,
                                itemCount: console.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Text(
                                    console[index],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF800000),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Next Level'),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('🚧 Next level not implemented')),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── CONFETTI CELEBRATION ─────────────────────────
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 20,
                minBlastForce: 10,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets padding = const EdgeInsets.all(20)}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
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
      padding: padding,
      child: child,
    );
  }
}
