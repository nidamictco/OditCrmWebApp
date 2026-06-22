import 'dart:math';
import 'package:flutter/material.dart';
import 'package:Odit_CRM/core/theme/app_text_style.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../models/dashboard_models.dart';

class CashFlowChart extends StatefulWidget {
  const CashFlowChart({
    super.key,
    required this.data,
    this.selectedIndex,
    this.onHover,
    this.onExit,
  });

  final List<CashFlowPoint> data;
  final int? selectedIndex;
  final ValueChanged<int>? onHover;
  final VoidCallback? onExit;

  @override
  State<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends State<CashFlowChart>
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
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Tooltip
        if (widget.selectedIndex != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _Tooltip(
              point: widget.data[widget.selectedIndex!],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _Tooltip(
              point: widget.data[6],
              isDefault: true,
            ),
          ),
        // Chart
        Expanded(
          child: MouseRegion(
            onHover: (event) {
              final width = context.size?.width ?? 1;
              final index = ((event.localPosition.dx / width) *
                      widget.data.length)
                  .clamp(0, widget.data.length - 1)
                  .toInt();
              widget.onHover?.call(index);
            },
            onExit: (_) => widget.onExit?.call(),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) => CustomPaint(
                painter: _ChartPainter(
                  data: widget.data,
                  progress: _animation.value,
                  selectedIndex: widget.selectedIndex,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
        // Y-axis labels + legend
        const SizedBox(height: 12),
        Row(
          children: const [
            _LegendDot(color: AppThemeColors.chartReceipt, label: 'Receipt'),
            SizedBox(width: 20),
            _LegendDot(color: AppThemeColors.chartPayment, label: 'Payment'),
          ],
        ),
      ],
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({required this.point, this.isDefault = false});
  final CashFlowPoint point;
  final bool isDefault;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          point.label ?? '29 July 00:00',
          style: AppTextStyle.caption(),
        ),
        const SizedBox(width: 12),
        Text(
          '220,342.76',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppThemeColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppThemeColors.growthGreenBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '+3.4%',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppThemeColors.growthGreen,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyle.bodySmall()),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.data,
    required this.progress,
    this.selectedIndex,
  });

  final List<CashFlowPoint> data;
  final double progress;
  final int? selectedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const double paddingLeft = 40;
    const double paddingRight = 12;
    const double paddingTop = 10;
    const double paddingBottom = 24;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final maxVal = data.map((e) => max(e.receipt, e.payment)).reduce(max);
    final minVal = 0.0;
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    double xOf(int i) =>
        paddingLeft + (i / (data.length - 1)) * chartWidth;
    double yOf(double v) =>
        paddingTop + chartHeight - ((v - minVal) / range) * chartHeight * progress;

    // Grid lines
    final gridPaint = Paint()
      ..color = AppThemeColors.borderLight.withOpacity(0.5)
      ..strokeWidth = 0.8;
    final yLevels = [0, 100, 200, 500, 1000];
    for (final level in yLevels) {
      final y = paddingTop + chartHeight - (level / maxVal) * chartHeight;
      if (y < paddingTop || y > paddingTop + chartHeight) continue;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );
      // Y label
      final tp = TextPainter(
        text: TextSpan(
          text: level.toString(),
          style: GoogleFonts.poppins(
              fontSize: 9, color: AppThemeColors.textMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Build receipt path
    final receiptPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = xOf(i);
      final y = yOf(data[i].receipt);
      if (i == 0) {
        receiptPath.moveTo(x, y);
      } else {
        final prev = Offset(xOf(i - 1), yOf(data[i - 1].receipt));
        final curr = Offset(x, y);
        final cp1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
        final cp2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
        receiptPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
      }
    }

    // Fill under receipt
    final fillPath = Path.from(receiptPath)
      ..lineTo(xOf(data.length - 1), paddingTop + chartHeight)
      ..lineTo(xOf(0), paddingTop + chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppThemeColors.primary.withOpacity(0.12),
          AppThemeColors.primary.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromLTWH(0, paddingTop, size.width, chartHeight),
      );
    canvas.drawPath(fillPath, fillPaint);

    // Stroke receipt
    final strokePaint = Paint()
      ..color = AppThemeColors.chartReceipt
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(receiptPath, strokePaint);

    // Payment line (dashed-ish lighter)
    final paymentPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = xOf(i);
      final y = yOf(data[i].payment);
      if (i == 0) {
        paymentPath.moveTo(x, y);
      } else {
        final prev = Offset(xOf(i - 1), yOf(data[i - 1].payment));
        final curr = Offset(x, y);
        final cp1 = Offset(prev.dx + (curr.dx - prev.dx) / 2, prev.dy);
        final cp2 = Offset(prev.dx + (curr.dx - prev.dx) / 2, curr.dy);
        paymentPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
      }
    }
    final paymentPaint = Paint()
      ..color = AppThemeColors.chartPayment
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(paymentPath, paymentPaint);

    // Selected / default crosshair at index 6
    final selIdx = selectedIndex ?? 6;
    final crossX = xOf(selIdx);
    final crossY = yOf(data[selIdx].receipt);

    // Vertical line
    canvas.drawLine(
      Offset(crossX, paddingTop),
      Offset(crossX, paddingTop + chartHeight),
      Paint()
        ..color = AppThemeColors.primary.withOpacity(0.4)
        ..strokeWidth = 1.2,
    );

    // Dot
    canvas.drawCircle(
      Offset(crossX, crossY),
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(crossX, crossY),
      4,
      Paint()..color = AppThemeColors.chartDot,
    );
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.progress != progress || old.selectedIndex != selectedIndex;
}
