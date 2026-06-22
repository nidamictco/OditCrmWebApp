import 'dart:math';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class PayableReceivableChart extends StatefulWidget {
  const PayableReceivableChart({
    super.key,
    required this.receivable,
    required this.payable,
  });

  final double receivable;
  final double payable;

  @override
  State<PayableReceivableChart> createState() =>
      _PayableReceivableChartState();
}

class _PayableReceivableChartState extends State<PayableReceivableChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatK(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.receivable + widget.payable;
    final receivableFrac = widget.receivable / total;

    return Column(
      children: [
        // Donut
        SizedBox(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, __) => CustomPaint(
              painter: _DonutPainter(
                receivableFrac: receivableFrac,
                progress: _animation.value,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RECEIVABLE',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: AppThemeColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatK(widget.receivable),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppThemeColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend rows
        _LegendRow(
          color: AppThemeColors.donutReceivable,
          label: 'Receivable',
          value:
              '${widget.receivable.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        ),
        const SizedBox(height: 8),
        _LegendRow(
          color: AppThemeColors.donutPayable,
          label: 'Payable',
          value:
              '${widget.payable.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.bodySmall(),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppThemeColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.receivableFrac, required this.progress});

  final double receivableFrac;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    const strokeWidth = 28.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final bgPaint = Paint()
      ..color = AppThemeColors.borderLight.withOpacity(0.4)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -pi / 2, 2 * pi, false, bgPaint);

    // Receivable arc (green)
    final receivableAngle = 2 * pi * receivableFrac * progress;
    final receivablePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C896), Color(0xFF00E5BB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -pi / 2, receivableAngle, false, receivablePaint);

    // Payable arc (lighter teal, small gap)
    const gapAngle = 0.04;
    final payableStart = -pi / 2 + receivableAngle + gapAngle;
    final payableAngle = 2 * pi * (1 - receivableFrac) * progress - gapAngle;
    if (payableAngle > 0) {
      final payablePaint = Paint()
        ..color = AppThemeColors.donutPayable.withOpacity(0.55)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, payableStart, payableAngle, false, payablePaint);
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.progress != progress || old.receivableFrac != receivableFrac;
}
