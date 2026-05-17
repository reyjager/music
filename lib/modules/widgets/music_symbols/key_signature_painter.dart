import 'package:flutter/material.dart';

/// Paints a key signature on a mini staff.
/// [sharps]: number of sharps (1-7), use 0 if flats
/// [flats]: number of flats (1-7), use 0 if sharps
/// [clefType]: optional clef to draw (treble, bass, alto, tenor)
class KeySignaturePainter extends CustomPainter {
  final int sharps;
  final int flats;
  final String? clefType;
  final Color color;
  bool drawStaffLines;

  KeySignaturePainter(
      {this.sharps = 0,
      this.flats = 0,
      this.clefType = 'treble',
      this.color = Colors.black,
      this.drawStaffLines = true});

  // Staff positions for sharps: F C G D A E B
  static const _sharpPositions = [0, 3, -1, 2, 5, 1, 4];
  // Staff positions for flats: B E A D G C F
  static const _flatPositions = [4, 1, 5, 2, 6, 3, 7];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    final staffTop = size.height * 0.2;
    final staffBottom = size.height * 0.8;
    final lineSpacing = (staffBottom - staffTop) / 4;

    // Draw 5 staff lines
    if (drawStaffLines) {
      paint.style = PaintingStyle.stroke;
      for (var i = 0; i < 5; i++) {
        final y = staffTop + i * lineSpacing;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }

    // Draw clef or single barline on the left
    double accidentalOffset = 0;
    final staffHeight = staffBottom - staffTop;
    if (drawStaffLines) {
      accidentalOffset = drawSingleBarline(canvas, staffTop, staffBottom);
    }
    if (clefType != null) {
      accidentalOffset = drawClef(canvas, size, staffTop, staffHeight);
    }

    // Draw accidentals
    if (sharps > 0) {
      drawSharps(canvas, size, staffTop, lineSpacing, paint, accidentalOffset);
    } else if (flats > 0) {
      drawFlats(canvas, size, staffTop, lineSpacing, paint, accidentalOffset);
    }
  }

  double drawSingleBarline(Canvas canvas, double staffTop, double staffBottom) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, staffTop), Offset(0, staffBottom), paint);
    return 4;
  }

  double drawClef(
      Canvas canvas, Size size, double staffTop, double staffHeight) {
    final clefSymbol = switch (clefType) {
      'treble' => '𝄞',
      'bass' => '𝄢',
      'alto' => '𝄡',
      'tenor' => '𝄡',
      _ => null,
    };
    if (clefSymbol == null) return 0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: clefSymbol,
        style: TextStyle(
            fontSize: (clefType == 'treble') ? staffHeight * .85 : staffHeight,
            color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(2, staffTop + (staffHeight - textPainter.height) / 2),
    );
    return textPainter.width + 4;
  }

  void drawSharps(Canvas canvas, Size size, double staffTop, double lineSpacing,
      Paint paint, double offset) {
    final count = sharps.clamp(0, 7);
    final availableWidth = size.width - offset;
    final spacing = availableWidth / (count + 1);

    for (var i = 0; i < count; i++) {
      final x = offset + spacing * (i * .4);
      final pos = _sharpPositions[i];
      final y = staffTop + pos * lineSpacing / 2;

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.0;

      final s = lineSpacing * 0.35;
      // Vertical lines
      canvas.drawLine(Offset(x - s * 0.2, y - s * 1.2),
          Offset(x - s * 0.3, y + s * 1.2), paint);
      canvas.drawLine(Offset(x + s * 0.2, y - s * 1.2),
          Offset(x + s * 0.3, y + s * 1.2), paint);
      // Horizontal lines
      paint.strokeWidth = 2.0;
      canvas.drawLine(
          Offset(x - s, y - s * 0.3), Offset(x + s, y - s * 0.4), paint);
      canvas.drawLine(
          Offset(x - s, y + s * 0.4), Offset(x + s, y + s * 0.4), paint);
    }
  }

  void drawFlats(Canvas canvas, Size size, double staffTop, double lineSpacing,
      Paint paint, double offset) {
    final count = flats.clamp(0, 7);
    final availableWidth = size.width - offset;
    final spacing = availableWidth * 0.8 / (count + 1);

    for (var i = 0; i < count; i++) {
      final x = offset + spacing * (i * .4);
      final pos = _flatPositions[i];
      final y = staffTop + pos * lineSpacing / 2;

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1.5;

      final s = lineSpacing * 0.4;
      // Vertical stem
      canvas.drawLine(Offset(x - s * 0.3, y - s * 1.5),
          Offset(x - s * 0.3, y + s * 0.5), paint);
      // Curved belly
      final path = Path()
        ..moveTo(x - s * 0.3, y - s * 0.2)
        ..cubicTo(x + s * 0.6, y - s * 0.5, x + s * 0.6, y + s * 0.3,
            x - s * 0.3, y + s * 0.5);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant KeySignaturePainter oldDelegate) =>
      sharps != oldDelegate.sharps ||
      flats != oldDelegate.flats ||
      clefType != oldDelegate.clefType ||
      color != oldDelegate.color ||
      drawStaffLines != oldDelegate.drawStaffLines;
}

/// Widget wrapper for KeySignaturePainter
class KeySignatureWidget extends StatelessWidget {
  final int sharps;
  final int flats;
  final String? clefType;
  final double size;
  final Color color;

  const KeySignatureWidget({
    Key? key,
    this.sharps = 0,
    this.flats = 0,
    this.clefType = 'treble',
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widthMultiplier = clefType != null ? 2.0 : 1.5;
    return CustomPaint(
      painter: KeySignaturePainter(
          sharps: sharps, flats: flats, clefType: clefType, color: color),
      size: Size(size * widthMultiplier, size),
    );
  }
}
