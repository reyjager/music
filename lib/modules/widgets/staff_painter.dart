import 'package:flutter/material.dart';
import '../../models/key_signature.dart';
import '../../models/musical_note.dart';

class NotePosition {
  final MusicalNote note;
  final double xFraction; // 0.0 = left edge, 1.0 = right edge
  final Color color;

  NotePosition(
      {required this.note, required this.xFraction, this.color = Colors.black});
}

class StaffPainter extends CustomPainter {
  final MusicalNote? note;
  final bool isBassClef;
  final Color noteColor;
  final double? noteXOffset;
  final List<NotePosition>? noteQueue;
  final KeySignature keySignature;
  final double staffLineSpacing = 20.0;

  StaffPainter({
    this.note,
    this.isBassClef = false,
    this.noteColor = Colors.black,
    this.noteXOffset,
    this.noteQueue,
    this.keySignature = const KeySignature(name: 'C Major'),
  });

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

    // Draw key signature after clef
    _drawKeySignature(canvas, startX + 50, centerY, paint);

    // Draw note queue if provided
    if (noteQueue != null) {
      for (final np in noteQueue!) {
        final adjustedPosition =
            isBassClef ? np.note.linePosition - 2 : np.note.linePosition;
        final x = startX + (endX - startX) * np.xFraction;
        _drawNoteAt(
            canvas, x, centerY, adjustedPosition, np.note, np.color, paint);
      }
    } else if (note != null) {
      final adjustedPosition =
          isBassClef ? note!.linePosition - 2 : note!.linePosition;
      final noteX = noteXOffset ?? size.width / 2;
      _drawNoteAt(
          canvas, noteX, centerY, adjustedPosition, note!, noteColor, paint);
    }
  }

  void _drawNoteAt(Canvas canvas, double x, double centerY, int linePosition,
      MusicalNote noteData, Color color, Paint paint) {
    final noteY = centerY - (linePosition * staffLineSpacing / 2);

    // Draw accidental only if not already in the key signature
    if (noteData.accidental != null) {
      final letter = noteData.noteName[0];
      final isInKey = (noteData.accidental == '#' && keySignature.hasSharp(letter)) ||
          (noteData.accidental == 'b' && keySignature.hasFlat(letter));
      if (!isInKey) {
        _drawAccidentalAt(canvas, x - 22, noteY, noteData.accidental!, color);
      }
    }

    // Note head
    final notePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, noteY), width: 20, height: 15),
      notePaint,
    );

    // Stem
    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 2.0;
    canvas.drawLine(
        Offset(x + 10, noteY), Offset(x + 10, noteY - 60), stemPaint);

    // Ledger lines
    drawLedgerLines(canvas, x, centerY, linePosition, paint);
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
    textPainter.paint(canvas, Offset(x, centerY - textPainter.height / 2));
  }

  void drawLedgerLines(
      Canvas canvas, double x, double centerY, int linePosition, Paint paint) {
    final ledgerPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0;

    if (linePosition > 4) {
      for (int i = 6; i <= linePosition; i += 2) {
        final y = centerY - (i * staffLineSpacing / 2);
        canvas.drawLine(Offset(x - 15, y), Offset(x + 15, y), ledgerPaint);
      }
    }

    if (linePosition < -4) {
      for (int i = -6; i >= linePosition; i -= 2) {
        final y = centerY - (i * staffLineSpacing / 2);
        canvas.drawLine(Offset(x - 15, y), Offset(x + 15, y), ledgerPaint);
      }
    }
  }

  void _drawKeySignature(
      Canvas canvas, double startX, double centerY, Paint paint) {
    final positions = keySignature.sharps.isNotEmpty
        ? (isBassClef
            ? KeySignature.bassSharpPositions
            : KeySignature.trebleSharpPositions)
        : (isBassClef
            ? KeySignature.bassFlatPositions
            : KeySignature.trebleFlatPositions);
    final count = keySignature.sharps.length + keySignature.flats.length;
    final isSharp = keySignature.sharps.isNotEmpty;

    for (int i = 0; i < count; i++) {
      final x = startX + i * 12.0;
      final y = centerY - (positions[i] * staffLineSpacing / 2);
      if (isSharp) {
        _drawAccidentalAt(canvas, x, y, '#', Colors.black);
      } else {
        _drawAccidentalAt(canvas, x, y, 'b', Colors.black);
      }
    }
  }

  @override
  bool shouldRepaint(StaffPainter oldDelegate) => true;

  void _drawAccidentalAt(
      Canvas canvas, double x, double y, String accidental, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (accidental == '#') {
      paint.style = PaintingStyle.stroke;
      final s = staffLineSpacing * 0.45;
      // Two vertical lines
      canvas.drawLine(Offset(x - s * 0.3, y - s * 1.3),
          Offset(x - s * 0.3, y + s * 1.3), paint);
      canvas.drawLine(Offset(x + s * 0.3, y - s * 1.3),
          Offset(x + s * 0.3, y + s * 1.3), paint);
      // Two horizontal lines (slightly slanted)
      paint.strokeWidth = 3.0;
      canvas.drawLine(
          Offset(x - s, y - s * 0.35), Offset(x + s, y - s * 0.45), paint);
      canvas.drawLine(
          Offset(x - s, y + s * 0.45), Offset(x + s, y + s * 0.35), paint);
    } else if (accidental == 'b') {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      final s = staffLineSpacing * 0.5;
      // Vertical stem
      canvas.drawLine(Offset(x - s * 0.3, y - s * 1.8),
          Offset(x - s * 0.3, y + s * 0.6), paint);
      // Curved belly
      final path = Path()
        ..moveTo(x - s * 0.3, y - s * 0.2)
        ..cubicTo(x + s * 0.8, y - s * 0.6, x + s * 0.8, y + s * 0.5,
            x - s * 0.3, y + s * 0.6);
      canvas.drawPath(path, paint);
    }
  }
}
