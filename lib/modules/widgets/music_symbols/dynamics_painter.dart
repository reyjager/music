import 'package:flutter/material.dart';

/// Paints a dynamic marking using italic musical text style.
/// [dynamicType]: pp, p, mp, mf, f, ff, sfz
class DynamicsPainter extends CustomPainter {
  final String dynamicType;
  final Color color;

  DynamicsPainter({required this.dynamicType, this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
      fontSize: size.height * 0.5,
      color: color,
    );

    final textSpan = TextSpan(text: dynamicType, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant DynamicsPainter oldDelegate) =>
      dynamicType != oldDelegate.dynamicType || color != oldDelegate.color;
}

/// Widget wrapper for DynamicsPainter
class DynamicsWidget extends StatelessWidget {
  final String dynamicType;
  final double size;
  final Color color;

  const DynamicsWidget({
    Key? key,
    required this.dynamicType,
    this.size = 60,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DynamicsPainter(dynamicType: dynamicType, color: color),
      size: Size(size * 1.2, size * 0.8),
    );
  }
}
