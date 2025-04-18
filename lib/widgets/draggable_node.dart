import 'package:biftech/provider/flow_chart_provider.dart';
import 'package:flutter/material.dart';

class DraggableNode extends StatelessWidget {
  final FlowNode node;
  final Function(Offset) onResize;
  final VoidCallback onDelete;
  final VoidCallback onEditLabel;

  const DraggableNode({super.key,
    required this.node,
    required this.onResize,
    required this.onDelete,
    required this.onEditLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: node.width,
          height: node.height,
          decoration: BoxDecoration(
            color: node.isSelected ? Colors.blueAccent : Colors.blue,
            shape:
            node.nodeType == NodeType.circle
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius:
            node.nodeType == NodeType.diamond
                ? BorderRadius.circular(12)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            node.label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Positioned(
          top: -10,
          right: -10,
          child: GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: GestureDetector(
            onTap: onEditLabel,
            child: Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ),
        Positioned(
          bottom: -8,
          right: -8,
          child: GestureDetector(
            onPanUpdate: (details) {
              onResize(details.localPosition);
            },
            child: Container(width: 16, height: 16, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
