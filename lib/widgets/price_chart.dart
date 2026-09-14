import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PriceBarChart extends StatelessWidget {
  const PriceBarChart({
    super.key,
    required this.values,
    this.highlightIndex,
  });

  final List<double> values;
  final int? highlightIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: CustomPaint(
        size: const Size(double.infinity, 150),
        painter: _BarChartPainter(
          values: values,
          highlightIndex: highlightIndex ?? values.length - 2,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.highlightIndex,
  });

  final List<double> values;
  final int highlightIndex;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final gap = size.width / values.length;
    final barWidth = gap * 0.42;
    final baseline = size.height - 4;

    final trackPaint = Paint()..color = AppColors.chartTrack;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(gap * highlightIndex + (gap - barWidth) / 2 - 2, 4, barWidth + 4, baseline - 4),
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ),
      trackPaint,
    );

    for (var i = 0; i < values.length; i++) {
      final normalized = values[i] / maxValue;
      final height = baseline * normalized;
      final left = gap * i + (gap - barWidth) / 2;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, baseline - height, barWidth, height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );

      final isHighlight = i == highlightIndex;
      final paint = Paint()
        ..color = isHighlight ? AppColors.chartPink : AppColors.chartBlue;

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.highlightIndex != highlightIndex;
}

class RangeTabs extends StatelessWidget {
  const RangeTabs({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected == option ? AppColors.blueSoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
