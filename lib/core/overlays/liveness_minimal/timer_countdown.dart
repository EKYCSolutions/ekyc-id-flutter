import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:interpolate/interpolate.dart';

final Interpolate progressMapping = Interpolate(
  inputRange: [0, 1],
  outputRange: [1, 0],
  extrapolate: Extrapolate.clamp,
);

class TimerCountDown extends StatefulWidget {
  const TimerCountDown({
    Key? key,
    this.current = 0,
    required this.max,
  }) : super(key: key);

  final int max;
  final int current;

  @override
  _TimerCountDownState createState() => _TimerCountDownState();
}

class _TimerCountDownState extends State<TimerCountDown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimerCountDown oldWidget) {
    if (widget.current != oldWidget.current) {
      _controller.animateTo((widget.max - widget.current) / widget.max);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TimerCountDownPainter(
        progressBarBackgroundColor:
            Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
        progressBarColor: ColorTween(
          begin: Colors.green,
          end: Colors.red,
        ).animate(_controller).value!,
        max: widget.max,
        current: widget.current,
        progress: Tween(begin: 1.0, end: 0.0)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.linear),
              ),
            )
            .value,
      ),
    );
  }
}

class TimerCountDownPainter extends CustomPainter {
  TimerCountDownPainter({
    this.current = 0,
    required this.max,
    required this.progress,
    required this.progressBarColor,
    required this.progressBarBackgroundColor,
  });

  int max;
  int current;
  double progress;
  Color progressBarColor;
  Color progressBarBackgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = progressBarBackgroundColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3;
    paint.strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    final activePaint = Paint();
    activePaint.strokeWidth = 5;
    activePaint.color = progressBarColor;
    activePaint.strokeCap = StrokeCap.round;
    activePaint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width * progress, size.height),
      activePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
