import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/services/tracker_store.dart';
import '../widgets/report_widgets.dart';

class TrackerReportScreen extends StatefulWidget {
  final TrackerType type;
  final String accountId;
  final bool isMetric;

  const TrackerReportScreen({
    Key? key,
    required this.type,
    required this.accountId,
    required this.isMetric,
  }) : super(key: key);

  @override
  State<TrackerReportScreen> createState() => _TrackerReportScreenState();
}

class _TrackerReportScreenState extends State<TrackerReportScreen> {
  Map<DateTime, double> _data = {};
  bool _loading = true;
  late int _rangeDays;

  TrackerInfo get _info => TrackerInfo.of(widget.type);
  List<int> get _ranges => _info.isBar ? const [7, 14, 30] : const [7, 30, 90];

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _daysAgo(int n) {
    final t = _today;
    return DateTime(t.year, t.month, t.day - n);
  }

  @override
  void initState() {
    super.initState();
    _rangeDays = _info.isBar ? 14 : 30;
    _load();
  }

  Future<void> _load() async {
    final d = await TrackerStore.load(widget.accountId, widget.type);
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  List<MapEntry<DateTime, double>> _entriesInRange() {
    final from = _daysAgo(_rangeDays - 1);
    final list = _data.entries.where((e) => !e.key.isBefore(from) && !e.key.isAfter(_today)).toList();
    list.sort((a, b) => a.key.compareTo(b.key));
    return list;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _openAddSheet() async {
    final result = await showModalBottomSheet<_EntryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddEntrySheet(info: _info, isMetric: widget.isMetric),
    );
    if (result == null) return;

    double value = result.storedValue;
    if (_info.accumulate) {
      value += _data[result.date] ?? 0;
    }
    await TrackerStore.setValue(widget.accountId, widget.type, result.date, value);
    await _load();
    if (!mounted) return;
    _snack('Saved.');
  }

  Future<void> _deleteEntry(DateTime date) async {
    await TrackerStore.remove(widget.accountId, widget.type, date);
    await _load();
    if (!mounted) return;
    _snack('Entry deleted.');
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final inRange = _entriesInRange();
    context.watchTheme();

    return ReportScaffold(
      title: info.title,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryPurple,
        onPressed: _openAddSheet,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          info.accumulate ? 'Add water' : 'Add entry',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _buildChartCard(inRange),
          _buildHistoryCard(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Tip: set a daily reminder in Profile > Reminders so you never forget to log.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<MapEntry<DateTime, double>> inRange) {
    final info = _info;

    return ReportCard(
      title: info.title,
      subtitle: info.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: _ranges
                .map((d) => ChoiceChip(
              label: Text('$d days'),
              selected: _rangeDays == d,
              selectedColor: AppColors.primaryPurple.withValues(alpha: 0.18),
              onSelected: (_) => setState(() => _rangeDays = d),
            ))
                .toList(),
          ),
          const SizedBox(height: 16),
          if (_data.isEmpty)
            ReportEmpty(
              icon: info.icon,
              message: 'No entries yet. Tap the button below to log your first one.',
            )
          else if (inRange.isEmpty)
            ReportEmpty(icon: info.icon, message: 'No entries in the last $_rangeDays days.')
          else ...[
              _buildChart(inRange),
              const SizedBox(height: 14),
              _buildStats(inRange),
            ],
        ],
      ),
    );
  }

  Widget _buildChart(List<MapEntry<DateTime, double>> inRange) {
    final info = _info;

    if (info.isBar) {
      final values = <double>[];
      final labels = <String>[];
      for (int i = _rangeDays - 1; i >= 0; i--) {
        final day = _daysAgo(i);
        values.add(info.toDisplay(_data[day] ?? 0, widget.isMetric));
        labels.add(shortDate(day));
      }
      return SimpleBarChart(
        values: values,
        labels: labels,
        color: info.color.withValues(alpha: 0.5),
        highlightColor: info.color,
        height: 200,
        decimals: info.decimals,
      );
    }

    final points = inRange
        .map((e) => LinePoint(e.key, info.toDisplay(e.value, widget.isMetric)))
        .toList();

    // Suhu: tandai hari ovulasi prediksi dari data siklus
    final markers = <DateTime>[];
    if (info.type == TrackerType.temperature) {
      final cycle = context.read<CycleProvider>();
      for (int i = 0; i < _rangeDays; i++) {
        final d = _daysAgo(i);
        if (!d.isBefore(points.first.date) && cycle.isOvulationDate(d)) markers.add(d);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleLineChart(
          points: points,
          color: info.color,
          height: 220,
          decimals: info.decimals,
          markers: markers,
        ),
        if (markers.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Dashed line = predicted ovulation day',
              style: TextStyle(fontSize: 11, color: Color(0xFF26A69A))),
        ],
      ],
    );
  }

  Widget _buildStats(List<MapEntry<DateTime, double>> inRange) {
    final info = _info;
    final values = inRange.map((e) => e.value).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final highest = values.reduce((a, b) => a > b ? a : b);
    final latest = inRange.last.value;

    return Row(
      children: [
        Expanded(child: StatChip(label: 'Latest', value: info.format(latest, widget.isMetric))),
        const SizedBox(width: 8),
        Expanded(child: StatChip(label: 'Average', value: info.format(avg, widget.isMetric))),
        const SizedBox(width: 8),
        Expanded(child: StatChip(label: 'Highest', value: info.format(highest, widget.isMetric))),
      ],
    );
  }

  Widget _buildHistoryCard() {
    final entries = _data.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    final shown = entries.take(30).toList();

    return ReportCard(
      title: 'History',
      child: shown.isEmpty
          ? const Text('Nothing logged yet.', style: TextStyle(fontSize: 12.5, color: Colors.grey))
          : Column(
        children: [
          for (int i = 0; i < shown.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(fullDate(shown[i].key),
                      style: const TextStyle(fontSize: 13, color: AppColors.darkText)),
                ),
                Text(_info.format(shown[i].value, widget.isMetric),
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                  onPressed: () => _deleteEntry(shown[i].key),
                ),
              ],
            ),
            if (i != shown.length - 1) Divider(height: 1, color: Colors.grey.shade200),
          ],
        ],
      ),
    );
  }
}

class _EntryResult {
  final DateTime date;
  final double storedValue;
  const _EntryResult(this.date, this.storedValue);
}

class _AddEntrySheet extends StatefulWidget {
  final TrackerInfo info;
  final bool isMetric;

  const _AddEntrySheet({Key? key, required this.info, required this.isMetric}) : super(key: key);

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final TextEditingController _controller = TextEditingController();
  late DateTime _date;
  String? _error;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _date = DateTime(n.year, n.month, n.day);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final n = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(n.year, n.month, n.day),
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _submit() {
    final info = widget.info;
    final raw = _controller.text.trim().replaceAll(',', '.');
    final display = double.tryParse(raw);
    if (display == null) {
      setState(() => _error = 'Please enter a number.');
      return;
    }
    final stored = info.toStored(display, widget.isMetric);
    if (stored < info.minValid || stored > info.maxValid) {
      setState(() => _error =
      'Please enter a value between ${info.format(info.minValid, widget.isMetric)} and ${info.format(info.maxValid, widget.isMetric)}.');
      return;
    }
    Navigator.pop(context, _EntryResult(_date, stored));
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final unit = info.unit(widget.isMetric);

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 16),
            Text(info.accumulate ? 'Add water' : 'Add ${info.title.toLowerCase()}',
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            if (info.accumulate)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text("The amount is added to that day's total.",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.primaryPurple),
                    const SizedBox(width: 10),
                    Text(fullDate(_date),
                        style: const TextStyle(fontSize: 14, color: AppColors.darkText)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: info.accumulate ? 'Amount' : 'Value',
                suffixText: unit,
                errorText: _error,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryPurple, width: 2),
                ),
              ),
            ),
            if (info.accumulate) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [150, 250, 500]
                    .map((v) => ActionChip(
                  label: Text('$v ml'),
                  onPressed: () => setState(() {
                    _controller.text = '$v';
                    _error = null;
                  }),
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submit,
                child: const Text('Save',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
