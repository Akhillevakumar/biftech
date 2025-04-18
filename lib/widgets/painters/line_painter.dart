import 'dart:math';

import 'package:biftech/provider/flow_chart_provider.dart';
import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Connection connection;

  LinePainter(this.connection);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
    Paint()
      ..color = Colors.black
      ..strokeWidth = 4;

    final start =
        connection.from.position + Offset(60, 30); // Center of the node
    final end = connection.to.position + Offset(60, 30); // Center of the node

    canvas.drawLine(start, end, paint);

    final arrowPaint =
    Paint()
      ..color = Colors.black
      ..strokeWidth = 6;
    _drawArrow(canvas, end, start, arrowPaint);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final angle = (end - start).direction;
    final arrowSize = 10.0;
    final arrowAngle = 0.5;

    final arrowPath =
    Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(
        start.dx - arrowSize * cos(angle - arrowAngle),
        start.dy - arrowSize * sin(angle - arrowAngle),
      )
      ..lineTo(
        start.dx - arrowSize * cos(angle + arrowAngle),
        start.dy - arrowSize * sin(angle + arrowAngle),
      )
      ..close();

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
