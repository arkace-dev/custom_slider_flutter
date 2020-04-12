import 'package:flutter/material.dart';

import './wave_painter.dart';

class WavySlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const WavySlider({
    this.width = 350,
    this.height = 50,
    this.color = Colors.black,
  });

  @override
  _WavySliderState createState() => _WavySliderState();
}

class _WavySliderState extends State<WavySlider> {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  void _updateDragPosition(Offset offset) {
    double newDragPosition = 0;

    if (offset.dx < 0)
      newDragPosition = 0;
    else if (offset.dx > widget.width)
      newDragPosition = widget.width;
    else
      newDragPosition = offset.dx;

    setState(() {
      _dragPosition = newDragPosition;
      _dragPercentage = newDragPosition / widget.width;
    });
  }

  void _onHorizontalDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(update.globalPosition);
    _updateDragPosition(offset);
  }

  void _onHorizontalDragStart(BuildContext context, DragStartDetails start) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(start.globalPosition);
    _updateDragPosition(offset);
  }

  // TODO Remove This Function after the videos, this is useless
  void _onHorizontalDragEnd(BuildContext context, DragEndDetails end) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        child: Container(
          width: widget.width,
          height: widget.height,
          child: CustomPaint(
            painter: WavePainter(
              sliderPosition: _dragPosition,
              dragPercentage: _dragPercentage,
            ),
          ),
        ),
        onHorizontalDragUpdate: (DragUpdateDetails update) =>
            _onHorizontalDragUpdate(context, update),
        onHorizontalDragStart: (DragStartDetails start) =>
            _onHorizontalDragStart(context, start),
        onHorizontalDragEnd: (DragEndDetails end) =>
            _onHorizontalDragEnd(context, end),
      ),
    );
  }
}
