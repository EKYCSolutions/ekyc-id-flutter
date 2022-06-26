import 'dart:math';
import 'dart:math' as math;
import 'package:ekyc_id_flutter/core/utils/interpolate.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';


final Interpolate progressMapping = Interpolate(
  inputRange: [0, 1],
  outputRange: [-90, 270],
  extrapolate: Extrapolate.clamp,
);

class FaceCutOut extends StatefulWidget {
  const FaceCutOut({
    Key? key,
    this.progress = 0,
    this.isFocusing = false,
    required this.cutOutSize,
  }) : super(key: key);

  final bool isFocusing;
  final double progress;
  final double cutOutSize;

  @override
  _FaceCutOutState createState() => _FaceCutOutState();
}

class _FaceCutOutState extends State<FaceCutOut>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() => setState(() {}));

    if (widget.isFocusing) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FaceCutOut oldWidget) {
    if (widget.isFocusing != oldWidget.isFocusing) {
      if (widget.isFocusing) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FaceCutOutPainter(
        progress: widget.progress,
        cutOutSize: widget.cutOutSize,
        cutOutRadius: Tween(begin: 5.0, end: widget.cutOutSize / 2)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.easeInOutExpo),
              ),
            )
            .value,
        backgroundColor: ColorTween(
          begin: Colors.black.withOpacity(0.4),
          end: Colors.black,
        ).animate(_controller).value!,
        borderColor: ColorTween(
          begin: Colors.white,
          end: Colors.transparent,
        ).animate(_controller).value!,
        progressRingRadius: Tween(
                begin: (widget.cutOutSize / 2) * 2, end: widget.cutOutSize / 2)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 1.0, curve: Curves.easeInOutExpo),
              ),
            )
            .value,
        progressRingColor: Colors.white,
        progressRingActiveColor: Colors.green,
        progressRingOpacity: Tween(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(0.5, 1.0, curve: Curves.easeInOutExpo),
              ),
            )
            .value,
      ),
    );
  }
}

class FaceCutOutPainter extends CustomPainter {
  FaceCutOutPainter({
    this.progress = 0,
    required this.borderColor,
    required this.cutOutSize,
    required this.cutOutRadius,
    required this.backgroundColor,
    required this.progressRingColor,
    required this.progressRingRadius,
    required this.progressRingOpacity,
    required this.progressRingActiveColor,
  });

  double progress;
  Color borderColor;
  double cutOutSize;
  double cutOutRadius;
  Color backgroundColor;
  Color progressRingColor;
  double progressRingRadius;
  double progressRingOpacity;
  Color progressRingActiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCutOut(canvas, size);
    _drawBorder(canvas, size);
    _drawProgressRing(canvas, size);
  }

  void _drawProgressRing(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = progressRingColor.withOpacity(progressRingOpacity);
    paint.strokeWidth = 2;
    paint.strokeCap = StrokeCap.round;

    final activePaint = Paint();
    activePaint.color =
        progressRingActiveColor.withOpacity(progressRingOpacity);
    activePaint.strokeWidth = 2;
    activePaint.strokeCap = StrokeCap.round;

    const int step = 2;
    const int tickerHeight = 10;
    const int tickerHeight2 = 5;

    Offset origin = Offset(size.width / 2, size.height / 2);

    for (int i = -90; i < 270; i += step) {
      double pDegree = progressMapping.eval(progress);
      if (i != -90 && pDegree >= i || pDegree == 270) {
        double x1 = progressRingRadius * cos(getRadian(i.toDouble()));
        double x2 =
            (progressRingRadius + tickerHeight) * cos(getRadian(i.toDouble()));
        double y1 = progressRingRadius * sin(getRadian(i.toDouble()));
        double y2 =
            (progressRingRadius + tickerHeight) * sin(getRadian(i.toDouble()));
        canvas.drawLine(Offset(origin.dx + x1, origin.dy + y1),
            Offset(origin.dx + x2, origin.dy + y2), activePaint);
      } else {
        double x1 = progressRingRadius * cos(getRadian(i.toDouble()));
        double x2 =
            (progressRingRadius + tickerHeight2) * cos(getRadian(i.toDouble()));
        double y1 = progressRingRadius * sin(getRadian(i.toDouble()));
        double y2 =
            (progressRingRadius + tickerHeight2) * sin(getRadian(i.toDouble()));
        canvas.drawLine(Offset(origin.dx + x1, origin.dy + y1),
            Offset(origin.dx + x2, origin.dy + y2), paint);
      }
    }
  }

  void _drawBorder(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = borderColor;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    Offset origin = Offset(size.width / 2, size.height / 2);

    canvas.drawRRect(
      RRect.fromLTRBR(
        origin.dx - (cutOutSize / 2),
        origin.dy - (cutOutSize / 2),
        origin.dx + (cutOutSize / 2),
        origin.dy + (cutOutSize / 2),
        Radius.circular(cutOutRadius),
      ),
      paint,
    );
  }

  void _drawCutOut(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = backgroundColor;
    Offset origin = Offset(size.width / 2, size.height / 2);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addRRect(
            RRect.fromLTRBR(
              0,
              0,
              size.width,
              size.height,
              Radius.zero,
            ),
          ),
        Path()
          ..addRRect(
            RRect.fromLTRBR(
              origin.dx - (cutOutSize / 2),
              origin.dy - (cutOutSize / 2),
              origin.dx + (cutOutSize / 2),
              origin.dy + (cutOutSize / 2),
              Radius.circular(cutOutRadius),
            ),
          )
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double angle) => math.pi / 180 * angle;
}
