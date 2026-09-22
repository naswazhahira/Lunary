import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/painters/dashed_circle_painter.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _item(_dot(AppColors.period), 'Period'),
        _item(_dot(AppColors.predictPeriod), 'Predict Period'),
        _item(
          CustomPaint(
            size: const Size(10, 10),
            painter: DashedCirclePainter(color: AppColors.fertile),
          ),
          'Fertile',
        ),
        _item(_dot(AppColors.ovulation), 'Ovulation'),
      ],
    );
  }

  Widget _dot(Color color) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );

  Widget _item(Widget marker, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
