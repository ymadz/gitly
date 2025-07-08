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

class GitGraphWidget extends StatelessWidget {
  final bool isInitialized;
  final bool simulateInitOnly;

  const GitGraphWidget({
    super.key,
    this.isInitialized = false,
    this.simulateInitOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GitGraphPainter(
        nodes: [
          if (isInitialized)
            GitNode(
              id: 'c0',
              message: 'Initial commit',
              parentIds: [],
              branch: 'main',
              position: const Offset(100, 100),
            )
        ],
        headId: isInitialized ? 'c0' : '',
        branchHeads: isInitialized ? {'main': 'c0'} : {},
      ),
      child: Container(),
    );
  }
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
  Map<String, double> branchXOffsets = {}; // NEW
  String? error;
  List<String> consoleLog = [];
  List<List<GitNode>> undoStack = [];
  List<List<GitNode>> redoStack = [];
  bool isDarkTheme = true;

  void _pushUndo() {
    undoStack.add(List.from(nodes));
    if (undoStack.length > 100) undoStack.removeAt(0);
    redoStack.clear();
  }

  void _undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(nodes));
      setState(() => nodes = undoStack.removeLast());
    }
  }

  void _redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(nodes));
      setState(() => nodes = redoStack.removeLast());
    }
  }

  void _addConsoleLog(String message) {
    setState(() => consoleLog.insert(0, message));
  }

  void _addCommit(String message) {
    final String id = "c$nodeCount";
    nodeCount++;

    final int branchIndex = branches.indexOf(currentBranch);
    double nextX = (branchXOffsets[currentBranch] ?? 100) + 80;
    branchXOffsets[currentBranch] = nextX;

    final Offset pos = Offset(nextX, 100 + branchIndex * 100);

    final GitNode node = GitNode(
      id: id,
      message: message,
      parentIds: headId.isNotEmpty ? [headId] : [],
      branch: currentBranch,
      position: pos,
    );

    _pushUndo();

    setState(() {
      nodes.add(node);
      headId = id;
      branchHeads[currentBranch] = id;
    });

    _addConsoleLog("[$currentBranch] commit $id: $message");
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
      _pushUndo();
      isInitialized = true;
      currentBranch = "main";
      branches = ["main"];
      branchHeads = {};
      branchXOffsets = {"main": 100};
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
          _pushUndo();
          branches.add(branchName);
          branchHeads[branchName] = branchHeads[currentBranch] ?? "";
          branchXOffsets[branchName] =
              branchXOffsets[currentBranch] ?? 100; // NEW
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
          _pushUndo();
          setState(() {
            currentBranch = target;
            headId = branchHeads[currentBranch] ?? '';
          });
          _addConsoleLog("✅ Switched to branch '$currentBranch'.");
        } else if (nodes.any((n) => n.id == target)) {
          _pushUndo();
          setState(() => headId = target);
          _addConsoleLog("🕒 HEAD is now at commit '$target'.");
        } else {
          _addConsoleLog("❌ '$target' is not a valid branch or commit ID.");
        }
      } else {
        _addConsoleLog(
            "❌ Invalid checkout syntax. Use: git checkout <branch|commit_id>");
      }
    } else if (trimmed.startsWith('git merge')) {
      final parts = trimmed.split(' ');
      if (parts.length == 3) {
        final mergeBranch = parts[2];
        if (!branches.contains(mergeBranch)) {
          _addConsoleLog("❌ Branch '$mergeBranch' does not exist.");
        } else {
          final mergeHead = branchHeads[mergeBranch];
          if (mergeHead == null) {
            _addConsoleLog("❌ Branch '$mergeBranch' has no commits.");
          } else {
            final id = "c$nodeCount";
            nodeCount++;
            final int branchIndex = branches.indexOf(currentBranch);
            double nextX = (branchXOffsets[currentBranch] ?? 100) + 80;
            branchXOffsets[currentBranch] = nextX;
            final Offset pos = Offset(nextX, 100 + branchIndex * 100);

            final GitNode mergeCommit = GitNode(
              id: id,
              message: "Merge branch '$mergeBranch'",
              parentIds: [headId, mergeHead],
              branch: currentBranch,
              position: pos,
            );

            _pushUndo();
            setState(() {
              nodes.add(mergeCommit);
              headId = id;
              branchHeads[currentBranch] = id;
            });

            _addConsoleLog(
                "🔀 Merged branch '$mergeBranch' into '$currentBranch'.");
          }
        }
      } else {
        _addConsoleLog("❌ Invalid merge syntax. Use: git merge branch_name");
      }
    } else if (trimmed == 'git log') {
      for (var node in nodes.reversed) {
        _addConsoleLog("[$currentBranch] ${node.id}: ${node.message}");
      }
    } else if (trimmed == 'git status') {
      _addConsoleLog(
          "📝 On branch '$currentBranch'. Last commit: ${branchHeads[currentBranch] ?? "None"}");
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
    final match = RegExp(r'git commit -m\s+\"(.+?)\"').firstMatch(input);
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
      branchXOffsets.clear();
      headId = "";
      suggestions.clear();
      controller.clear();
      consoleLog.clear();
      error = null;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(!isInitialized
            ? "Gitly: Git Graph Visualizer"
            : "Gitly: On '$currentBranch'"),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _resetSimulation),
          IconButton(
            icon: Icon(isDarkTheme ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => setState(() => isDarkTheme = !isDarkTheme),
          ),
        ],
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
                      suggestions = gitCommands
                          .where((cmd) => cmd.startsWith(val))
                          .toList();
                    });
                  },
                  onSubmitted: _handleCommand,
                  decoration: InputDecoration(
                    labelText: isInitialized
                        ? "Enter Git command"
                        : "Run 'git init' to begin",
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
            child: InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 2.5,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: GitGraphPainter(
                        nodes: nodes, headId: headId, branchHeads: branchHeads),
                    child: Container(),
                  ),
                  ...nodes.map((node) {
                    return Positioned(
                      left: node.position.dx - 10,
                      top: node.position.dy - 10,
                      child: Tooltip(
                        message: node.id,
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: node.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('📋 Copied commit ID: ${node.id}')),
                            );
                          },
                          child: Container(
                              width: 20, height: 20, color: Colors.transparent),
                        ),
                      ),
                    );
                  }),
                ],
              ),
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
                  return Text(consoleLog[index],
                      style: const TextStyle(fontSize: 12));
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
  final Map<String, String> branchHeads;

  GitGraphPainter(
      {required this.nodes, required this.headId, required this.branchHeads});

  @override
  void paint(Canvas canvas, Size size) {
    final nodePaint = Paint()..color = Colors.yellow;
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    for (var node in nodes) {
      for (var parentId in node.parentIds) {
        final parent =
            nodes.firstWhere((n) => n.id == parentId, orElse: () => node);
        canvas.drawLine(parent.position, node.position, linePaint);
      }
      canvas.drawRect(
          Rect.fromCenter(center: node.position, width: 20, height: 20),
          nodePaint);

      final textPainter = TextPainter(
        text: TextSpan(
            text: node.message,
            style: TextStyle(color: Colors.white, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: 150);
      textPainter.paint(canvas, node.position + Offset(10, -10));
    }

    for (var entry in branchHeads.entries) {
      final branch = entry.key;
      final commitId = entry.value;
      final node = nodes.firstWhere((n) => n.id == commitId);
      final labelPainter = TextPainter(
        text: TextSpan(
            text: branch, style: TextStyle(color: Colors.green, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(canvas, node.position + Offset(20, 0));
    }

    if (headId.isNotEmpty && nodes.any((n) => n.id == headId)) {
      final headNode = nodes.firstWhere((n) => n.id == headId);
      final headPaint = Paint()..color = Colors.cyan;
      canvas.drawCircle(headNode.position + Offset(0, -30), 8, headPaint);

      final labelPainter = TextPainter(
        text: TextSpan(
          text: 'HEAD',
          style: TextStyle(
              color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout(minWidth: 0, maxWidth: 100);
      labelPainter.paint(canvas, headNode.position + Offset(-20, -45));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
