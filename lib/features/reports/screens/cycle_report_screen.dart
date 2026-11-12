import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/report_widgets.dart';

/// Statistik siklus yang dihitung dari tanggal haid yang dicatat di Kalender.
class CycleStats {
  final List<int> cycleLengths;
  final List<String> cycleLabels;
  final List<int> periodLengths;
  final List<String> periodLabels;

  const CycleStats({
    required this.cycleLengths,
    required this.cycleLabels,
    required this.periodLengths,
    required this.periodLabels,
  });

  static int _diff(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  static CycleStats from(Iterable<DateTime> logged) {
    final days = logged.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()..sort();

    // Kelompokkan tanggal berurutan menjadi blok haid
    final blocks = <List<DateTime>>[];
    for (final day in days) {
      if (blocks.isNotEmpty && _diff(blocks.last.last, day) == 1) {
        blocks.last.add(day);
      } else {
        blocks.add([day]);
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Panjang siklus = jarak antar hari pertama haid
    final cycleLengths = <int>[];
    final cycleLabels = <String>[];
    for (int i = 1; i < blocks.length; i++) {
      cycleLengths.add(_diff(blocks[i - 1].first, blocks[i].first));
      cycleLabels.add(shortDate(blocks[i - 1].first));
    }

    // Lama haid = jumlah hari per blok (haid yang masih berjalan hari ini dilewati)
    final periodLengths = <int>[];
    final periodLabels = <String>[];
    for (int i = 0; i < blocks.length; i++) {
      final b = blocks[i];
      final ongoing = i == blocks.length - 1 && b.last == today;
      if (ongoing) continue;
      periodLengths.add(b.length);
      periodLabels.add(shortDate(b.first));
    }

    const maxItems = 12;
    List<T> tail<T>(List<T> l) => l.length > maxItems ? l.sublist(l.length - maxItems) : l;

    return CycleStats(
      cycleLengths: tail(cycleLengths),
      cycleLabels: tail(cycleLabels),
      periodLengths: tail(periodLengths),
      periodLabels: tail(periodLabels),
    );
  }

  static double average(List<int> l) => l.reduce((a, b) => a + b) / l.length;
  static int minOf(List<int> l) => l.reduce((a, b) => a < b ? a : b);
  static int maxOf(List<int> l) => l.reduce((a, b) => a > b ? a : b);
}

class CycleReportScreen extends StatelessWidget {
  const CycleReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    context.watchTheme();
    final stats = CycleStats.from(cycle.loggedPeriodDates);

    return ReportScaffold(
      title: 'Cycle length',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReportCard(
            title: 'Cycle length',
            subtitle: 'Days from the first day of one period to the first day of the next',
            child: stats.cycleLengths.isEmpty
                ? const ReportEmpty(
              icon: Icons.bar_chart_rounded,
              message: 'Log at least two periods in the Calendar to see your cycle length.',
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleBarChart(
                  values: stats.cycleLengths.map((e) => e.toDouble()).toList(),
                  labels: stats.cycleLabels,
                  height: 200,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        label: 'Average',
                        value: '${formatNumber(CycleStats.average(stats.cycleLengths))} days',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatChip(
                        label: 'Shortest',
                        value: '${CycleStats.minOf(stats.cycleLengths)} days',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatChip(
                        label: 'Longest',
                        value: '${CycleStats.maxOf(stats.cycleLengths)} days',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ReportCard(
            title: 'Period length',
            subtitle: 'How many days each period lasted',
            child: stats.periodLengths.isEmpty
                ? const ReportEmpty(
              icon: Icons.water_drop_outlined,
              message: 'Complete a period in the Calendar to see how long it lasts.',
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SimpleBarChart(
                  values: stats.periodLengths.map((e) => e.toDouble()).toList(),
                  labels: stats.periodLabels,
                  color: AppColors.predictPeriod,
                  highlightColor: AppColors.primaryPink,
                  height: 180,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatChip(
                        label: 'Average',
                        value: '${formatNumber(CycleStats.average(stats.periodLengths))} days',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatChip(
                        label: 'Shortest',
                        value: '${CycleStats.minOf(stats.periodLengths)} days',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatChip(
                        label: 'Longest',
                        value: '${CycleStats.maxOf(stats.periodLengths)} days',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'These charts are based on the periods you logged. Lunary is a tracking tool, not a medical device.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
