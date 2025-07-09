import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'git_graph.dart';

class Level3Screen extends StatefulWidget {
  const Level3Screen({super.key});

  @override
  State<Level3Screen> createState() => _Level3ScreenState();
}

class _Level3ScreenState extends State<Level3Screen> {
  final TextEditingController controller = TextEditingController();
  final List<String> console = [];
  bool isInitialized = false;
  bool isStatusChecked = false;
  bool isCompleted = false;
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

    if (!isInitialized && trimmed != 'git init') {
      console.insert(0, '❌ Repository not initialized. Run `git init` first.');
    } else if (trimmed == 'git init' && !isInitialized) {
      setState(() => isInitialized = true);
      console.insert(0, '✅ Git repository initialized.');
    } else if (trimmed == 'git status' && isInitialized && !isStatusChecked) {
      setState(() {
        isStatusChecked = true;
        isCompleted = true;
      });
      console.insert(0, '✅ Git status checked: No commits yet.');
      console.insert(0, "🎉 Level 3 completed! You've learned git status.");
      _confettiController.play();
    } else if (trimmed == 'git init' && isInitialized) {
      console.insert(0, '⚠️ Repository already initialized.');
    } else if (trimmed == 'git status' && isStatusChecked) {
      console.insert(0, '⚠️ You already ran `git status`.');
    } else {
      console.insert(0, '❌ Invalid command for this level.');
    }

    controller.clear();
  }

  String _getCurrentStep() {
    if (!isInitialized) return 'Step 1: Run `git init`';
    if (!isStatusChecked) return 'Step 2: Check repository status using `git status`';
    return '✅ Level completed!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 3: Check Git Status'),
        backgroundColor: const Color(0xFF800000),
      ),
      body: Container(
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCard(
                      child: Column(
                        children: [
                          Text(
                            _getCurrentStep(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: isCompleted ? 1.0 : (isInitialized ? 0.5 : 0.0),
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isCompleted ? '2/2 steps completed' : '${isInitialized ? 1 : 0}/2 steps completed',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔍 What is `git status`?',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "`git status` shows the working tree status — what's staged, unstaged, or untracked.",
                            style: TextStyle(color: Colors.black87),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '✅ Task: Run `git status` after initializing the repository.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        children: [
                          TextField(
                            controller: controller,
                            onSubmitted: _handleCommand,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: isInitialized ? 'Enter git status' : 'Enter Git command',
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
                          // if (isCompleted)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 20),
                          //     child: ElevatedButton.icon(
                          //       style: ElevatedButton.styleFrom(
                          //         backgroundColor: const Color(0xFF800000),
                          //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(12),
                          //         ),
                          //       ),
                          //       icon: const Icon(Icons.arrow_forward),
                          //       label: const Text('Next Level'),
                          //       onPressed: () {
                          //         ScaffoldMessenger.of(context).showSnackBar(
                          //           const SnackBar(content: Text('🚧 Next level not implemented')),
                          //         );
                          //       },
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _buildCard({required Widget child}) {
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
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}
