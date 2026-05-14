import 'package:flutter/material.dart';

/// Paints a musical rest of the specified type.
/// [restType]: whole, half, quarter, eighth, sixteenth
class RestsPainter extends CustomPainter {
  final String restType;
  final Color color;

  RestsPainter({required this.restType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (restType) {
      case 'whole':
        drawWholeRest(canvas, cx, cy, size, paint);
        break;
      case 'half':
        drawHalfRest(canvas, cx, cy, size, paint);
        break;
      case 'quarter':
        drawQuarterRest(canvas, cx, cy, size, paint);
        break;
      case 'eighth':
        drawEighthRest(canvas, cx, cy, size, paint);
        break;
      case 'sixteenth':
        drawSixteenthRest(canvas, cx, cy, size, paint);
        break;
    }
  }

  void drawWholeRest(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Whole rest: rectangle hanging below a line
    final lineY = cy - size.height * 0.1;
    final rectWidth = size.width * 0.3;
    final rectHeight = size.height * 0.1;

    // Staff line
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - rectWidth * 0.8, lineY),
      Offset(cx + rectWidth * 0.8, lineY),
      paint,
    );

    // Hanging rectangle
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx - rectWidth / 2, lineY, rectWidth, rectHeight),
      paint,
    );
  }

  void drawHalfRest(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Half rest: rectangle sitting on top of a line
    final lineY = cy + size.height * 0.05;
    final rectWidth = size.width * 0.3;
    final rectHeight = size.height * 0.1;

    // Staff line
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(cx - rectWidth * 0.8, lineY),
      Offset(cx + rectWidth * 0.8, lineY),
      paint,
    );

    // Sitting rectangle
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
          cx - rectWidth / 2, lineY - rectHeight, rectWidth, rectHeight),
      paint,
    );
  }

  void drawQuarterRest(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Quarter rest: zigzag shape
    final h = size.height * 0.5;
    final top = cy - h / 2;
    final w = size.width * 0.15;

    final path = Path()
      ..moveTo(cx + w, top)
      ..lineTo(cx - w, top + h * 0.25)
      ..lineTo(cx + w, top + h * 0.5)
      ..lineTo(cx - w, top + h * 0.75)
      ..lineTo(cx + w, top + h);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    paint.strokeCap = StrokeCap.round;
    canvas.drawPath(path, paint);
  }

  void drawEighthRest(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Eighth rest: dot with a curved line
    final h = size.height * 0.35;
    final top = cy - h / 2;

    // Dot
    canvas.drawCircle(Offset(cx + size.width * 0.05, top), 3.5, paint);

    // Curved stem
    final path = Path()
      ..moveTo(cx + size.width * 0.05, top + 3)
      ..cubicTo(
        cx - size.width * 0.1,
        top + h * 0.4,
        cx + size.width * 0.05,
        top + h * 0.6,
        cx - size.width * 0.05,
        top + h,
      );

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(path, paint);
  }

  void drawSixteenthRest(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Sixteenth rest: two dots with curved line
    final h = size.height * 0.45;
    final top = cy - h / 2;

    // Two dots
    canvas.drawCircle(Offset(cx + size.width * 0.05, top), 3.5, paint);
    canvas.drawCircle(
        Offset(cx + size.width * 0.08, top + h * 0.3), 3.5, paint);

    // Curved stem
    final path = Path()
      ..moveTo(cx + size.width * 0.05, top + 3)
      ..cubicTo(
        cx - size.width * 0.1,
        top + h * 0.4,
        cx + size.width * 0.05,
        top + h * 0.6,
        cx - size.width * 0.05,
        top + h,
      );

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RestsPainter oldDelegate) =>
      restType != oldDelegate.restType || color != oldDelegate.color;
}

/// Widget wrapper for RestsPainter
class RestWidget extends StatelessWidget {
  final String restType;
  final double size;
  final Color color;

  const RestWidget({
    Key? key,
    required this.restType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RestsPainter(restType: restType, color: color),
      size: Size(size, size * 1.5),
    );
  }
}
