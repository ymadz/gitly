import 'package:flutter/material.dart';

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
  double yOffset = 100;
  int nodeCount = 0;

  void _addCommit(String message) {
    final String id = "c$nodeCount";
    nodeCount++;

    // Position the commit horizontally by order and vertically by branch
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
    });
  }

  int _getBranchIndex(String branchName) {
    // For now, only main branch = 0
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Gitly: Git Graph Visualizer")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Enter git commit message",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) {
                if (val.isNotEmpty) _addCommit(val);
              },
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: GitGraphPainter(nodes: nodes, headId: headId),
              child: Container(),
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
      // Draw lines to parent nodes
      for (var parentId in node.parentIds) {
        final parent = nodes.firstWhere((n) => n.id == parentId, orElse: () => node);
        canvas.drawLine(parent.position, node.position, linePaint);
      }

      // Draw commit node
      canvas.drawRect(
        Rect.fromCenter(center: node.position, width: 20, height: 20),
        nodePaint,
      );

      // Draw message text
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

    // Draw HEAD pointer
    if (headId.isNotEmpty) {
      final headNode = nodes.firstWhere((n) => n.id == headId);
      final headPaint = Paint()..color = Colors.cyan;
      canvas.drawCircle(headNode.position + const Offset(0, -30), 8, headPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
