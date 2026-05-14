import 'package:flutter/material.dart';
import '../../models/musical_note.dart';

class StaffPainter extends CustomPainter {
  final MusicalNote? note;
  final bool isBassClef;
  final Color noteColor;
  final double staffLineSpacing = 20.0;

  StaffPainter(
      {this.note, this.isBassClef = false, this.noteColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    const startX = 40.0;
    final endX = size.width - 40.0;

    // Draw 5 staff lines
    for (int i = -2; i <= 2; i++) {
      final y = centerY + (i * staffLineSpacing);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }

    // Draw appropriate clef
    if (isBassClef) {
      drawBassClef(canvas, startX + 10, centerY, paint);
    } else {
      drawTrebleClef(canvas, startX + 10, centerY, paint);
    }

    // Draw note if present
    if (note != null) {
      // Shift linePosition by -2 to convert Treble positions (FACE) to Bass positions (ACEG)
      // This ensures that an 'A' note appears in the bottom space of the Bass clef.
      final adjustedPosition =
          isBassClef ? note!.linePosition - 2 : note!.linePosition;
      drawNote(canvas, size.width / 2, centerY, adjustedPosition, paint);
    }
  }

  void drawTrebleClef(Canvas canvas, double x, double centerY, Paint paint) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '𝄞',
        style: TextStyle(fontSize: 80, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, centerY - 50));
  }

  void drawBassClef(Canvas canvas, double x, double centerY, Paint paint) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '𝄢',
        style: TextStyle(fontSize: 80, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    // Center the bass clef vertically on the staff
    textPainter.paint(canvas, Offset(x, centerY - textPainter.height / 2));
  }

  void drawNote(
      Canvas canvas, double x, double centerY, int linePosition, Paint paint) {
    final noteY = centerY - (linePosition * staffLineSpacing / 2);

    // Draw accidental if sharp/flat
    if (note?.accidental != null) {
      drawAccidental(canvas, x - 18, noteY, note!.accidental!);
    }

    // Draw note head (filled oval)
    final notePaint = Paint()
      ..color = noteColor
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, noteY), width: 20, height: 15),
      notePaint,
    );

    // Draw stem
    final stemPaint = Paint()
      ..color = noteColor
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(x + 10, noteY),
      Offset(x + 10, noteY - 60),
      stemPaint,
    );

    // Draw ledger lines if needed
    drawLedgerLines(canvas, x, centerY, linePosition, paint);
  }

  void drawLedgerLines(
      Canvas canvas, double x, double centerY, int linePosition, Paint paint) {
    final ledgerPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    // Above staff (linePosition > 4)
    // Staff lines are at even positions, so ledger lines at even positions too
    if (linePosition > 4) {
      for (int i = 6; i <= linePosition; i += 2) {
        final y = centerY - (i * staffLineSpacing / 2);
        canvas.drawLine(Offset(x - 15, y), Offset(x + 15, y), ledgerPaint);
      }
    }

    // Below staff (linePosition < -4)
    if (linePosition < -4) {
      for (int i = -6; i >= linePosition; i -= 2) {
        final y = centerY - (i * staffLineSpacing / 2);
        canvas.drawLine(Offset(x - 15, y), Offset(x + 15, y), ledgerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(StaffPainter oldDelegate) =>
      oldDelegate.note != note ||
      oldDelegate.isBassClef != isBassClef ||
      oldDelegate.noteColor != noteColor;

  void drawAccidental(Canvas canvas, double x, double y, String accidental) {
    final paint = Paint()
      ..color = noteColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    if (accidental == '#') {
      paint.style = PaintingStyle.stroke;
      final s = staffLineSpacing * 0.3;
      // Vertical lines
      canvas.drawLine(Offset(x - s * 0.3, y - s * 1.2),
          Offset(x - s * 0.3, y + s * 1.2), paint);
      canvas.drawLine(Offset(x + s * 0.3, y - s * 1.2),
          Offset(x + s * 0.3, y + s * 1.2), paint);
      // Horizontal lines
      paint.strokeWidth = 2.5;
      canvas.drawLine(
          Offset(x - s, y - s * 0.3), Offset(x + s, y - s * 0.4), paint);
      canvas.drawLine(
          Offset(x - s, y + s * 0.4), Offset(x + s, y + s * 0.3), paint);
    } else if (accidental == 'b') {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.8;
      final s = staffLineSpacing * 0.35;
      // Vertical stem
      canvas.drawLine(Offset(x - s * 0.3, y - s * 1.8),
          Offset(x - s * 0.3, y + s * 0.5), paint);
      // Curved belly
      final path = Path()
        ..moveTo(x - s * 0.3, y - s * 0.2)
        ..cubicTo(x + s * 0.7, y - s * 0.5, x + s * 0.7, y + s * 0.4,
            x - s * 0.3, y + s * 0.5);
      canvas.drawPath(path, paint);
    }
  }
}
