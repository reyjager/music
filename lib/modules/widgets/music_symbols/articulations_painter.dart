import 'package:flutter/material.dart';

/// Paints a musical articulation mark.
/// [articulationType]: staccato, legato, accent, tenuto
class ArticulationsPainter extends CustomPainter {
  final String articulationType;
  final Color color;

  ArticulationsPainter(
      {required this.articulationType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;

    switch (articulationType) {
      case 'staccato':
        drawStaccato(canvas, cx, cy, size, paint);
        break;
      case 'legato':
        drawLegato(canvas, cx, cy, size, paint);
        break;
      case 'accent':
        drawAccent(canvas, cx, cy, size, paint);
        break;
      case 'tenuto':
        drawTenuto(canvas, cx, cy, size, paint);
        break;
    }
  }

  void drawStaccato(
      Canvas canvas, double cx, double cy, Size size, Paint paint) {
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.08, paint);
  }

  void drawLegato(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Slur/arc
    final w = size.width * 0.6;
    final path = Path()
      ..moveTo(cx - w / 2, cy)
      ..quadraticBezierTo(cx, cy - size.height * 0.25, cx + w / 2, cy);

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(path, paint);
  }

  void drawAccent(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // > shape
    final w = size.width * 0.3;
    final h = size.height * 0.15;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;

    final path = Path()
      ..moveTo(cx - w, cy - h)
      ..lineTo(cx + w, cy)
      ..lineTo(cx - w, cy + h);

    canvas.drawPath(path, paint);
  }

  void drawTenuto(Canvas canvas, double cx, double cy, Size size, Paint paint) {
    // Horizontal line
    final w = size.width * 0.25;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    canvas.drawLine(Offset(cx - w, cy), Offset(cx + w, cy), paint);
  }

  @override
  bool shouldRepaint(covariant ArticulationsPainter oldDelegate) =>
      articulationType != oldDelegate.articulationType ||
      color != oldDelegate.color;
}

/// Widget wrapper for ArticulationsPainter
class ArticulationWidget extends StatelessWidget {
  final String articulationType;
  final double size;
  final Color color;

  const ArticulationWidget({
    Key? key,
    required this.articulationType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArticulationsPainter(
          articulationType: articulationType, color: color),
      size: Size(size, size),
    );
  }
}
