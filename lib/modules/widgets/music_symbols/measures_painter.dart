import 'package:flutter/material.dart';

/// Paints a barline/measure marking.
/// [barlineType]: single, double, final, repeatStart, repeatEnd, repeatBoth
class MeasuresPainter extends CustomPainter {
  final String barlineType;
  final Color color;

  MeasuresPainter({required this.barlineType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    final staffTop = size.height * 0.2;
    final staffHeight = size.height * 0.6;
    final lineSpacing = staffHeight / 4;
    final cx = size.width / 2;

    // Draw 5 staff lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    for (var i = 0; i < 5; i++) {
      final y = staffTop + i * lineSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw barline
    switch (barlineType) {
      case 'single':
        drawSingle(canvas, cx, staffTop, staffHeight, paint);
        break;
      case 'double':
        drawDouble(canvas, cx, staffTop, staffHeight, paint);
        break;
      case 'final':
        drawFinal(canvas, cx, staffTop, staffHeight, paint);
        break;
      case 'repeatStart':
        drawRepeatStart(canvas, cx, staffTop, staffHeight, paint);
        break;
      case 'repeatEnd':
        drawRepeatEnd(canvas, cx, staffTop, staffHeight, paint);
        break;
      case 'repeatBoth':
        drawRepeatBoth(canvas, cx, staffTop, staffHeight, paint);
        break;
    }
  }

  void drawSingle(Canvas canvas, double cx, double top, double h, Paint paint) {
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx, top), Offset(cx, top + h), paint);
  }

  void drawDouble(Canvas canvas, double cx, double top, double h, Paint paint) {
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 4, top), Offset(cx - 4, top + h), paint);
    canvas.drawLine(Offset(cx + 4, top), Offset(cx + 4, top + h), paint);
  }

  void drawFinal(Canvas canvas, double cx, double top, double h, Paint paint) {
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 5, top), Offset(cx - 5, top + h), paint);
    paint.strokeWidth = 4.0;
    canvas.drawLine(Offset(cx + 4, top), Offset(cx + 4, top + h), paint);
  }

  void drawRepeatStart(
      Canvas canvas, double cx, double top, double h, Paint paint) {
    paint.strokeWidth = 4.0;
    canvas.drawLine(Offset(cx - 6, top), Offset(cx - 6, top + h), paint);
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx + 2, top), Offset(cx + 2, top + h), paint);
    // Dots
    paint.style = PaintingStyle.fill;
    final dotX = cx + 10;
    canvas.drawCircle(Offset(dotX, top + h * 0.37), 3, paint);
    canvas.drawCircle(Offset(dotX, top + h * 0.63), 3, paint);
  }

  void drawRepeatEnd(
      Canvas canvas, double cx, double top, double h, Paint paint) {
    // Dots
    paint.style = PaintingStyle.fill;
    final dotX = cx - 10;
    canvas.drawCircle(Offset(dotX, top + h * 0.37), 3, paint);
    canvas.drawCircle(Offset(dotX, top + h * 0.63), 3, paint);
    // Lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - 2, top), Offset(cx - 2, top + h), paint);
    paint.strokeWidth = 4.0;
    canvas.drawLine(Offset(cx + 6, top), Offset(cx + 6, top + h), paint);
  }

  void drawRepeatBoth(
      Canvas canvas, double cx, double top, double h, Paint paint) {
    // Left dots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 14, top + h * 0.37), 3, paint);
    canvas.drawCircle(Offset(cx - 14, top + h * 0.63), 3, paint);
    // Center thick bar
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4.0;
    canvas.drawLine(Offset(cx - 2, top), Offset(cx - 2, top + h), paint);
    canvas.drawLine(Offset(cx + 2, top), Offset(cx + 2, top + h), paint);
    // Right dots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 14, top + h * 0.37), 3, paint);
    canvas.drawCircle(Offset(cx + 14, top + h * 0.63), 3, paint);
  }

  @override
  bool shouldRepaint(covariant MeasuresPainter oldDelegate) =>
      barlineType != oldDelegate.barlineType || color != oldDelegate.color;
}

/// Widget wrapper for MeasuresPainter
class MeasureWidget extends StatelessWidget {
  final String barlineType;
  final double size;
  final Color color;

  const MeasureWidget({
    Key? key,
    required this.barlineType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MeasuresPainter(barlineType: barlineType, color: color),
      size: Size(size * 1.2, size),
    );
  }
}
