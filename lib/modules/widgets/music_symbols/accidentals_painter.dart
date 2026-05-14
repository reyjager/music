import 'package:flutter/material.dart';

/// Paints a musical accidental.
/// [accidentalType]: sharp, flat, natural, doubleSharp, doubleFlat
class AccidentalsPainter extends CustomPainter {
  final String accidentalType;
  final Color color;

  AccidentalsPainter({required this.accidentalType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (accidentalType) {
      case 'sharp':
        drawSharp(canvas, cx, cy, size, paint);
        break;
      case 'flat':
        drawFlat(canvas, cx, cy, size, paint);
        break;
      case 'natural':
        drawNatural(canvas, cx, cy, size, paint);
        break;
      case 'doubleSharp':
        drawDoubleSharp(canvas, cx, cy, size, paint);
        break;
      case 'doubleFlat':
        drawDoubleFlat(canvas, cx, cy, size, paint);
        break;
    }
  }

  void drawSharp(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final h = size.height * 0.5;
    final w = size.width * 0.25;

    paint.style = PaintingStyle.stroke;

    // Two vertical lines
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - w * 0.4, cy - h * 0.6),
        Offset(cx - w * 0.4, cy + h * 0.6), paint);
    canvas.drawLine(Offset(cx + w * 0.4, cy - h * 0.6),
        Offset(cx + w * 0.4, cy + h * 0.6), paint);

    // Two horizontal lines (slightly slanted)
    paint.strokeWidth = 3.0;
    canvas.drawLine(
        Offset(cx - w, cy - h * 0.2), Offset(cx + w, cy - h * 0.3), paint);
    canvas.drawLine(
        Offset(cx - w, cy + h * 0.3), Offset(cx + w, cy + h * 0.2), paint);
  }

  void drawFlat(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final h = size.height * 0.5;

    // Vertical stem
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawLine(
        Offset(cx - 4, cy - h * 0.5), Offset(cx - 4, cy + h * 0.4), paint);

    // Curved belly
    final path = Path()
      ..moveTo(cx - 4, cy + h * 0.05)
      ..cubicTo(
        cx + h * 0.25,
        cy - h * 0.1,
        cx + h * 0.25,
        cy + h * 0.3,
        cx - 4,
        cy + h * 0.4,
      );

    paint.strokeWidth = 2.0;
    canvas.drawPath(path, paint);
  }

  void drawNatural(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final h = size.height * 0.5;
    final w = size.width * 0.15;

    paint.style = PaintingStyle.stroke;

    // Left vertical (extends up)
    paint.strokeWidth = 1.5;
    canvas.drawLine(
        Offset(cx - w, cy - h * 0.5), Offset(cx - w, cy + h * 0.2), paint);

    // Right vertical (extends down)
    canvas.drawLine(
        Offset(cx + w, cy - h * 0.2), Offset(cx + w, cy + h * 0.5), paint);

    // Two horizontal connecting lines (slightly slanted)
    paint.strokeWidth = 2.5;
    canvas.drawLine(
        Offset(cx - w, cy - h * 0.15), Offset(cx + w, cy - h * 0.25), paint);
    canvas.drawLine(
        Offset(cx - w, cy + h * 0.25), Offset(cx + w, cy + h * 0.15), paint);
  }

  void drawDoubleSharp(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final s = size.width * 0.15;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;

    // X shape
    canvas.drawLine(Offset(cx - s, cy - s), Offset(cx + s, cy + s), paint);
    canvas.drawLine(Offset(cx + s, cy - s), Offset(cx - s, cy + s), paint);
  }

  void drawDoubleFlat(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Two flats side by side
    final offset = size.width * 0.12;
    final h = size.height * 0.45;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    for (final dx in [-offset, offset]) {
      final x = cx + dx;
      canvas.drawLine(
          Offset(x - 3, cy - h * 0.5), Offset(x - 3, cy + h * 0.4), paint);

      final path = Path()
        ..moveTo(x - 3, cy + h * 0.05)
        ..cubicTo(
          x + h * 0.2,
          cy - h * 0.1,
          x + h * 0.2,
          cy + h * 0.3,
          x - 3,
          cy + h * 0.4,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AccidentalsPainter oldDelegate) =>
      accidentalType != oldDelegate.accidentalType ||
      color != oldDelegate.color;
}

/// Widget wrapper for AccidentalsPainter
class AccidentalWidget extends StatelessWidget {
  final String accidentalType;
  final double size;
  final Color color;

  const AccidentalWidget({
    Key? key,
    required this.accidentalType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AccidentalsPainter(accidentalType: accidentalType, color: color),
      size: Size(size, size * 1.5),
    );
  }
}
