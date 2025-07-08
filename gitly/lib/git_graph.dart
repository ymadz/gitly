import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GitNode {
  final String id;
  final String message;
  final List<String> parentIds;
  final String branch;
  final Offset position;

  GitNode({
    required this.id,
    required this.message,
    required this.parentIds,
    required this.branch,
    required this.position,
  });
}

class GitGraphScreen extends StatefulWidget {
  const GitGraphScreen({super.key});

  @override
  State<GitGraphScreen> createState() => _GitGraphScreenState();
}

class _GitGraphScreenState extends State<GitGraphScreen> {
  List<GitNode> nodes = [];
  String headId = "";
  String currentBranch = "main";
  int nodeCount = 0;
  bool isInitialized = false;

  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<String> gitCommands = [
    'git init',
    'git commit -m ""',
    'git branch ',
    'git checkout ',
    'git merge ',
    'git log',
    'git status',
    'git reset --hard'
  ];

  List<String> suggestions = [];
  List<String> branches = [];
  Map<String, String> branchHeads = {};
  String? error;
  List<String> consoleLog = [];

  void _addConsoleLog(String message) {
    setState(() {
      consoleLog.insert(0, message);
    });
  }

  void _addCommit(String message) {
    final String id = "c$nodeCount";
    nodeCount++;

    final int branchIndex = _getBranchIndex(currentBranch);
    final Offset pos = Offset(100 + (nodeCount * 60), 100 + branchIndex * 100);

    final GitNode node = GitNode(
      id: id,
      message: message,
      parentIds: headId.isNotEmpty ? [headId] : [],
      branch: currentBranch,
      position: pos,
    );

    setState(() {
      nodes.add(node);
      headId = id;
      branchHeads[currentBranch] = id;
    });

    _addConsoleLog("[$currentBranch] commit $id: $message");
  }

  int _getBranchIndex(String branchName) {
    return branches.indexOf(branchName);
  }

  void _handleCommand(String input) {
    final trimmed = input.trim();

    if (!isInitialized && !trimmed.startsWith('git init')) {
      error = "❌ Repository not initialized. Run 'git init' first.";
      _addConsoleLog(error!);
      return;
    }

    error = null;

    if (trimmed == 'git init') {
      isInitialized = true;
      currentBranch = "main";
      branches = ["main"];
      branchHeads = {};
      nodes.clear();
      headId = "c0";
      branchHeads["main"] = headId;
      nodes.add(GitNode(
        id: headId,
        message: "Initial commit",
        parentIds: [],
        branch: currentBranch,
        position: Offset(100, 100),
      ));
      nodeCount = 1;

      _addConsoleLog("✅ Initialized empty Git repository on branch 'main'.");
    } else if (trimmed.startsWith('git commit -m')) {
      final msg = _extractMessage(trimmed);
      if (msg != null && msg.isNotEmpty) {
        _addCommit(msg);
      } else {
        error = "❌ Invalid commit message.";
        _addConsoleLog(error!);
      }
    } else if (trimmed.startsWith('git branch')) {
      final parts = trimmed.split(' ');
      if (parts.length == 3) {
        final branchName = parts[2];
        if (!branches.contains(branchName)) {
          branches.add(branchName);
          branchHeads[branchName] = branchHeads[currentBranch] ?? "";
          _addConsoleLog("✅ Created branch '$branchName'.");
        } else {
          _addConsoleLog("⚠️ Branch '$branchName' already exists.");
        }
      } else {
        _addConsoleLog("❌ Invalid branch syntax. Use: git branch branch_name");
      }
    } else if (trimmed.startsWith('git checkout')) {
      final parts = trimmed.split(' ');
      if (parts.length == 3) {
        final target = parts[2];

        if (branches.contains(target)) {
          setState(() {
            currentBranch = target;
            headId = branchHeads[currentBranch] ?? '';
          });
          _addConsoleLog("✅ Switched to branch '$currentBranch'.");
        } else if (nodes.any((n) => n.id == target)) {
          setState(() {
            headId = target;
          });
          _addConsoleLog("🕒 HEAD is now at commit '$target'.");
        } else {
          _addConsoleLog("❌ '$target' is not a valid branch or commit ID.");
        }
      } else {
        _addConsoleLog("❌ Invalid checkout syntax. Use: git checkout <branch|commit_id>");
      }
    } else if (trimmed.startsWith('git log')) {
      for (var node in nodes.reversed) {
        _addConsoleLog("[$currentBranch] ${node.id}: ${node.message}");
      }
    } else if (trimmed.startsWith('git status')) {
      _addConsoleLog("📝 On branch '$currentBranch'. Last commit: ${branchHeads[currentBranch] ?? "None"}");
    } else if (trimmed.startsWith('git merge')) {
      _addConsoleLog("🔧 Merge support not yet implemented.");
    } else if (trimmed == 'git reset --hard') {
      _resetSimulation();
      _addConsoleLog("🔄 Simulation reset.");
    } else {
      error = "❌ Unknown or unsupported command.";
      _addConsoleLog(error!);
    }

    controller.clear();
    suggestions.clear();
    setState(() {});
  }

  String? _extractMessage(String input) {
    final match = RegExp(r'git commit -m\s+\"(.+)\"').firstMatch(input);
    return match?.group(1);
  }

  void _resetSimulation() {
    setState(() {
      isInitialized = false;
      currentBranch = "main";
      nodeCount = 0;
      nodes.clear();
      branches.clear();
      branchHeads.clear();
      headId = "";
      suggestions.clear();
      controller.clear();
      consoleLog.clear();
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !isInitialized
              ? "Gitly: Git Graph Visualizer"
              : "Gitly: On branch '$currentBranch'",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Simulation",
            onPressed: _resetSimulation,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            color: Colors.black,
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final b = branches[index];
                final isCurrent = b == currentBranch;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
                  child: Chip(
                    label: Text(b),
                    backgroundColor: isCurrent ? Colors.cyan : Colors.grey.shade700,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  focusNode: _focusNode,
                  onChanged: (val) {
                    setState(() {
                      suggestions = gitCommands.where((cmd) => cmd.startsWith(val)).toList();
                    });
                  },
                  onSubmitted: _handleCommand,
                  decoration: InputDecoration(
                    labelText: isInitialized ? "Enter Git command" : "Repository not initialized. Run 'git init'",
                    border: const OutlineInputBorder(),
                    errorText: error,
                  ),
                ),
                if (suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: suggestions.map((s) {
                        return ListTile(
                          dense: true,
                          title: Text(s, style: const TextStyle(fontSize: 13)),
                          onTap: () {
                            controller.text = s;
                            _focusNode.requestFocus();
                            setState(() => suggestions.clear());
                          },
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                CustomPaint(
                  painter: GitGraphPainter(nodes: nodes, headId: headId),
                  child: Container(),
                ),
                ...nodes.map((node) {
                  return Positioned(
                    left: node.position.dx - 10,
                    top: node.position.dy - 10,
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: node.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('📋 Copied commit ID: ${node.id}')),
                        );
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        color: Colors.transparent,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: ListView.builder(
                reverse: true,
                itemCount: consoleLog.length,
                itemBuilder: (context, index) {
                  return Text(consoleLog[index], style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GitGraphPainter extends CustomPainter {
  final List<GitNode> nodes;
  final String headId;

  GitGraphPainter({required this.nodes, required this.headId});

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()..color = Colors.yellow;
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (var node in nodes) {
      for (var parentId in node.parentIds) {
        final parent = nodes.firstWhere((n) => n.id == parentId, orElse: () => node);
        canvas.drawLine(parent.position, node.position, linePaint);
      }

      canvas.drawRect(
        Rect.fromCenter(center: node.position, width: 20, height: 20),
        nodePaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: node.message,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: 150);
      textPainter.paint(canvas, node.position + const Offset(10, -10));
    }

    if (headId.isNotEmpty && nodes.any((n) => n.id == headId)) {
      final headNode = nodes.firstWhere((n) => n.id == headId);
      final headPaint = Paint()..color = Colors.cyan;
      canvas.drawCircle(headNode.position + const Offset(0, -30), 8, headPaint);

      final labelPainter = TextPainter(
        text: const TextSpan(
          text: 'HEAD',
          style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout(minWidth: 0, maxWidth: 100);
      labelPainter.paint(canvas, headNode.position + const Offset(-20, -45));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
