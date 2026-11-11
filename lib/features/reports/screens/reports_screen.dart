import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/services/tracker_store.dart';
import '../widgets/report_widgets.dart';
import 'cycle_report_screen.dart';
import 'tracker_report_screen.dart';

class ReportsScreen extends StatefulWidget {
  final String accountId;
  final bool isMetric;

  const ReportsScreen({Key? key, required this.accountId, required this.isMetric})
      : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<TrackerType, MapEntry<DateTime, double>?> _latest = {};

  @override
  void initState() {
    super.initState();
    _loadLatest();
  }

  Future<void> _loadLatest() async {
    final result = <TrackerType, MapEntry<DateTime, double>?>{};
    for (final info in TrackerInfo.all) {
      final data = await TrackerStore.load(widget.accountId, info.type);
      if (data.isEmpty) {
        result[info.type] = null;
      } else {
        result[info.type] = data.entries.reduce((a, b) => a.key.isAfter(b.key) ? a : b);
      }
    }
    if (!mounted) return;
    setState(() => _latest = result);
  }

  Future<void> _openTracker(TrackerInfo info) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackerReportScreen(
          type: info.type,
          accountId: widget.accountId,
          isMetric: widget.isMetric,
        ),
      ),
    );
    _loadLatest();
  }

  @override
  Widget build(BuildContext context) {
    return ReportScaffold(
      title: 'Charts & reports',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCycleCard(),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: TrackerInfo.all.map(_buildTrackerCard).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleCard() {
    final cycle = context.watch<CycleProvider>();
    final stats = CycleStats.from(cycle.loggedPeriodDates);
    final hasData = stats.cycleLengths.isNotEmpty;

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CycleReportScreen()),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Cycle length',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 12),
              SimpleBarChart(
                values: hasData
                    ? stats.cycleLengths.map((e) => e.toDouble()).toList()
                    : const [18, 26, 22, 30, 24, 28],
                showLabels: false,
                height: 64,
                color: hasData ? const Color(0xFFB197FC) : const Color(0xFFE5E7EB),
                highlightLast: hasData,
              ),
              const SizedBox(height: 10),
              Text(
                hasData
                    ? 'Average ${formatNumber(CycleStats.average(stats.cycleLengths))} days · ${stats.cycleLengths.length} cycles'
                    : 'Log at least 2 periods in the Calendar',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackerCard(TrackerInfo info) {
    final latest = _latest[info.type];
    final subtitle = latest == null
        ? 'No data yet'
        : '${info.format(latest.value, widget.isMetric)}\n${shortDate(latest.key)}';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTracker(info),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(info.icon, color: info.color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(info.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.darkText)),
              const SizedBox(height: 4),
              Text(subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.3)),
            ],
          ),
        ),
      ),
    );
  }
}