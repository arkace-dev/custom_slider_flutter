import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final Color color;

  final Paint fillPainter;
  final Paint wavePainter;

  WavePainter({
    @required this.sliderPosition,
    @required this.dragPercentage,
    this.color = Colors.black,
  })  : fillPainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill,
        wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;

  void _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, size.height), 5.0, fillPainter);
    canvas.drawCircle(Offset(size.width, size.height), 5.0, fillPainter);
    _paintLine(canvas, size);
    _paintBox(canvas, size);
  }

  void _paintLine(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(0.0, size.height)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  void _paintBox(Canvas canvas, Size size) {
    Rect sliderRect =
        Offset(sliderPosition, size.height - 5.0) & Size(3.0, 10.0);
    canvas.drawRect(sliderRect, fillPainter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
