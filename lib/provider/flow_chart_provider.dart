import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

// Enum for node types (Rectangle, Circle, Diamond)
enum NodeType { rectangle, circle, diamond }

class FlowNode {
  final int id;
  String label;
  Offset position;
  double width;
  double height;
  bool isSelected;
  NodeType nodeType;

  FlowNode({
    required this.id,
    required this.position,
    this.label = "Node",
    this.width = 120.0,
    this.height = 60.0,
    this.isSelected = false,
    this.nodeType = NodeType.rectangle,
  });
}

class Connection {
  final FlowNode from;
  final FlowNode to;

  Connection({required this.from, required this.to});
}

class FlowChartProvider extends ChangeNotifier {
  List<FlowNode> nodes = [];
  List<Connection> connections = [];
  FlowNode? startNode;
  int nodeCounter = 0;

  FlowChartProvider() {
    _loadTemplate();
  }

  void _loadTemplate() {
    nodes = [
      FlowNode(id: nodeCounter++, position: Offset(50, 100), label: "Start"),
      FlowNode(id: nodeCounter++, position: Offset(250, 100), label: "Process"),
      FlowNode(id: nodeCounter++, position: Offset(450, 100), label: "End"),
    ];
    connections = [
      Connection(from: nodes[0], to: nodes[1]),
      Connection(from: nodes[1], to: nodes[2]),
    ];
    notifyListeners();
  }

  // Handle node tap (to create connections between nodes)
  void handleNodeTap(FlowNode node) {
    if (startNode == null) {
      startNode = node;
      node.isSelected = true;
      notifyListeners();
    } else {
      connections.add(Connection(from: startNode!, to: node));
      startNode!.isSelected = false;
      node.isSelected = false;
      startNode = null;
      notifyListeners();
    }
  }

  // Add new node
  void addNode() {
    nodes.add(FlowNode(id: nodeCounter++, position: Offset(100, 200), label: "Node $nodeCounter"));
    notifyListeners();
  }

  // Delete a node and its connections
  void deleteNode(FlowNode node) {
    nodes.remove(node);
    connections.removeWhere((connection) => connection.from == node || connection.to == node);
    notifyListeners();
  }

  // Resize a node
  void resizeNode(FlowNode node, Offset resizePosition) {
    node.width = resizePosition.dx;
    node.height = resizePosition.dy;
    notifyListeners();
  }

  // Update node position when dragging
  void updateNodePosition(FlowNode node, Offset newPosition) {
    node.position = newPosition;
    notifyListeners();
  }

  // Edit label of a node
  void editNodeLabel(FlowNode node, String newLabel) {
    node.label = newLabel;
    notifyListeners();
  }

  // Serialize flowchart to JSON format
  String serializeFlowchart() {
    final nodesJson = nodes.map((node) {
      return {
        'id': node.id,
        'label': node.label,
        'position': {'dx': node.position.dx, 'dy': node.position.dy},
        'width': node.width,
        'height': node.height,
        'type': node.nodeType.toString(),
      };
    }).toList();

    final connectionsJson = connections.map((connection) {
      return {
        'from': connection.from.id,
        'to': connection.to.id,
      };
    }).toList();

    return jsonEncode({'nodes': nodesJson, 'connections': connectionsJson});
  }

  // Deserialize flowchart from JSON format
  void deserializeFlowchart(String jsonData) {
    final json = jsonDecode(jsonData);
    nodes = (json['nodes'] as List).map((nodeData) {
      return FlowNode(
        id: nodeData['id'],
        label: nodeData['label'],
        position: Offset(nodeData['position']['dx'], nodeData['position']['dy']),
        width: nodeData['width'],
        height: nodeData['height'],
        nodeType: NodeType.values.firstWhere((e) => e.toString() == nodeData['type']),
      );
    }).toList();

    connections = (json['connections'] as List).map((connectionData) {
      final fromNode = nodes.firstWhere((node) => node.id == connectionData['from']);
      final toNode = nodes.firstWhere((node) => node.id == connectionData['to']);
      return Connection(from: fromNode, to: toNode);
    }).toList();

    notifyListeners();
  }
}
