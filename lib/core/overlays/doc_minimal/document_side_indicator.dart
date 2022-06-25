import 'dart:math' as math;

// import 'package:ekyc_demo_app/config/theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class DocumentSideIndicator extends StatefulWidget {
  const DocumentSideIndicator({
    Key? key,
    this.size = 50.0,
  }) : super(key: key);

  final double size;

  @override
  _DocumentSideIndicatorState createState() => _DocumentSideIndicatorState();
}

class _DocumentSideIndicatorState extends State<DocumentSideIndicator>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() => setState(() {}))
          ..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
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
    return Container(
      width: widget.size + 10,
      height: widget.size * 0.56 + 10,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Transform(
          transform: Matrix4.identity()
            ..rotateY((_animation.value) * math.pi * 1),
          alignment: FractionalOffset.center,
          child: CustomPaint(
            child:
                SizedBox.fromSize(size: Size(widget.size, widget.size * 0.56)),
            painter: _DocumentSideIndicatorPainter(
              color: Colors.white,
              // color: COLOR_SCHEME_DARK.onBackground,
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentSideIndicatorPainter extends CustomPainter {
  _DocumentSideIndicatorPainter({
    required this.color,
  });

  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    Paint painter = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    Paint infoPainter = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(5)),
        painter);
    canvas.drawRRect(
        RRect.fromLTRBR(5, 5, 20, 20, Radius.circular(2)), painter);
    canvas.drawRRect(
        RRect.fromLTRBR(
            size.width - 25, 5, size.width - 5, 7, Radius.circular(0)),
        infoPainter);
    canvas.drawRRect(
        RRect.fromLTRBR(
            size.width - 25, 9, size.width - 5, 11, Radius.circular(0)),
        infoPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;

  double getRadian(double a) => math.pi / 180 * a;
}
