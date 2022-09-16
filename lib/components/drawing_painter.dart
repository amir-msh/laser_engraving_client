import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PaintingSession {
  final List<Offset> points;
  final double strokeWidth;
  PaintingSession({
    List<Offset>? points,
    required this.strokeWidth,
  }) : points = points ?? [];
}

class DrawingPainter extends CustomPainter {
  final PaintingSessions sessions;
  final bool invert;
  static const backgroundColor = Colors.white;
  static const foregroundColor = Colors.black;
  static final drawingPaint = Paint()
    ..color = foregroundColor
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = false;

  DrawingPainter({
    required this.sessions,
    this.invert = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(
      invert ? foregroundColor : backgroundColor,
      BlendMode.src,
    );
    drawingPaint.color = invert ? backgroundColor : foregroundColor;
    for (var session in sessions) {
      drawingPaint.strokeWidth = session.strokeWidth;
      canvas.drawPoints(
        PointMode.polygon,
        session.points,
        drawingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

typedef PaintingSessions = List<PaintingSession>;

// ignore: must_be_immutable
class PaintingData extends Equatable {
  final PaintingSessions paintingSessions;
  bool invert;

  PaintingData({
    PaintingSessions? paintingSessions,
    this.invert = false,
  }) : paintingSessions = paintingSessions ?? [];

  @override
  List<Object> get props => [invert, paintingSessions];
}

class PaintingNotifier extends ChangeNotifier
    implements ValueListenable<PaintingData> {
  final PaintingData _value;

  PaintingNotifier([PaintingData? value]) : _value = value ?? PaintingData();

  void addPoint(Offset offset, double strokeWidth) {
    if (_value.paintingSessions.isEmpty) {
      addNewSession(strokeWidth);
    }
    _value.paintingSessions.last.points.add(offset);
    notifyListeners();
  }

  void addNewSession(double strokeWidth) {
    _value.paintingSessions.add(
      PaintingSession(
        strokeWidth: strokeWidth,
      ),
    );
    notifyListeners();
  }

  void undo() {
    if (_value.paintingSessions.isEmpty) return;
    _value.paintingSessions.removeLast();
    notifyListeners();
  }

  void clear() {
    _value.paintingSessions.clear();
    notifyListeners();
  }

  bool get invert => _value.invert;
  set invert(bool newValue) {
    _value.invert = newValue;
    notifyListeners();
  }

  @override
  PaintingData get value => _value;

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
