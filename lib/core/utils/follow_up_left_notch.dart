import 'package:flutter/material.dart';

class RibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = const Color(0xffA7F3D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//////////
///

class NotchedCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final double notchWidth;
  final double notchHeight;
  final double notchTop;

  const NotchedCard({
    super.key,
    required this.child,
    this.borderColor = const Color(0xFFA7F3D0),
    this.backgroundColor = Colors.white,
    this.borderRadius = 12,
    this.notchWidth = 12,
    this.notchHeight = 24,
    this.notchTop = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: notchWidth),
      child: CustomPaint(
        painter: _NotchedCardPainter(
          borderColor: borderColor,
          backgroundColor: backgroundColor,
          borderRadius: borderRadius,
          notchWidth: notchWidth,
          notchHeight: notchHeight,
          notchTop: notchTop,
        ),
        child: ClipPath(
          clipper: _NotchedCardClipper(
            borderRadius: borderRadius,
            notchWidth: notchWidth,
            notchHeight: notchHeight,
            notchTop: notchTop,
          ),
          child: Container(color: backgroundColor, child: child),
        ),
      ),
    );
  }
}

class _NotchedCardClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchWidth;
  final double notchHeight;
  final double notchTop;

  const _NotchedCardClipper({
    required this.borderRadius,
    required this.notchWidth,
    required this.notchHeight,
    required this.notchTop,
  });

  @override
  Path getClip(Size size) {
    final r = borderRadius;

    final top = notchTop;
    final mid = notchTop + notchHeight / 2;
    final bottom = notchTop + notchHeight;

    final path = Path();

    path.moveTo(r, 0);

    // Top
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r));

    // Right
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
    );

    // Bottom
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r));

    // Left side until notch
    path.lineTo(0, bottom);

    // ===== OUTWARD NOTCH =====

    path.quadraticBezierTo(0, bottom - 2, -2, bottom - 4);

    path.lineTo(-notchWidth, mid);

    path.lineTo(-2, top + 4);

    path.quadraticBezierTo(0, top + 2, 0, top);

    // =========================

    path.lineTo(0, r);

    path.arcToPoint(Offset(r, 0), radius: Radius.circular(r));

    path.close();

    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

class _NotchedCardPainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final double notchWidth;
  final double notchHeight;
  final double notchTop;

  const _NotchedCardPainter({
    required this.borderColor,
    required this.backgroundColor,
    required this.borderRadius,
    required this.notchWidth,
    required this.notchHeight,
    required this.notchTop,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _NotchedCardClipper(
      borderRadius: borderRadius,
      notchWidth: notchWidth,
      notchHeight: notchHeight,
      notchTop: notchTop,
    ).getClip(size);

    canvas.drawShadow(path, Colors.black.withOpacity(.08), 5, false);

    final fill = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fill);

    final border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_) => false;
}
