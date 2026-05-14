import 'package:flutter/material.dart';

/// Paints other common music symbols.
/// [symbolType]: fermata, coda, segno, repeatStart, repeatEnd
class OtherSymbolsPainter extends CustomPainter {
  final String symbolType;
  final Color color;

  OtherSymbolsPainter({required this.symbolType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (symbolType) {
      case 'fermata':
        drawFermata(canvas, cx, cy, size, paint);
        break;
      case 'coda':
        drawCoda(canvas, cx, cy, size, paint);
        break;
      case 'segno':
        drawSegno(canvas, cx, cy, size, paint);
        break;
      case 'repeatStart':
        drawRepeatStart(canvas, cx, cy, size, paint);
        break;
      case 'repeatEnd':
        drawRepeatEnd(canvas, cx, cy, size, paint);
        break;
    }
  }

  void drawFermata(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final w = size.width * 0.35;
    final h = size.height * 0.25;

    // Arc
    final path = Path()
      ..moveTo(cx - w, cy + h * 0.3)
      ..quadraticBezierTo(cx, cy - h, cx + w, cy + h * 0.3);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(path, paint);

    // Dot below arc
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + h * 0.2), 3.5, paint);
  }

  void drawCoda(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final r = size.width * 0.2;

    // Circle
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Cross through circle
    canvas.drawLine(Offset(cx, cy - r * 1.5), Offset(cx, cy + r * 1.5), paint);
    canvas.drawLine(Offset(cx - r * 1.5, cy), Offset(cx + r * 1.5, cy), paint);
  }

  void drawSegno(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final r = size.width * 0.18;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    // S-curve
    final path = Path()
      ..moveTo(cx + r, cy - r * 1.2)
      ..cubicTo(cx + r, cy - r * 0.5, cx - r, cy - r * 0.3, cx - r, cy)
      ..cubicTo(
          cx - r, cy + r * 0.3, cx + r, cy + r * 0.5, cx + r, cy + r * 1.2);

    canvas.drawPath(path, paint);

    // Diagonal line
    canvas.drawLine(
      Offset(cx - r * 1.3, cy + r * 1.3),
      Offset(cx + r * 1.3, cy - r * 1.3),
      paint,
    );

    // Two dots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - r * 0.8, cy - r * 0.8), 3, paint);
    canvas.drawCircle(Offset(cx + r * 0.8, cy + r * 0.8), 3, paint);
  }

  void drawRepeatStart(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final h = size.height * 0.5;
    final barX = cx - size.width * 0.1;

    // Thick bar
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 5.0;
    canvas.drawLine(
        Offset(barX - 5, cy - h / 2), Offset(barX - 5, cy + h / 2), paint);

    // Thin bar
    paint.strokeWidth = 1.5;
    canvas.drawLine(
        Offset(barX + 3, cy - h / 2), Offset(barX + 3, cy + h / 2), paint);

    // Two dots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(barX + 12, cy - h * 0.12), 3.5, paint);
    canvas.drawCircle(Offset(barX + 12, cy + h * 0.12), 3.5, paint);
  }

  void drawRepeatEnd(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    final h = size.height * 0.5;
    final barX = cx + size.width * 0.1;

    // Thin bar
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(
        Offset(barX - 3, cy - h / 2), Offset(barX - 3, cy + h / 2), paint);

    // Thick bar
    paint.strokeWidth = 5.0;
    canvas.drawLine(
        Offset(barX + 5, cy - h / 2), Offset(barX + 5, cy + h / 2), paint);

    // Two dots
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(barX - 12, cy - h * 0.12), 3.5, paint);
    canvas.drawCircle(Offset(barX - 12, cy + h * 0.12), 3.5, paint);
  }

  @override
  bool shouldRepaint(covariant OtherSymbolsPainter oldDelegate) =>
      symbolType != oldDelegate.symbolType || color != oldDelegate.color;
}

/// Widget wrapper for OtherSymbolsPainter
class OtherSymbolWidget extends StatelessWidget {
  final String symbolType;
  final double size;
  final Color color;

  const OtherSymbolWidget({
    Key? key,
    required this.symbolType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: OtherSymbolsPainter(symbolType: symbolType, color: color),
      size: Size(size, size),
    );
  }
}
