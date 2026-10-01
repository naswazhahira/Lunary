import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/painters/cycle_phase_ring_painter.dart';
import '../../../core/painters/mini_line_chart_painter.dart';

class CycleDetailScreen extends StatelessWidget {
  const CycleDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhaseSummaryCard(cycle),
                      const SizedBox(height: 20),
                      _buildSymptomPredictionCard(),
                      const SizedBox(height: 20),
                      _buildFertilityCard(cycle),
                      const SizedBox(height: 20),
                      _buildHormonalCard(),
                      const SizedBox(height: 20),
                      _buildLifestyleCard(cycle),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RoutePaths.calendar);
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
          ),
          const Expanded(
            child: Text(
              'Cycle Insights',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildPhaseSummaryCard(CycleProvider cycle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day ${cycle.currentCycleDay} - ${cycle.currentPhaseLabel}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cycle.daysUntilNextPeriod != null
                ? 'There are ${cycle.daysUntilNextPeriod} days before your next period starts.'
                : 'Log your first period so Lunary can start predicting your cycle.',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkerSubText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: CyclePhaseRingPainter(
                      periodFraction: cycle.periodFraction,
                      follicularFraction: cycle.follicularFraction,
                      fertileFraction: cycle.fertileFraction,
                      lutealFraction: cycle.lutealFraction,
                      todayProgress: cycle.todayCycleProgress,
                      ovulationProgress: cycle.ovulationCycleProgress,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Day ${cycle.currentCycleDay}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cycle.currentPhaseLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.darkerSubText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: const [
              _RingLegendDot(color: Color(0xFFED5589), label: 'Period'),
              _RingLegendDot(color: Color(0xFF6C5CE7), label: 'Follicular'),
              _RingLegendDot(color: Color(0xFFF5C77E), label: 'Fertile window'),
              _RingLegendDot(color: Color(0xFFD8CFF0), label: 'Luteal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomPredictionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.circle, size: 8, color: AppColors.primaryPink),
              SizedBox(width: 8),
              Text(
                'Symptom prediction',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Feeling a bit low-energy today is normal, your hormones are still finding their rhythm.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkerSubText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildSymptomRow(Icons.spa_outlined, 'Dry hair'),
          const SizedBox(height: 12),
          _buildSymptomRow(Icons.battery_2_bar_rounded, 'Tired'),
        ],
      ),
    );
  }

  Widget _buildSymptomRow(IconData icon, String label) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryPink.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryPink),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildFertilityCard(CycleProvider cycle) {
    final values = List.generate(20, (i) {
      const ov = 10.0;
      final distance = (i - ov).abs();
      return (60 - distance * distance * 0.55).clamp(2, 65).toDouble();
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.circle, size: 8, color: AppColors.primaryPurple),
              SizedBox(width: 8),
              Text(
                'Fertility level',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            cycle.daysUntilOvulation != null
                ? 'Estimated ovulation in ${cycle.daysUntilOvulation} days.'
                : 'Not enough data yet to predict ovulation.',
            style: const TextStyle(fontSize: 12, color: AppColors.darkerSubText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: MiniLineChartPainter(
                series: [
                  ChartSeries(
                    values: values,
                    color: AppColors.primaryPurple,
                    label: 'Fertility',
                  )
                ],
                maxY: 70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHormonalCard() {
    final estrogen = List.generate(20, (i) {
      const peak = 10.0;
      final distance = (i - peak).abs();
      return (80 - distance * distance * 0.7).clamp(5, 85).toDouble();
    });
    final progesterone = List.generate(20, (i) {
      const peak = 15.0;
      final distance = (i - peak).abs();
      return (70 - distance * distance * 0.6).clamp(5, 75).toDouble();
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hormonal changes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Estrogen and progesterone levels gradually increase.',
            style: TextStyle(fontSize: 12, color: AppColors.darkerSubText),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: MiniLineChartPainter(
                series: [
                  ChartSeries(
                    values: estrogen,
                    color: const Color(0xFF3AB795),
                    label: 'Estrogen',
                  ),
                  ChartSeries(
                    values: progesterone,
                    color: const Color(0xFFF0A868),
                    label: 'Progesterone',
                  ),
                ],
                maxY: 90,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _RingLegendDot(color: Color(0xFF3AB795), label: 'Estrogen'),
              SizedBox(width: 16),
              _RingLegendDot(color: Color(0xFFF0A868), label: 'Progesterone'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleCard(CycleProvider cycle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lifestyle guide - ${cycle.currentPhaseLabel}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipSection(
            'Sex tips',
            'Use water-based lubricants if you feel dry - they are safer for condoms than oil-based ones.',
          ),
          const SizedBox(height: 14),
          _buildTipSection(
            'Diet tips',
            'Reduce saturated fat intake to help maintain a healthy weight and hormonal balance.',
          ),
          const SizedBox(height: 14),
          _buildTipSection(
            'Exercise tips',
            'Gentle walking, light cardio, or yoga suits this phase well to keep your energy balanced.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 3, height: 34, color: AppColors.primaryPink),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkerSubText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _RingLegendDot({
    Key? key,
    required this.color,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.darkerSubText),
        ),
      ],
    );
  }
}
