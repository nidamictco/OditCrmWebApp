import 'package:flutter/material.dart';

class DottedArrowDown extends StatelessWidget {
  final double height;
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashGap;
  final double arrowSize;

  const DottedArrowDown({
    super.key,
    this.height = 120,
    this.color = Colors.grey,
    this.strokeWidth = 1,
    this.dashHeight = 1.5,
    this.dashGap = 3,
    this.arrowSize = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15,
      // height: height,
      child: CustomPaint(
        painter: _DottedArrowPainter(
          color: color,
          strokeWidth: strokeWidth,
          dashHeight: dashHeight,
          dashGap: dashGap,
          arrowSize: arrowSize,
        ),
      ),
    );
  }
}

class _DottedArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashHeight;
  final double dashGap;
  final double arrowSize;

  _DottedArrowPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashHeight,
    required this.dashGap,
    required this.arrowSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;

    // Draw dotted line
    double y = 0;
    final lineEnd = size.height - arrowSize;

    while (y < lineEnd) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, (y + dashHeight).clamp(0, lineEnd)),
        paint,
      );
      y += dashHeight + dashGap;
    }

    // Draw arrow
    final arrowTip = Offset(centerX, size.height);
    canvas.drawLine(
      Offset(centerX - arrowSize / 1.3, size.height - arrowSize),
      arrowTip,
      paint,
    );
    canvas.drawLine(
      Offset(centerX + arrowSize / 1.3, size.height - arrowSize),
      arrowTip,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
