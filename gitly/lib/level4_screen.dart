import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'git_graph.dart';

class Level4Screen extends StatefulWidget {
  const Level4Screen({super.key});

  @override
  State<Level4Screen> createState() => _Level4ScreenState();
}

class _Level4ScreenState extends State<Level4Screen> {
  bool isRepoInitialized = false;
  bool isBranchCreated = false;
  bool isCheckoutCompleted = false;
  bool isCompleted = false;

  final TextEditingController controller = TextEditingController();
  final List<String> console = [];
  late ConfettiController _confettiController;

  List<GitNode> nodes = [];
  String headId = "";
  String currentBranch = "";
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
      console.insert(0, '❌ Repository not initialized. Run `git init` first.');
      controller.clear();
      return;
    }

    if (trimmed == 'git init' && !isRepoInitialized) {
      setState(() {
        isRepoInitialized = true;
        currentBranch = 'main';
        nodeCount = 0;
        headId = 'c0';

        nodes = [
          GitNode(
            id: 'c0',
            message: 'Initial commit',
            parentIds: [],
            branch: currentBranch,
            position: const Offset(100, 100),
          )
        ];

        branchHeads = {'main': 'c0'};
        nodeCount = 1;
      });
      console.insert(0, '✅ Initialized empty Git repository on branch `main`.');
    } else if (trimmed.startsWith('git branch ') && isRepoInitialized && !isBranchCreated) {
      final parts = trimmed.split(' ');
      if (parts.length == 3) {
        final newBranch = parts[2];
        setState(() {
          branchHeads[newBranch] = headId;
          isBranchCreated = true;
        });
        console.insert(0, '✅ Branch `$newBranch` created from `$currentBranch`.');
      } else {
        console.insert(0, '❌ Invalid branch command. Use: git branch <branch_name>');
      }
    } else if (trimmed.startsWith('git checkout ') && isBranchCreated && !isCheckoutCompleted) {
      final parts = trimmed.split(' ');
      if (parts.length == 3 && branchHeads.containsKey(parts[2])) {
        setState(() {
          currentBranch = parts[2];
          isCheckoutCompleted = true;
          isCompleted = true;
        });
        _confettiController.play();
        console.insert(0, '🎉 Switched to branch `${parts[2]}`. Level 4 complete!');
      } else {
        console.insert(0, '❌ Branch not found. Create it first with `git branch <name>`');
      }
    } else {
      console.insert(0, '❌ Invalid command for this level.');
    }

    controller.clear();
  }

  String _getCurrentStep() {
    if (!isRepoInitialized) return 'Step 1: Initialize repository';
    if (!isBranchCreated) return 'Step 2: Create a new branch';
    if (!isCheckoutCompleted) return 'Step 3: Checkout to the new branch';
    return '✅ Level completed!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Level 4: Branch & Checkout',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF800000),
        iconTheme: const IconThemeData(color: Colors.white),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getCurrentStep(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: isCompleted
                                ? 1.0
                                : isCheckoutCompleted
                                    ? 0.66
                                    : isBranchCreated
                                        ? 0.33
                                        : isRepoInitialized
                                            ? 0.1
                                            : 0.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF800000)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: const Text(
                        'Learn how to create a new branch using `git branch <name>` and switch to it using `git checkout <name>`. Branches help you work on features independently.',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: SizedBox(
                        height: 200,
                        child: isRepoInitialized
                            ? CustomPaint(
                                painter: GitGraphPainter(
                                  nodes: nodes,
                                  headId: headId,
                                  branchHeads: branchHeads,
                                ),
                                child: Container(),
                              )
                            : const Center(
                                child: Text(
                                  'Graph will appear after `git init`',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: controller,
                            onSubmitted: _handleCommand,
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'Enter Git command',
                              labelStyle: const TextStyle(color: Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send, color: Colors.black),
                                onPressed: () => _handleCommand(controller.text),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            constraints: const BoxConstraints(maxHeight: 120),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFAFA),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: console.length,
                              itemBuilder: (_, i) => Text(
                                console[i],
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}
