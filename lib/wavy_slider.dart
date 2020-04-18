import 'package:flutter/material.dart';

import './wave_painter.dart';

enum SliderState {
  starting,
  sliding,
  stopping,
  resting,
}

class WavySlider extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  final ValueChanged<double> onChangedStart;
  final ValueChanged<double> onChangedUpdate;

  const WavySlider({
    this.width = 350,
    this.height = 50,
    this.color = Colors.black,
    @required this.onChangedUpdate,
    @required this.onChangedStart,
  }) : assert(height >= 50 && height <= 600);

  @override
  _WavySliderState createState() => _WavySliderState();
}

class _WavySliderState extends State<WavySlider>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  double _dragPercentage = 0;

  WavySliderController _silderController;

  @override
  void initState() {
    super.initState();
    _silderController = WavySliderController(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _silderController.dispose();
  }

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

  void _handleChangeUpdate(double val) {
    assert(widget.onChangedUpdate != null);
    widget.onChangedUpdate(val);
  }

  void _handleChangeStart(double val) {
    assert(widget.onChangedStart != null);
    widget.onChangedStart(val);
  }

  void _onHorizontalDragUpdate(BuildContext context, DragUpdateDetails update) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(update.globalPosition);
    _silderController.setStateToSliding();
    _updateDragPosition(offset);
    _handleChangeUpdate(_dragPercentage);
  }

  void _onHorizontalDragStart(BuildContext context, DragStartDetails start) {
    RenderBox box = context.findRenderObject();
    Offset offset = box.globalToLocal(start.globalPosition);
    _silderController.setStateToStarting();
    _updateDragPosition(offset);
    _handleChangeStart(_dragPercentage);
  }

  void _onHorizontalDragEnd(BuildContext context, DragEndDetails end) {
    _silderController.setStateToStopping();
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
              animationProgress: _silderController.progress,
              sliderState: _silderController.state,
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

class WavySliderController extends ChangeNotifier {
  final AnimationController animationController;
  SliderState _sliderState = SliderState.resting;

  WavySliderController({@required TickerProvider vsync})
      : animationController = AnimationController(vsync: vsync) {
    animationController
      ..addListener(_onProgressUpdate)
      ..addStatusListener(_onStatusUpdate);
  }

  double get progress => animationController.value;

  SliderState get state => _sliderState;

  void _onProgressUpdate() {
    notifyListeners();
  }

  void _onStatusUpdate(AnimationStatus status) {
    if (status == AnimationStatus.completed) _onTransitionCompleted();
  }

  void _onTransitionCompleted() {
    if (_sliderState == SliderState.stopping) setStateToResting();
  }

  void _startAnimation() {
    animationController
      ..duration = Duration(milliseconds: 500)
      ..forward(from: 0.0);
    notifyListeners();
  }

  void setStateToResting() {
    _sliderState = SliderState.resting;
  }

  void setStateToStarting() {
    _startAnimation();
    _sliderState = SliderState.starting;
  }

  void setStateToSliding() {
    _sliderState = SliderState.sliding;
  }

  void setStateToStopping() {
    _startAnimation();
    _sliderState = SliderState.stopping;
  }
}
