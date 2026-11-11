import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/services/cycle_settings.dart';
import '../../reports/screens/cycle_report_screen.dart';
import '../../reports/widgets/report_widgets.dart';

const Color _okColor = Color(0xFF3AB795);
const Color _warnColor = Color(0xFFF0A868);
const Color _noDataColor = Color(0xFF9CA3AF);

/// Data untuk bar rentang (posisi nilai pengguna terhadap rentang umum).
class _RangeData {
  final double value;
  final double min;
  final double max;
  final double typicalStart;
  final double typicalEnd;

  const _RangeData({
    required this.value,
    required this.min,
    required this.max,
    required this.typicalStart,
    required this.typicalEnd,
  });
}

class _TypeInfo {
  final String title;
  final String label;
  final String desc;
  final Color color;
  final IconData icon;
  final _RangeData? range;

  /// Teks tombol di bawah deskripsi (mis. "Log your period in Calendar").
  final String? actionLabel;

  const _TypeInfo({
    required this.title,
    required this.label,
    required this.desc,
    required this.color,
    required this.icon,
    this.range,
    this.actionLabel,
  });

  bool get hasData => color != _noDataColor;
}

const String _logAction = 'Log your period in Calendar';

_TypeInfo _cycleLengthInfo(double? avg) {
  if (avg == null) {
    return const _TypeInfo(
      title: 'Cycle length',
      label: 'No data yet',
      desc: 'Log at least two periods in the Calendar, or fill in your cycle length in Cycle and ovulation.',
      color: _noDataColor,
      icon: Icons.autorenew_rounded,
      actionLabel: _logAction,
    );
  }

  final v = formatNumber(avg);
  final range = _RangeData(value: avg, min: 15, max: 45, typicalStart: 21, typicalEnd: 35);

  if (avg < 21) {
    return _TypeInfo(
      title: 'Cycle length',
      label: 'Short',
      desc: 'Your cycle averages $v days, shorter than 21 days. Periods come more often than usual.',
      color: _warnColor,
      icon: Icons.autorenew_rounded,
      range: range,
    );
  }
  if (avg > 35) {
    return _TypeInfo(
      title: 'Cycle length',
      label: 'Long',
      desc: 'Your cycle averages $v days, longer than 35 days. Periods come less often than usual.',
      color: _warnColor,
      icon: Icons.autorenew_rounded,
      range: range,
    );
  }
  return _TypeInfo(
    title: 'Cycle length',
    label: 'Typical',
    desc: 'Your cycle averages $v days, within the common 21 to 35 day range.',
    color: _okColor,
    icon: Icons.autorenew_rounded,
    range: range,
  );
}

_TypeInfo _regularityInfo(List<int> lengths) {
  if (lengths.length >= 3) {
    final variation = CycleStats.maxOf(lengths) - CycleStats.minOf(lengths);
    final range = _RangeData(
      value: variation.toDouble(),
      min: 0,
      max: 14,
      typicalStart: 0,
      typicalEnd: 7,
    );

    if (variation <= 7) {
      return _TypeInfo(
        title: 'Regularity',
        label: 'Regular',
        desc:
        'Your cycles differ by only $variation day${variation == 1 ? '' : 's'}, so predictions should be fairly reliable.',
        color: _okColor,
        icon: Icons.timeline_rounded,
        range: range,
      );
    }
    return _TypeInfo(
      title: 'Regularity',
      label: 'Irregular',
      desc: 'Your cycles differ by $variation days. Treat predictions as estimates and keep logging every period.',
      color: _warnColor,
      icon: Icons.timeline_rounded,
      range: range,
    );
  }

  if (CycleSettings.irregularCycle) {
    return const _TypeInfo(
      title: 'Regularity',
      label: 'Irregular',
      desc: 'You told us your cycle is irregular. Treat predictions as estimates and keep logging.',
      color: _warnColor,
      icon: Icons.timeline_rounded,
      actionLabel: _logAction,
    );
  }

  return const _TypeInfo(
    title: 'Regularity',
    label: 'Not enough data',
    desc: 'Lunary needs at least 3 logged cycles to tell how regular your cycle is.',
    color: _noDataColor,
    icon: Icons.timeline_rounded,
    actionLabel: _logAction,
  );
}

_TypeInfo _periodLengthInfo(double? avg) {
  if (avg == null) {
    return const _TypeInfo(
      title: 'Period duration',
      label: 'No data yet',
      desc: 'Complete a period in the Calendar, or fill in your period length in Cycle and ovulation.',
      color: _noDataColor,
      icon: Icons.water_drop_outlined,
      actionLabel: _logAction,
    );
  }

  final v = formatNumber(avg);
  final range = _RangeData(value: avg, min: 1, max: 10, typicalStart: 3, typicalEnd: 7);

  if (avg < 3) {
    return _TypeInfo(
      title: 'Period duration',
      label: 'Short',
      desc: 'Your period averages $v days, shorter than the common 3 to 7 days.',
      color: _warnColor,
      icon: Icons.water_drop_outlined,
      range: range,
    );
  }
  if (avg > 7) {
    return _TypeInfo(
      title: 'Period duration',
      label: 'Long',
      desc: 'Your period averages $v days, longer than the common 3 to 7 days.',
      color: _warnColor,
      icon: Icons.water_drop_outlined,
      range: range,
    );
  }
  return _TypeInfo(
    title: 'Period duration',
    label: 'Typical',
    desc: 'Your period averages $v days, within the common 3 to 7 day range.',
    color: _okColor,
    icon: Icons.water_drop_outlined,
    range: range,
  );
}

class CycleTypeScreen extends StatelessWidget {
  const CycleTypeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final stats = CycleStats.from(cycle.loggedPeriodDates);

    final hasCycles = stats.cycleLengths.isNotEmpty;
    final hasPeriods = stats.periodLengths.isNotEmpty;

    final double? avgCycle = hasCycles
        ? CycleStats.average(stats.cycleLengths)
        : CycleSettings.cycleLength?.toDouble();
    final double? avgPeriod = hasPeriods
        ? CycleStats.average(stats.periodLengths)
        : CycleSettings.periodLength?.toDouble();

    final infos = [
      _cycleLengthInfo(avgCycle),
      _regularityInfo(stats.cycleLengths),
      _periodLengthInfo(avgPeriod),
    ];

    // Hanya item yang punya data yang dihitung, supaya item "belum ada data"
    // tidak dianggap sebagai variasi.
    final withData = infos.where((i) => i.hasData).toList();
    final hasAny = withData.isNotEmpty;
    final allGood = hasAny && withData.every((i) => i.color == _okColor);
    final missingSome = withData.length < infos.length;

    String source;
    if (hasCycles) {
      source =
      'Based on ${stats.cycleLengths.length} logged cycle${stats.cycleLengths.length == 1 ? '' : 's'}';
    } else if (hasAny) {
      source = 'Based on your survey / cycle settings';
    } else {
      source = 'No data yet';
    }

    return ReportScaffold(
      title: 'Cycle type',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummary(infos, allGood, hasAny, missingSome, source),
          ...infos.map((i) => _buildTile(context, i)),
          _buildGuide(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'This is general information based on what you logged, not a diagnosis. '
                  'If your cycle changes suddenly, bleeding is very heavy, or pain is severe, talk to a doctor.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(
      List<_TypeInfo> infos,
      bool allGood,
      bool hasAny,
      bool missingSome,
      String source,
      ) {
    final String headline;
    final String sub;

    if (!hasAny) {
      headline = 'Your cycle type will show up here';
      sub = 'Log your periods in the Calendar to get started.';
    } else if (allGood) {
      headline = 'Your cycle looks typical';
      sub = missingSome
          ? 'Everything we can measure is within the common range. Log more cycles for a fuller picture.'
          : 'Everything is within the common range.';
    } else {
      headline = 'Your cycle has some variations';
      sub = 'Variations are common. Keep logging so Lunary can learn your pattern.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.category_outlined, color: AppColors.primaryPurple, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  headline,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            sub,
            style: const TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.4),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: infos.map((i) => _badge(i.label, i.color)).toList(),
          ),
          const SizedBox(height: 12),
          Text(source, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color, height: 1.0),
      ),
    );
  }

  Widget _buildTile(BuildContext context, _TypeInfo info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(info.icon, color: info.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        info.title,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText),
                      ),
                    ),
                    _badge(info.label, info.color),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  info.desc,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.darkerSubText, height: 1.45),
                ),
                if (info.range != null) ...[
                  const SizedBox(height: 14),
                  _RangeBar(data: info.range!, color: info.color),
                ],
                if (info.actionLabel != null) ...[
                  const SizedBox(height: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => handleAppNavTap(context, AppNavTab.calendar),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            info.actionLabel!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right_rounded,
                              size: 18, color: AppColors.primaryPurple),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuide() {
    const items = [
      ['Typical cycle', '21 to 35 days between the first day of one period and the next.'],
      ['Short cycle', 'Under 21 days. Can happen in adolescence or with hormonal changes.'],
      ['Long cycle', 'Over 35 days. Stress, weight changes, PCOS, or thyroid issues can be factors.'],
      ['Irregular cycle', 'Cycle length varies by more than about 7 days from month to month.'],
      ['Short period', 'Bleeding for less than 3 days. Often harmless, but mention it to a doctor if it is new for you.'],
      ['Long period', 'Bleeding for more than 7 days. Worth checking with a doctor if it happens repeatedly.'],
    ];

    return ReportCard(
      title: 'Know the types',
      subtitle: 'Quick guide to the terms above',
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    margin: const EdgeInsets.only(right: 10),
                    color: AppColors.primaryPink,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i][0],
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          items[i][1],
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.darkerSubText, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Bar kecil: rentang skala, zona umum (hijau), dan penanda posisi nilai pengguna.
class _RangeBar extends StatelessWidget {
  final _RangeData data;
  final Color color;

  const _RangeBar({Key? key, required this.data, required this.color}) : super(key: key);

  String _n(double v) => formatNumber(v);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            double pos(double v) =>
                ((v - data.min) / (data.max - data.min)).clamp(0.0, 1.0) * width;

            final zoneLeft = pos(data.typicalStart);
            final zoneWidth = pos(data.typicalEnd) - zoneLeft;
            const markerSize = 16.0;
            final markerLeft = (pos(data.value) - markerSize / 2)
                .clamp(0.0, width - markerSize)
                .toDouble();

            return SizedBox(
              height: markerSize,
              width: width,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 5,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEAF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Positioned(
                    left: zoneLeft,
                    width: zoneWidth,
                    top: 5,
                    height: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _okColor.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Positioned(
                    left: markerLeft,
                    top: 0,
                    child: Container(
                      width: markerSize,
                      height: markerSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_n(data.min)}', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
            Text(
              'Typical: ${_n(data.typicalStart)} to ${_n(data.typicalEnd)} days',
              style: const TextStyle(fontSize: 10.5, color: _okColor, fontWeight: FontWeight.w600),
            ),
            Text('${_n(data.max)}+', style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}