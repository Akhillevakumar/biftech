import 'package:biftech/provider/flow_chart_provider.dart';
import 'package:biftech/services/database_helper.dart';
import 'package:biftech/widgets/draggable_node.dart';
import 'package:biftech/widgets/painters/line_painter.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';

class FlowChartScreen extends StatefulWidget {
  final int videoId;
  const FlowChartScreen({super.key, required this.videoId});

  @override
  _FlowChartScreenState createState() => _FlowChartScreenState();
}

class _FlowChartScreenState extends State<FlowChartScreen> {
  @override
  void initState() {
    super.initState();
     _loadFlowchart();
  }

   Future<void> _loadFlowchart() async {
    final dbHelper = DatabaseHelper();
    final jsonFlowchart = await dbHelper.getFlowchart(widget.videoId);

    if (jsonFlowchart != null) {
       Provider.of<FlowChartProvider>(
        context,
        listen: false,
      ).deserializeFlowchart(jsonFlowchart);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FlowChartProvider>(
      builder: (context, flowChartProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Flowchart Editor"),
            actions: [
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                   String jsonFlowchart = flowChartProvider.serializeFlowchart();
                   final dbHelper = DatabaseHelper();
                  await dbHelper.insertFlowchart(widget.videoId, jsonFlowchart);
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Stack(
                    children: [
                       for (var connection in flowChartProvider.connections)
                        CustomPaint(
                          size: Size(
                            constraints.maxWidth,
                            constraints.maxHeight,
                          ),
                          painter: LinePainter(connection),
                        ),
                       for (var node in flowChartProvider.nodes)
                        Positioned(
                          left: node.position.dx,
                          top: node.position.dy,
                          child: GestureDetector(
                            onTap: () => flowChartProvider.handleNodeTap(node),
                            onPanUpdate: (details) {
                               flowChartProvider.updateNodePosition(
                                node,
                                details.localPosition,
                              );
                            },
                            child: DraggableNode(
                              node: node,
                              onResize: (resizePosition) {
                                flowChartProvider.resizeNode(
                                  node,
                                  resizePosition,
                                );
                              },
                              onDelete:
                                  () => flowChartProvider.deleteNode(node),
                              onEditLabel: () {
                                flowChartProvider.editNodeLabel(
                                  node,
                                  "Edited Node ${node.id}",
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: flowChartProvider.addNode,
            tooltip: 'Add Node',
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

 }


