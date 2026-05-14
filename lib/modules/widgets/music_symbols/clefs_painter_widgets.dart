import 'package:flutter/material.dart';

/// Paints a musical clef.
/// [clefType]: treble, bass, alto, tenor
class ClefsPainter extends CustomPainter {
  final String clefType;
  final Color color;

  ClefsPainter({required this.clefType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (clefType) {
      case 'treble':
        drawTrebleClef(canvas, size, paint);
        break;
      case 'bass':
        drawBassClef(canvas, size, paint);
        break;
      case 'alto':
        drawAltoClef(canvas, size, paint);
        break;
      case 'tenor':
        drawTenorClef(canvas, size, paint);
        break;
    }
  }

  void drawTrebleClef(Canvas canvas, Size size, Paint paint) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '𝄞',
        style: TextStyle(fontSize: size.height * 0.85, color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void drawBassClef(Canvas canvas, Size size, Paint paint) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '𝄢',
        style: TextStyle(fontSize: size.height * 0.85, color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void drawAltoClef(Canvas canvas, Size size, Paint paint) {
    final cx = size.width * 0.4;
    final cy = size.height * 0.5;
    final h = size.height * 0.6;

    // Two vertical lines
    paint.strokeWidth = 3.5;
    canvas.drawLine(
        Offset(cx - 8, cy - h / 2), Offset(cx - 8, cy + h / 2), paint);
    paint.strokeWidth = 1.5;
    canvas.drawLine(
        Offset(cx - 3, cy - h / 2), Offset(cx - 3, cy + h / 2), paint);

    // Two curved brackets
    final bracketPath = Path()
      ..moveTo(cx, cy - h / 2)
      ..cubicTo(cx + 12, cy - h / 4, cx + 12, cy - h / 8, cx + 6, cy)
      ..cubicTo(cx + 12, cy + h / 8, cx + 12, cy + h / 4, cx, cy + h / 2);

    paint.strokeWidth = 2.0;
    canvas.drawPath(bracketPath, paint);
  }

  void drawTenorClef(Canvas canvas, Size size, Paint paint) {
    // Tenor clef is alto clef shifted up
    final cx = size.width * 0.4;
    final cy = size.height * 0.4; // shifted up from 0.5
    final h = size.height * 0.6;

    paint.strokeWidth = 3.5;
    canvas.drawLine(
        Offset(cx - 8, cy - h / 2), Offset(cx - 8, cy + h / 2), paint);
    paint.strokeWidth = 1.5;
    canvas.drawLine(
        Offset(cx - 3, cy - h / 2), Offset(cx - 3, cy + h / 2), paint);

    final bracketPath = Path()
      ..moveTo(cx, cy - h / 2)
      ..cubicTo(cx + 12, cy - h / 4, cx + 12, cy - h / 8, cx + 6, cy)
      ..cubicTo(cx + 12, cy + h / 8, cx + 12, cy + h / 4, cx, cy + h / 2);

    paint.strokeWidth = 2.0;
    canvas.drawPath(bracketPath, paint);
  }

  @override
  bool shouldRepaint(covariant ClefsPainter oldDelegate) =>
      clefType != oldDelegate.clefType || color != oldDelegate.color;
}

/// Widget wrapper for ClefsPainter
class ClefWidget extends StatelessWidget {
  final String clefType;
  final double size;
  final Color color;

  const ClefWidget({
    Key? key,
    required this.clefType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ClefsPainter(clefType: clefType, color: color),
      size: Size(size, size * 1.8),
    );
  }
}
