import 'package:flutter/material.dart';

/// Represents a symbol to be drawn on the staff.
class StaffSymbol {
  /// Type of symbol: clef, timeSignature, keySignature, note, rest, accidental, barline, dynamic, articulation
  final StaffSymbolType type;

  /// Horizontal position (0.0 = left edge, 1.0 = right edge) or absolute x offset
  final double x;

  /// Staff position: 0 = top line, 1 = first space, 2 = second line, etc.
  /// Negative = above staff, >8 = below staff
  final int staffPosition;

  /// Symbol-specific data
  final Map<String, dynamic> data;

  /// Optional color override
  final Color? color;

  const StaffSymbol({
    required this.type,
    required this.x,
    this.staffPosition = 0,
    this.data = const {},
    this.color,
  });
}

enum StaffSymbolType {
  clef,
  timeSignature,
  keySignature,
  note,
  rest,
  accidental,
  barline,
  dynamic,
  articulation,
}

/// A dynamic, composable staff painter. All symbols are parameters.
/// Reuse this to render any music by passing in a list of [StaffSymbol].
class MusicStaffPainter extends CustomPainter {
  final List<StaffSymbol> symbols;
  final Color staffColor;
  final int staffLines;
  final double staffTopRatio;
  final double staffHeightRatio;
  final bool drawStaffLines;

  MusicStaffPainter({
    required this.symbols,
    this.staffColor = Colors.black,
    this.staffLines = 5,
    this.staffTopRatio = 0.2,
    this.staffHeightRatio = 0.6,
    this.drawStaffLines = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final staffTop = size.height * staffTopRatio;
    final staffHeight = size.height * staffHeightRatio;
    final lineSpacing = staffHeight / (staffLines - 1);

    if (drawStaffLines) {
      _drawStaffLines(canvas, size, staffTop, lineSpacing);
    }

    for (final symbol in symbols) {
      final color = symbol.color ?? staffColor;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      switch (symbol.type) {
        case StaffSymbolType.clef:
          drawClef(canvas, size, symbol, staffTop, staffHeight, color);
        case StaffSymbolType.timeSignature:
          drawTimeSignature(canvas, size, symbol, staffTop, staffHeight, color);
        case StaffSymbolType.keySignature:
          drawKeySignature(canvas, size, symbol, staffTop, lineSpacing, paint);
        case StaffSymbolType.note:
          drawNote(canvas, size, symbol, staffTop, lineSpacing, paint);
        case StaffSymbolType.rest:
          drawRest(canvas, size, symbol, staffTop, staffHeight, paint);
        case StaffSymbolType.accidental:
          drawAccidental(canvas, size, symbol, staffTop, lineSpacing, paint);
        case StaffSymbolType.barline:
          drawBarline(canvas, symbol, staffTop, staffHeight, paint);
        case StaffSymbolType.dynamic:
          drawDynamic(canvas, size, symbol, staffTop, staffHeight, color);
        case StaffSymbolType.articulation:
          drawArticulation(canvas, size, symbol, staffTop, lineSpacing, paint);
      }
    }
  }

  void _drawStaffLines(
      Canvas canvas, Size size, double staffTop, double lineSpacing) {
    final paint = Paint()
      ..color = staffColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < staffLines; i++) {
      final y = staffTop + i * lineSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // --- Clef ---
  void drawClef(Canvas canvas, Size size, StaffSymbol symbol, double staffTop,
      double staffHeight, Color color) {
    final clefType = symbol.data['clef'] as String? ?? 'treble';
    final clefChar = switch (clefType) {
      'treble' => '𝄞',
      'bass' => '𝄢',
      'alto' => '𝄡',
      'tenor' => '𝄡',
      _ => '𝄞',
    };
    final tp = TextPainter(
      text: TextSpan(
        text: clefChar,
        style: TextStyle(fontSize: staffHeight * 1.2, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(symbol.x, staffTop + (staffHeight - tp.height) / 2));
  }

  // --- Time Signature ---
  void drawTimeSignature(Canvas canvas, Size size, StaffSymbol symbol,
      double staffTop, double staffHeight, Color color) {
    final upper = symbol.data['upper'] as int? ?? 4;
    final lower = symbol.data['lower'] as int? ?? 4;
    final style = TextStyle(
      fontSize: staffHeight * 0.45,
      fontWeight: FontWeight.bold,
      color: color,
    );
    final topTp = TextPainter(
      text: TextSpan(text: '$upper', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final bottomTp = TextPainter(
      text: TextSpan(text: '$lower', style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    topTp.paint(canvas, Offset(symbol.x - topTp.width / 2, staffTop));
    bottomTp.paint(canvas,
        Offset(symbol.x - bottomTp.width / 2, staffTop + staffHeight / 2));
  }

  // --- Key Signature ---
  static const _sharpPositions = [0, 3, -1, 2, 5, 1, 4];
  static const _flatPositions = [4, 1, 5, 2, 6, 3, 7];

  void drawKeySignature(Canvas canvas, Size size, StaffSymbol symbol,
      double staffTop, double lineSpacing, Paint paint) {
    final sharps = symbol.data['sharps'] as int? ?? 0;
    final flats = symbol.data['flats'] as int? ?? 0;
    final spacing = lineSpacing * 0.7;

    if (sharps > 0) {
      for (var i = 0; i < sharps.clamp(0, 7); i++) {
        final x = symbol.x + i * spacing;
        final y = staffTop + _sharpPositions[i] * lineSpacing / 2;
        drawSharpSymbol(canvas, x, y, lineSpacing, paint);
      }
    } else if (flats > 0) {
      for (var i = 0; i < flats.clamp(0, 7); i++) {
        final x = symbol.x + i * spacing;
        final y = staffTop + _flatPositions[i] * lineSpacing / 2;
        drawFlatSymbol(canvas, x, y, lineSpacing, paint);
      }
    }
  }

  void drawSharpSymbol(
      Canvas canvas, double x, double y, double lineSpacing, Paint paint) {
    final s = lineSpacing * 0.35;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    canvas.drawLine(Offset(x - s * 0.3, y - s * 1.2),
        Offset(x - s * 0.3, y + s * 1.2), paint);
    canvas.drawLine(Offset(x + s * 0.3, y - s * 1.2),
        Offset(x + s * 0.3, y + s * 1.2), paint);
    paint.strokeWidth = 2.0;
    canvas.drawLine(
        Offset(x - s, y - s * 0.4), Offset(x + s, y - s * 0.5), paint);
    canvas.drawLine(
        Offset(x - s, y + s * 0.5), Offset(x + s, y + s * 0.4), paint);
  }

  void drawFlatSymbol(
      Canvas canvas, double x, double y, double lineSpacing, Paint paint) {
    final s = lineSpacing * 0.4;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(x - s * 0.3, y - s * 1.5),
        Offset(x - s * 0.3, y + s * 0.5), paint);
    final path = Path()
      ..moveTo(x - s * 0.3, y - s * 0.2)
      ..cubicTo(x + s * 0.6, y - s * 0.5, x + s * 0.6, y + s * 0.3, x - s * 0.3,
          y + s * 0.5);
    canvas.drawPath(path, paint);
  }

  // --- Note ---
  void drawNote(Canvas canvas, Size size, StaffSymbol symbol, double staffTop,
      double lineSpacing, Paint paint) {
    final noteType = symbol.data['noteType'] as String? ?? 'quarter';
    final x = symbol.x;
    final y = staffTop + symbol.staffPosition * lineSpacing / 2;
    final noteW = lineSpacing * 0.6;
    final noteH = noteW * 0.7;
    final stemH = lineSpacing * 2.5;

    // Ledger lines
    drawLedgerLines(
        canvas, x, staffTop, lineSpacing, symbol.staffPosition, noteW, paint);

    switch (noteType) {
      case 'whole':
        drawNoteHead(canvas, x, y, noteW, noteH, paint, filled: false);
      case 'half':
        drawNoteHead(canvas, x, y, noteW, noteH, paint, filled: false);
        drawStem(canvas, x + noteW, y, stemH, paint);
      case 'quarter':
        drawNoteHead(canvas, x, y, noteW, noteH, paint, filled: true);
        drawStem(canvas, x + noteW, y, stemH, paint);
      case 'eighth':
        drawNoteHead(canvas, x, y, noteW, noteH, paint, filled: true);
        drawStem(canvas, x + noteW, y, stemH, paint);
        drawFlag(canvas, x + noteW, y - stemH, lineSpacing, paint, 1);
      case 'sixteenth':
        drawNoteHead(canvas, x, y, noteW, noteH, paint, filled: true);
        drawStem(canvas, x + noteW, y, stemH, paint);
        drawFlag(canvas, x + noteW, y - stemH, lineSpacing, paint, 2);
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
      paint.style = PaintingStyle.fill;
      canvas.drawOval(rect, paint);
    } else {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;
      canvas.drawOval(rect, paint);
    }
    canvas.restore();
  }

  void drawStem(Canvas canvas, double x, double y, double height, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawLine(Offset(x, y), Offset(x, y - height), paint);
  }

  void drawFlag(Canvas canvas, double x, double y, double lineSpacing,
      Paint paint, int count) {
    final flagLen = lineSpacing * 1.2;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;
    for (var i = 0; i < count; i++) {
      final startY = y + i * lineSpacing * 0.5;
      final path = Path()
        ..moveTo(x, startY)
        ..cubicTo(x + flagLen * 0.5, startY + flagLen * 0.3, x + flagLen * 0.8,
            startY + flagLen * 0.6, x + flagLen * 0.3, startY + flagLen);
      canvas.drawPath(path, paint);
    }
  }

  void drawLedgerLines(Canvas canvas, double x, double staffTop,
      double lineSpacing, int staffPos, double noteW, Paint paint) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    // Above staff (position < 0)
    if (staffPos < 0) {
      for (var i = -2; i >= staffPos; i -= 2) {
        final y = staffTop + i * lineSpacing / 2;
        canvas.drawLine(
            Offset(x - noteW * 1.3, y), Offset(x + noteW * 1.3, y), paint);
      }
    }
    // Below staff (position > 8 for 5-line staff)
    final bottomPos = (staffLines - 1) * 2;
    if (staffPos > bottomPos) {
      for (var i = bottomPos + 2; i <= staffPos; i += 2) {
        final y = staffTop + i * lineSpacing / 2;
        canvas.drawLine(
            Offset(x - noteW * 1.3, y), Offset(x + noteW * 1.3, y), paint);
      }
    }
  }

  // --- Rest ---
  void drawRest(Canvas canvas, Size size, StaffSymbol symbol, double staffTop,
      double staffHeight, Paint paint) {
    final restType = symbol.data['restType'] as String? ?? 'quarter';
    final x = symbol.x;
    final cy = staffTop + staffHeight / 2;
    final lineSpacing = staffHeight / (staffLines - 1);

    switch (restType) {
      case 'whole':
        final y = staffTop + lineSpacing;
        paint.style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(x - 6, y, 12, lineSpacing * 0.5), paint);
      case 'half':
        final y = staffTop + lineSpacing * 2 - lineSpacing * 0.5;
        paint.style = PaintingStyle.fill;
        canvas.drawRect(Rect.fromLTWH(x - 6, y, 12, lineSpacing * 0.5), paint);
      case 'quarter':
        final h = staffHeight * 0.5;
        final w = lineSpacing * 0.3;
        final path = Path()
          ..moveTo(x + w, cy - h / 2)
          ..lineTo(x - w, cy - h * 0.25)
          ..lineTo(x + w, cy)
          ..lineTo(x - w, cy + h * 0.25)
          ..lineTo(x + w, cy + h / 2);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.5;
        canvas.drawPath(path, paint);
      case 'eighth':
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x + 2, cy - lineSpacing * 0.5), 3, paint);
        final path = Path()
          ..moveTo(x + 2, cy - lineSpacing * 0.4)
          ..cubicTo(x - 4, cy, x + 2, cy + lineSpacing * 0.3, x - 2,
              cy + lineSpacing * 0.6);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.0;
        canvas.drawPath(path, paint);
      case 'sixteenth':
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x + 2, cy - lineSpacing * 0.7), 3, paint);
        canvas.drawCircle(Offset(x + 4, cy - lineSpacing * 0.3), 3, paint);
        final path = Path()
          ..moveTo(x + 2, cy - lineSpacing * 0.6)
          ..cubicTo(x - 4, cy, x + 2, cy + lineSpacing * 0.3, x - 2,
              cy + lineSpacing * 0.7);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.0;
        canvas.drawPath(path, paint);
    }
  }

  // --- Accidental ---
  void drawAccidental(Canvas canvas, Size size, StaffSymbol symbol,
      double staffTop, double lineSpacing, Paint paint) {
    final accType = symbol.data['accidental'] as String? ?? 'sharp';
    final x = symbol.x;
    final y = staffTop + symbol.staffPosition * lineSpacing / 2;

    switch (accType) {
      case 'sharp':
        drawSharpSymbol(canvas, x, y, lineSpacing, paint);
      case 'flat':
        drawFlatSymbol(canvas, x, y, lineSpacing, paint);
      case 'natural':
        drawNaturalSymbol(canvas, x, y, lineSpacing, paint);
      case 'doubleSharp':
        final s = lineSpacing * 0.25;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.5;
        canvas.drawLine(Offset(x - s, y - s), Offset(x + s, y + s), paint);
        canvas.drawLine(Offset(x + s, y - s), Offset(x - s, y + s), paint);
      case 'doubleFlat':
        drawFlatSymbol(canvas, x - lineSpacing * 0.3, y, lineSpacing, paint);
        drawFlatSymbol(canvas, x + lineSpacing * 0.3, y, lineSpacing, paint);
    }
  }

  void drawNaturalSymbol(
      Canvas canvas, double x, double y, double lineSpacing, Paint paint) {
    final s = lineSpacing * 0.3;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.2;
    canvas.drawLine(
        Offset(x - s, y - s * 1.5), Offset(x - s, y + s * 0.5), paint);
    canvas.drawLine(
        Offset(x + s, y - s * 0.5), Offset(x + s, y + s * 1.5), paint);
    paint.strokeWidth = 2.0;
    canvas.drawLine(
        Offset(x - s, y - s * 0.4), Offset(x + s, y - s * 0.6), paint);
    canvas.drawLine(
        Offset(x - s, y + s * 0.6), Offset(x + s, y + s * 0.4), paint);
  }

  // --- Barline ---
  void drawBarline(Canvas canvas, StaffSymbol symbol, double staffTop,
      double staffHeight, Paint paint) {
    final barType = symbol.data['barline'] as String? ?? 'single';
    final x = symbol.x;

    switch (barType) {
      case 'single':
        paint.strokeWidth = 1.5;
        canvas.drawLine(
            Offset(x, staffTop), Offset(x, staffTop + staffHeight), paint);
      case 'double':
        paint.strokeWidth = 1.5;
        canvas.drawLine(Offset(x - 3, staffTop),
            Offset(x - 3, staffTop + staffHeight), paint);
        canvas.drawLine(Offset(x + 3, staffTop),
            Offset(x + 3, staffTop + staffHeight), paint);
      case 'final':
        paint.strokeWidth = 1.5;
        canvas.drawLine(Offset(x - 4, staffTop),
            Offset(x - 4, staffTop + staffHeight), paint);
        paint.strokeWidth = 4.0;
        canvas.drawLine(Offset(x + 3, staffTop),
            Offset(x + 3, staffTop + staffHeight), paint);
      case 'repeatStart':
        paint.strokeWidth = 4.0;
        canvas.drawLine(Offset(x - 4, staffTop),
            Offset(x - 4, staffTop + staffHeight), paint);
        paint.strokeWidth = 1.5;
        canvas.drawLine(Offset(x + 3, staffTop),
            Offset(x + 3, staffTop + staffHeight), paint);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(x + 10, staffTop + staffHeight * 0.37), 3, paint);
        canvas.drawCircle(
            Offset(x + 10, staffTop + staffHeight * 0.63), 3, paint);
      case 'repeatEnd':
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
            Offset(x - 10, staffTop + staffHeight * 0.37), 3, paint);
        canvas.drawCircle(
            Offset(x - 10, staffTop + staffHeight * 0.63), 3, paint);
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawLine(Offset(x - 3, staffTop),
            Offset(x - 3, staffTop + staffHeight), paint);
        paint.strokeWidth = 4.0;
        canvas.drawLine(Offset(x + 4, staffTop),
            Offset(x + 4, staffTop + staffHeight), paint);
    }
  }

  // --- Dynamic ---
  void drawDynamic(Canvas canvas, Size size, StaffSymbol symbol,
      double staffTop, double staffHeight, Color color) {
    final dynText = symbol.data['text'] as String? ?? 'mf';
    final tp = TextPainter(
      text: TextSpan(
        text: dynText,
        style: TextStyle(
          fontSize: staffHeight * 0.3,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(symbol.x - tp.width / 2, staffTop + staffHeight + 8));
  }

  // --- Articulation ---
  void drawArticulation(Canvas canvas, Size size, StaffSymbol symbol,
      double staffTop, double lineSpacing, Paint paint) {
    final artType = symbol.data['articulation'] as String? ?? 'staccato';
    final x = symbol.x;
    final y = staffTop + symbol.staffPosition * lineSpacing / 2;

    switch (artType) {
      case 'staccato':
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 2.5, paint);
      case 'accent':
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.0;
        final s = lineSpacing * 0.4;
        final path = Path()
          ..moveTo(x - s, y - s * 0.5)
          ..lineTo(x + s, y)
          ..lineTo(x - s, y + s * 0.5);
        canvas.drawPath(path, paint);
      case 'tenuto':
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2.0;
        final s = lineSpacing * 0.4;
        canvas.drawLine(Offset(x - s, y), Offset(x + s, y), paint);
      case 'fermata':
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        final s = lineSpacing * 0.5;
        final path = Path()
          ..addArc(
              Rect.fromCenter(
                  center: Offset(x, y), width: s * 2, height: s * 1.5),
              3.14,
              3.14);
        canvas.drawPath(path, paint);
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y - 2), 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MusicStaffPainter oldDelegate) =>
      symbols != oldDelegate.symbols ||
      staffColor != oldDelegate.staffColor ||
      drawStaffLines != oldDelegate.drawStaffLines;
}

/// Widget wrapper for MusicStaffPainter
class MusicStaffWidget extends StatelessWidget {
  final List<StaffSymbol> symbols;
  final double width;
  final double height;
  final Color staffColor;
  final bool drawStaffLines;

  const MusicStaffWidget({
    Key? key,
    required this.symbols,
    this.width = 300,
    this.height = 100,
    this.staffColor = Colors.black,
    this.drawStaffLines = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MusicStaffPainter(
        symbols: symbols,
        staffColor: staffColor,
        drawStaffLines: drawStaffLines,
      ),
      size: Size(width, height),
    );
  }
}

/// Grand staff painter: treble + bass staves with brace and connecting barline.
class GrandStaffPainter extends CustomPainter {
  final List<StaffSymbol> trebleSymbols;
  final List<StaffSymbol> bassSymbols;
  final Color staffColor;
  final bool drawBrace;
  final bool drawConnectingBarline;

  /// Left margin reserved for brace + barline
  final double leftMargin;

  GrandStaffPainter({
    required this.trebleSymbols,
    required this.bassSymbols,
    this.staffColor = Colors.black,
    this.drawBrace = true,
    this.drawConnectingBarline = true,
    this.leftMargin = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Layout: top 45% = treble, bottom 45% = bass, 10% gap between
    final trebleHeight = size.height * 0.4;
    final gap = size.height * 0.1;
    final bassTop = trebleHeight + gap;

    final trebleStaffTop = trebleHeight * 0.2;
    final bassStaffTop = bassTop + trebleHeight * 0.2;
    final bassStaffH = trebleHeight * 0.6;

    // Draw brace
    if (drawBrace) {
      _drawBrace(canvas, trebleStaffTop, bassStaffTop + bassStaffH);
    }

    // Draw connecting vertical barline at the start
    if (drawConnectingBarline) {
      final paint = Paint()
        ..color = staffColor
        ..strokeWidth = 2.0;
      final x = leftMargin;
      canvas.drawLine(
        Offset(x, trebleStaffTop),
        Offset(x, bassStaffTop + bassStaffH),
        paint,
      );
    }

    // Draw treble staff
    canvas.save();
    canvas.translate(0, 0);
    final treblePainter = MusicStaffPainter(
      symbols: trebleSymbols,
      staffColor: staffColor,
      staffTopRatio: 0.2,
      staffHeightRatio: 0.6,
    );
    treblePainter.paint(canvas, Size(size.width, trebleHeight));
    canvas.restore();

    // Draw bass staff
    canvas.save();
    canvas.translate(0, bassTop);
    final bassPainter = MusicStaffPainter(
      symbols: bassSymbols,
      staffColor: staffColor,
      staffTopRatio: 0.2,
      staffHeightRatio: 0.6,
    );
    bassPainter.paint(canvas, Size(size.width, trebleHeight));
    canvas.restore();
  }

  void _drawBrace(Canvas canvas, double top, double bottom) {
    final height = bottom - top;
    final midY = top + height / 2;
    final x = leftMargin - 6;

    final paint = Paint()
      ..color = staffColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Brace as two mirrored cubic curves meeting at the middle
    final path = Path()
      ..moveTo(x, top)
      ..cubicTo(
          x - 10, top + height * 0.25, x - 10, midY - height * 0.1, x - 3, midY)
      ..cubicTo(x - 10, midY + height * 0.1, x - 10, bottom - height * 0.25, x,
          bottom);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GrandStaffPainter oldDelegate) =>
      trebleSymbols != oldDelegate.trebleSymbols ||
      bassSymbols != oldDelegate.bassSymbols ||
      staffColor != oldDelegate.staffColor;
}

/// Widget wrapper for GrandStaffPainter
class GrandStaffWidget extends StatelessWidget {
  final List<StaffSymbol> trebleSymbols;
  final List<StaffSymbol> bassSymbols;
  final double width;
  final double height;
  final Color staffColor;
  final bool drawBrace;
  final bool drawConnectingBarline;

  const GrandStaffWidget({
    Key? key,
    required this.trebleSymbols,
    required this.bassSymbols,
    this.width = 400,
    this.height = 200,
    this.staffColor = Colors.black,
    this.drawBrace = true,
    this.drawConnectingBarline = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GrandStaffPainter(
        trebleSymbols: trebleSymbols,
        bassSymbols: bassSymbols,
        staffColor: staffColor,
        drawBrace: drawBrace,
        drawConnectingBarline: drawConnectingBarline,
      ),
      size: Size(width, height),
    );
  }
}
