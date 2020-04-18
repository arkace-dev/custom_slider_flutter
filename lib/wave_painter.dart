import 'dart:ui';

import 'package:flutter/material.dart';

import './wavy_slider.dart';

class WavyLineDefinitions {
  final double startOfBezier;
  final double endOfBezier;
  final double startOfBend;
  final double endOfBend;
  double controlHeight;
  final double centerPoint;
  final double leftControlPoint1;
  final double leftControlPoint2;
  final double rightControlPoint1;
  final double rightControlPoint2;

  WavyLineDefinitions({
    this.endOfBezier,
    this.startOfBend,
    this.startOfBezier,
    this.endOfBend,
    this.controlHeight,
    this.centerPoint,
    this.leftControlPoint1,
    this.leftControlPoint2,
    this.rightControlPoint1,
    this.rightControlPoint2,
  });
}

class WavePainter extends CustomPainter {
  final double sliderPosition;
  final double dragPercentage;
  final Color color;

  final Paint fillPainter;
  final Paint wavePainter;

  double _previousSliderPosition = 0.0;

  final double animationProgress;

  final SliderState sliderState;

  WavePainter({
    @required this.sliderPosition,
    @required this.dragPercentage,
    this.color = Colors.black,
    @required this.animationProgress,
    @required this.sliderState,
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
  }

  WavyLineDefinitions _calcWavyLineDefinitions(Size size) {
    double minHeight = size.height * 0.2;
    double maxHeight = size.height * 0.8;

    double controlHeight =
        (size.height - minHeight) - (maxHeight * dragPercentage);

    double bendWidth = 20.0 + 20.0 * dragPercentage;
    double bezierWidth = 20.0 + 20.0 * dragPercentage;

    double centerPoint = sliderPosition;
    centerPoint = centerPoint > sliderPosition ? size.width : centerPoint;

    double startOfBend = sliderPosition - bendWidth / 2;
    double startOfBezier = sliderPosition - bezierWidth;
    double endOfBend = sliderPosition + bendWidth / 2;
    double endOfBezier = sliderPosition + bezierWidth;

    startOfBend = startOfBend <= 0.0 ? 0.0 : startOfBend;
    startOfBezier = startOfBezier <= 0.0 ? 0.0 : startOfBezier;
    endOfBend = endOfBend >= size.width ? size.width : endOfBend;
    endOfBezier = endOfBezier > size.width ? size.width : endOfBezier;

    double leftControlPoint1 = startOfBend;
    double leftControlPoint2 = startOfBend;
    double rightControlPoint1 = endOfBend;
    double rightControlPoint2 = endOfBend;

    double bendability = 25.0;
    double maxSlideDifference = 30.0;

    double slideDifference = (sliderPosition - _previousSliderPosition).abs();

    slideDifference = slideDifference > maxSlideDifference
        ? maxSlideDifference
        : slideDifference;

    bool moveLeft = sliderPosition < _previousSliderPosition;

    double bend =
        lerpDouble(0.0, bendability, slideDifference / maxSlideDifference);

    bend = moveLeft ? -bend : bend;

    leftControlPoint1 += bend;
    leftControlPoint2 -= bend;
    rightControlPoint1 -= bend;
    rightControlPoint2 += bend;
    centerPoint -= bend;

    WavyLineDefinitions wavyLineDefinitions = WavyLineDefinitions(
      centerPoint: centerPoint,
      controlHeight: controlHeight,
      endOfBend: endOfBend,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftControlPoint1,
      leftControlPoint2: leftControlPoint2,
      rightControlPoint1: rightControlPoint1,
      rightControlPoint2: rightControlPoint2,
      startOfBend: startOfBend,
      startOfBezier: startOfBezier,
    );

    return wavyLineDefinitions;
  }

  void _paintWavyLine(
    Canvas canvas,
    Size size,
    WavyLineDefinitions definitions,
  ) {
    Path path = Path()
      ..moveTo(0.0, size.height)
      ..lineTo(definitions.startOfBezier, size.height)
      ..cubicTo(
          definitions.leftControlPoint1,
          size.height,
          definitions.leftControlPoint2,
          definitions.controlHeight,
          definitions.centerPoint,
          definitions.controlHeight)
      ..cubicTo(
          definitions.rightControlPoint1,
          definitions.controlHeight,
          definitions.rightControlPoint2,
          size.height,
          definitions.endOfBezier,
          size.height)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  void _paintStartUpWave(Canvas canvas, Size size) {
    WavyLineDefinitions line = _calcWavyLineDefinitions(size);
    double waveHeight = lerpDouble(size.height, line.controlHeight,
        Curves.elasticOut.transform(animationProgress));
    line.controlHeight = waveHeight;

    _paintWavyLine(canvas, size, line);
  }

  void _paintRestingWave(Canvas canvas, Size size) {
    Path path = Path()
      ..moveTo(0.0, size.height)
      ..lineTo(size.width, size.height);
    canvas.drawPath(path, wavePainter);
  }

  void _paintSlidingWave(Canvas canvas, Size size) {
    WavyLineDefinitions definitions = _calcWavyLineDefinitions(size);
    _paintWavyLine(canvas, size, definitions);
  }

  void _paintStoppingWave(Canvas canvas, Size size) {
    WavyLineDefinitions line = _calcWavyLineDefinitions(size);
    double waveHeight = lerpDouble(line.controlHeight, size.height,
        Curves.elasticOut.transform(animationProgress));
    line.controlHeight = waveHeight;

    _paintWavyLine(canvas, size, line);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);

    switch (sliderState) {
      case SliderState.starting:
        _paintStartUpWave(canvas, size);
        break;
      case SliderState.resting:
        _paintRestingWave(canvas, size);
        break;
      case SliderState.sliding:
        _paintSlidingWave(canvas, size);
        break;
      case SliderState.stopping:
        _paintStoppingWave(canvas, size);
        break;
      default:
        _paintRestingWave(canvas, size);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    _previousSliderPosition = oldDelegate.sliderPosition;
    return true;
  }
}
