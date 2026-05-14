import 'package:flutter/material.dart';

/// Paints a time signature (two stacked numbers).
/// [upper]: top number (beats per measure)
/// [lower]: bottom number (beat unit)
class TimeSignaturePainter extends CustomPainter {
  final int upper;
  final int lower;
  final Color color;

  TimeSignaturePainter({required this.upper, required this.lower, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final style = TextStyle(
      fontSize: size.height * 0.38,
      fontWeight: FontWeight.bold,
      color: color,
    );

    final topSpan = TextSpan(text: '$upper', style: style);
    final bottomSpan = TextSpan(text: '$lower', style: style);

    final topPainter = TextPainter(text: topSpan, textDirection: TextDirection.ltr)..layout();
    final bottomPainter = TextPainter(text: bottomSpan, textDirection: TextDirection.ltr)..layout();

    topPainter.paint(canvas, Offset((size.width - topPainter.width) / 2, size.height * 0.05));
    bottomPainter.paint(canvas, Offset((size.width - bottomPainter.width) / 2, size.height * 0.5));
  }

  @override
  bool shouldRepaint(covariant TimeSignaturePainter oldDelegate) =>
      upper != oldDelegate.upper || lower != oldDelegate.lower || color != oldDelegate.color;
}

/// Widget wrapper for TimeSignaturePainter
class TimeSignatureWidget extends StatelessWidget {
  final int upper;
  final int lower;
  final double size;
  final Color color;

  const TimeSignatureWidget({
    Key? key,
    required this.upper,
    required this.lower,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TimeSignaturePainter(upper: upper, lower: lower, color: color),
      size: Size(size * 0.6, size * 1.2),
    );
  }
}
