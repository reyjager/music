import 'package:flutter/material.dart';

/// Paints a musical note of the specified type.
/// [noteType]: whole, half, quarter, eighth, sixteenth
class NoteValuesPainter extends CustomPainter {
  final String noteType;
  final Color color;

  NoteValuesPainter({required this.noteType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height * 0.65;
    final noteWidth = size.width * 0.18;
    final noteHeight = noteWidth * 0.7;

    switch (noteType) {
      case 'whole':
        drawNoteHead(canvas, cx, cy, noteWidth, noteHeight, paint,
            filled: false);
        break;
      case 'half':
        drawNoteHead(canvas, cx, cy, noteWidth, noteHeight, paint,
            filled: false);
        drawStem(canvas, cx + noteWidth, cy, size.height * 0.4, paint);
        break;
      case 'quarter':
        drawNoteHead(canvas, cx, cy, noteWidth, noteHeight, paint,
            filled: true);
        drawStem(canvas, cx + noteWidth, cy, size.height * 0.4, paint);
        break;
      case 'eighth':
        drawNoteHead(canvas, cx, cy, noteWidth, noteHeight, paint,
            filled: true);
        drawStem(canvas, cx + noteWidth, cy, size.height * 0.4, paint);
        drawFlag(
            canvas, cx + noteWidth, cy - size.height * 0.4, size, paint, 1);
        break;
      case 'sixteenth':
        drawNoteHead(canvas, cx, cy, noteWidth, noteHeight, paint,
            filled: true);
        drawStem(canvas, cx + noteWidth, cy, size.height * 0.4, paint);
        drawFlag(
            canvas, cx + noteWidth, cy - size.height * 0.4, size, paint, 2);
        break;
    }
  }

  void drawNoteHead(
      Canvas canvas, double cx, double cy, double w, double h, Paint paint,
      {required bool filled}) {
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(-0.3);

    final rect =
        Rect.fromCenter(center: Offset.zero, width: w * 2, height: h * 2);
    if (filled) {
      canvas.drawOval(rect, paint);
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.5;
      canvas.drawOval(rect, paint);
      paint.style = PaintingStyle.fill;
    }
    canvas.restore();
  }

  void drawStem(Canvas canvas, double x, double y, double height, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    canvas.drawLine(Offset(x, y), Offset(x, y - height), paint);
    paint.style = PaintingStyle.fill;
  }

  void drawFlag(
      Canvas canvas, double x, double y, Size size, Paint paint, int count) {
    final flagLength = size.height * 0.2;
    for (var i = 0; i < count; i++) {
      final startY = y + i * 10.0;
      final path = Path()
        ..moveTo(x, startY)
        ..cubicTo(
          x + flagLength * 0.5,
          startY + flagLength * 0.3,
          x + flagLength * 0.8,
          startY + flagLength * 0.6,
          x + flagLength * 0.3,
          startY + flagLength,
        );
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.5;
      canvas.drawPath(path, paint);
    }
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant NoteValuesPainter oldDelegate) =>
      noteType != oldDelegate.noteType || color != oldDelegate.color;
}

/// Widget wrapper for NoteValuesPainter
class NoteValueWidget extends StatelessWidget {
  final String noteType;
  final double size;
  final Color color;

  const NoteValueWidget({
    Key? key,
    required this.noteType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NoteValuesPainter(noteType: noteType, color: color),
      size: Size(size, size * 1.5),
    );
  }
}
