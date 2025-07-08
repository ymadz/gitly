import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'git_graph.dart';

class Level2Screen extends StatefulWidget {
  const Level2Screen({super.key});

  @override
  State<Level2Screen> createState() => _Level2ScreenState();
}

class _Level2ScreenState extends State<Level2Screen> {
  bool isRepoInitialized = false;
  bool isCommitCompleted = false;
  bool isCompleted = false;
  final TextEditingController controller = TextEditingController();
  final List<String> console = [];
  late ConfettiController _confettiController;
  
  // Add these variables to track git state
  List<GitNode> nodes = [];
  String headId = "";
  String currentBranch = "main";
  int nodeCount = 0;
  Map<String, String> branchHeads = {};

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

    if (!isRepoInitialized && trimmed != 'git init') {
      console.insert(0, '❌ Repository not initialized. Run \'git init\' first.');
      controller.clear();
      return;
    }

    if (trimmed == 'git init' && !isRepoInitialized) {
      setState(() {
        isRepoInitialized = true;
        currentBranch = "main";
        nodeCount = 0;
        headId = "c0";
        
        // Create initial commit node
        nodes = [
          GitNode(
            id: "c0",
            message: "Initial commit",
            parentIds: [],
            branch: currentBranch,
            position: const Offset(100, 100),
          )
        ];
        
        branchHeads = {"main": "c0"};
        nodeCount = 1;
      });
      console.insert(0, '✅ Initialized empty Git repository on branch \'main\'.');
    } else if (trimmed.startsWith('git commit -m') && isRepoInitialized && !isCommitCompleted) {
      final message = _extractMessage(trimmed);
      if (message != null && message.isNotEmpty) {
        // Create new commit node
        final String id = "c$nodeCount";
        final GitNode newNode = GitNode(
          id: id,
          message: message,
          parentIds: [headId],
          branch: currentBranch,
          position: Offset(100 + nodeCount * 80, 100),
        );
        
        setState(() {
          nodes.add(newNode);
          headId = id;
          branchHeads[currentBranch] = id;
          nodeCount++;
          isCommitCompleted = true;
          isCompleted = true;
        });
        
        _confettiController.play();
        console.insert(0, '✅ First commit created successfully!');
        console.insert(0, '🎉 Level 2 completed! You\'ve learned git commit.');
      } else {
        console.insert(0, '❌ Invalid commit message format. Use: git commit -m "your message"');
      }
    } else if (trimmed == 'git init' && isRepoInitialized) {
      console.insert(0, '⚠️ Repository already initialized.');
    } else if (trimmed.startsWith('git commit -m') && isCommitCompleted) {
      console.insert(0, '⚠️ You\'ve already completed the commit for this level.');
    } else {
      console.insert(0, '❌ Invalid command for this level.');
    }

    controller.clear();
  }

  String? _extractMessage(String input) {
    final match = RegExp(r'git commit -m\s+"(.+?)"').firstMatch(input);
    return match?.group(1);
  }

  String _getCurrentStep() {
    if (!isRepoInitialized) {
      return "Step 1: Initialize the repository";
    } else if (!isCommitCompleted) {
      return "Step 2: Make your first commit";
    } else {
      return "✅ Level completed!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 2: Make a Commit'),
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
                      // ── PROGRESS INDICATOR ───────────────────
                      _buildCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              _getCurrentStep(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: isCompleted ? 1.0 : (isRepoInitialized ? 0.5 : 0.0),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isCompleted ? '2/2 steps completed' : 
                              '${isRepoInitialized ? 1 : 0}/2 steps completed',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── EDUCATIONAL CARD ─────────────────────
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📝 What is `git commit`?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '`git commit` saves your staged changes to the repository history. It creates a snapshot of your project at this moment in time.',
                              style: TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '📘 The -m flag:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'The -m flag lets you add a commit message directly in the command line. Every commit needs a message to describe what changes were made.',
                              style: TextStyle(color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '✅ Task:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isRepoInitialized 
                                ? 'Now type: git commit -m "Your commit message here"'
                                : 'First, initialize the repository with: git init',
                              style: const TextStyle(color: Colors.black87),
                            ),
                            if (isRepoInitialized && !isCommitCompleted)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3CD),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFFFD700)),
                                ),
                                child: const Text(
                                  '💡 Example: git commit -m "Add welcome message"',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                ),
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
                                ? CustomPaint(
                                    painter: GitGraphPainter(
                                      nodes: nodes,
                                      headId: headId,
                                      branchHeads: branchHeads,
                                    ),
                                    child: Container(),
                                  )
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
                                labelText: isRepoInitialized 
                                  ? 'Enter Git commit command'
                                  : 'Enter Git command',
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