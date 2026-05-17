import 'package:flutter/material.dart';
import '../../models/key_signature.dart';
import '../../models/musical_note.dart';
import 'music_symbols/clefs_painter_widgets.dart';

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
    const startX = 0.0;
    final endX = size.width;

    // Draw 5 staff lines
    for (int i = -2; i <= 2; i++) {
      final y = centerY + (i * staffLineSpacing);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }

    // Draw appropriate clef
    final clefType = isBassClef ? 'bass' : 'treble';
    final clefPainter = ClefsPainter(clefType: clefType);
    const clefSize = Size(40, 80);
    canvas.save();
    canvas.translate(startX, centerY - clefSize.height / 2);
    clefPainter.paint(canvas, clefSize);
    canvas.restore();

    // Draw key signature after clef
    final count = keySignature.sharps.length + keySignature.flats.length;
    if (count > 0) {
      final isSharp = keySignature.sharps.isNotEmpty;
      // Treble clef positions (half-steps from middle line B4)
      // Sharp order: F C G D A E B
      const trebleSharpPos = [4, 1, 5, 2, -1, 3, 0];
      // Flat order: B E A D G C F
      const trebleFlatPos = [0, 3, -1, 2, -2, 1, -3];
      // Bass clef positions
      const bassSharpPos = [2, -1, 3, 0, -3, 1, -2];
      const bassFlatPos = [-2, 1, -3, 0, -4, -1, -5];

      final positions = isSharp
          ? (isBassClef ? bassSharpPos : trebleSharpPos)
          : (isBassClef ? bassFlatPos : trebleFlatPos);

      for (int i = 0; i < count; i++) {
        final x = startX + 44 + i * 10.0;
        final y = centerY - (positions[i] * staffLineSpacing / 2);
        drawAccidentalAt(canvas, x, y, isSharp ? '#' : 'b', Colors.black);
      }
    }

    // Draw note queue if provided
    if (noteQueue != null) {
      for (final np in noteQueue!) {
        final adjustedPosition =
            isBassClef ? np.note.linePosition - 2 : np.note.linePosition;
        final x = startX + (endX - startX) * np.xFraction;
        drawNoteAt(
            canvas, x, centerY, adjustedPosition, np.note, np.color, paint);
      }
    } else if (note != null) {
      final adjustedPosition =
          isBassClef ? note!.linePosition - 2 : note!.linePosition;
      final noteX = noteXOffset ?? size.width / 2;
      drawNoteAt(
          canvas, noteX, centerY, adjustedPosition, note!, noteColor, paint);
    }
  }

  void drawNoteAt(Canvas canvas, double x, double centerY, int linePosition,
      MusicalNote noteData, Color color, Paint paint) {
    final noteY = centerY - (linePosition * staffLineSpacing / 2);

    // Draw accidental only if not already in the key signature
    if (noteData.accidental != null) {
      final letter = noteData.noteName[0];
      final isInKey =
          (noteData.accidental == '#' && keySignature.hasSharp(letter)) ||
              (noteData.accidental == 'b' && keySignature.hasFlat(letter));
      if (!isInKey) {
        drawAccidentalAt(canvas, x - 22, noteY, noteData.accidental!, color);
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

  @override
  bool shouldRepaint(StaffPainter oldDelegate) => true;

  void drawAccidentalAt(
      Canvas canvas, double x, double y, String accidental, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (accidental == '#') {
      paint.style = PaintingStyle.stroke;
      final s = staffLineSpacing * 0.25;
      // Two vertical lines
      paint.strokeWidth = 1.2;
      canvas.drawLine(Offset(x - s * 0.25, y - s * 1.1),
          Offset(x - s * 0.25, y + s * 1.1), paint);
      canvas.drawLine(Offset(x + s * 0.25, y - s * 1.1),
          Offset(x + s * 0.25, y + s * 1.1), paint);
      // Two horizontal lines (slightly slanted, thicker)
      paint.strokeWidth = 2.0;
      canvas.drawLine(
          Offset(x - s * 0.7, y - s * 0.3), Offset(x + s * 0.7, y - s * 0.4), paint);
      canvas.drawLine(
          Offset(x - s * 0.7, y + s * 0.4), Offset(x + s * 0.7, y + s * 0.3), paint);
    } else if (accidental == 'b') {
      paint.style = PaintingStyle.stroke;
      final s = staffLineSpacing * 0.4;
      // Vertical stem
      paint.strokeWidth = 1.5;
      canvas.drawLine(Offset(x - s * 0.2, y - s * 1.6),
          Offset(x - s * 0.2, y + s * 0.5), paint);
      // Curved belly
      paint.strokeWidth = 1.8;
      final path = Path()
        ..moveTo(x - s * 0.2, y - s * 0.1)
        ..cubicTo(x + s * 0.7, y - s * 0.5, x + s * 0.7, y + s * 0.4,
            x - s * 0.2, y + s * 0.5);
      canvas.drawPath(path, paint);
    }
  }
}
