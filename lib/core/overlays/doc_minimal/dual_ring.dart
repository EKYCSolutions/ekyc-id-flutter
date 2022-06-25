import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class DualRing extends StatefulWidget {
  const DualRing({
    Key? key,
    required this.color,
    this.lineWidth = 7.0,
    this.size = 50.0,
    this.duration = const Duration(seconds: 2),
    this.curve = Curves.elasticInOut,
  }) : super(key: key);

  final Color color;
  final double lineWidth;
  final double size;
  final Duration duration;
  final Curve curve;

  @override
  _DualRingState createState() => _DualRingState();
}

class _DualRingState extends State<DualRing> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() => setState(() {}))
      ..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: widget.curve),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..rotateZ((_animation.value) * math.pi * 2),
        alignment: FractionalOffset.center,
        child: CustomPaint(
          child: SizedBox.fromSize(size: Size.square(widget.size)),
          painter: _DualRingPainter(
              paintWidth: widget.lineWidth, color: widget.color),
        ),
      ),
    );
  }
}

class _DualRingPainter extends CustomPainter {
  _DualRingPainter(
      {this.angle = 90.0, required double paintWidth, required Color color})
      : ringPaint = Paint()
          ..color = color
          ..strokeWidth = paintWidth
          ..style = PaintingStyle.stroke;

  final Paint ringPaint;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromPoints(Offset.zero, Offset(size.width, size.height));
    canvas.drawArc(rect, getRadian(-25), getRadian(50), false, ringPaint);
    canvas.drawArc(rect, getRadian(65), getRadian(50), false, ringPaint);
    canvas.drawArc(rect, getRadian(155), getRadian(50), false, ringPaint);
    canvas.drawArc(rect, getRadian(245), getRadian(50), false, ringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double a) => math.pi / 180 * a;
}
