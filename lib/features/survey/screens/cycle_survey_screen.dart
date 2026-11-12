import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/cycle_provider.dart';
import '../../../core/services/cycle_settings.dart';

const List<String> _monthLong = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
  'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
];

const List<String> _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fullDate(DateTime d) => '${d.day} ${_monthShort[d.month - 1]} ${d.year}';

// -----------------------------------------------------------------------------
// Data pertanyaan angka (lama haid & panjang siklus)
// -----------------------------------------------------------------------------

class _Category {
  final String label;
  final String rangeText;
  final int min;
  final int max;
  final int representative; // nilai yang dipilih saat kartu diketuk

  const _Category({
    required this.label,
    required this.rangeText,
    required this.min,
    required this.max,
    required this.representative,
  });

  bool contains(int v) => v >= min && v <= max;
}

class _NumberQuestion {
  final IconData icon;
  final String title;
  final String subtitle;
  final String tip;
  final int min;
  final int max;
  final int defaultValue;
  final List<_Category> categories;

  /// Peringatan lembut kalau nilai di luar rentang umum (null = tidak dipakai).
  final int? warnBelow; // nilai < warnBelow
  final int? warnAbove; // nilai > warnAbove
  final String warnText;

  const _NumberQuestion({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tip,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.categories,
    this.warnBelow,
    this.warnAbove,
    this.warnText = '',
  });

  bool needsWarning(int v) {
    if (warnBelow != null && v < warnBelow!) return true;
    if (warnAbove != null && v > warnAbove!) return true;
    return false;
  }
}

const _NumberQuestion _periodQuestion = _NumberQuestion(
  icon: Icons.water_drop_outlined,
  title: 'How long does your period usually last?',
  subtitle: 'Pick the option closest to you, then fine-tune the number below.',
  tip: 'Most periods last between 3 and 7 days. A bit shorter or longer is okay too.',
  min: 1,
  max: 12,
  defaultValue: 5,
  categories: [
    _Category(label: 'Shorter', rangeText: '1–3 days', min: 1, max: 3, representative: 3),
    _Category(label: 'Typical', rangeText: '4–7 days', min: 4, max: 7, representative: 5),
    _Category(label: 'Longer', rangeText: '8+ days', min: 8, max: 12, representative: 9),
  ],
  warnAbove: 8,
  warnText: 'Bleeding for more than 8 days is worth mentioning to a doctor.',
);

const _NumberQuestion _cycleQuestion = _NumberQuestion(
  icon: Icons.autorenew_rounded,
  title: 'How long is your menstrual cycle?',
  subtitle: 'Count from the first day of one period to the first day of the next.',
  tip: 'A typical cycle is 25 to 35 days. Not sure? Tap "I\'m not sure" and Lunary will learn from your logs.',
  min: 20,
  max: 60,
  defaultValue: 28,
  categories: [
    _Category(label: 'Shorter', rangeText: '20–24 days', min: 20, max: 24, representative: 23),
    _Category(label: 'Typical', rangeText: '25–35 days', min: 25, max: 35, representative: 28),
    _Category(label: 'Longer', rangeText: '36+ days', min: 36, max: 60, representative: 38),
  ],
  warnBelow: 21,
  warnAbove: 35,
  warnText:
  'Cycles shorter than 21 or longer than 35 days can still be normal for you, but mention it to a doctor if it keeps happening.',
);

// -----------------------------------------------------------------------------
// Layar survei
// -----------------------------------------------------------------------------

class CycleSurveyScreen extends StatefulWidget {
  /// Dipanggil setelah survei selesai (diisi atau dilewati).
  /// Kalau null, layar ini cukup di-pop (dipakai alur login).
  final VoidCallback? onFinished;

  const CycleSurveyScreen({super.key, this.onFinished});

  @override
  State<CycleSurveyScreen> createState() => _CycleSurveyScreenState();
}

class _CycleSurveyScreenState extends State<CycleSurveyScreen> {
  static const int _totalSteps = 3;

  final PageController _pageController = PageController();
  int _step = 0;
  bool _finishing = false;

  // null = belum dijawab / "I don't remember" / "I'm not sure"
  DateTime? _lastPeriod;
  int? _periodLen;
  int? _cycleLen;
  bool _irregular = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _step == _totalSteps - 1;

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _lastPeriod != null;
      case 1:
        return _periodLen != null;
      default:
        return _cycleLen != null;
    }
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  void _next() {
    if (!_canContinue) return;
    if (_isLast) {
      _irregular = false;
      _finish(saveAnswers: true);
    } else {
      _goTo(_step + 1);
    }
  }

  /// "I don't remember" (layar 1) atau "I'm not sure" (layar 2 dan 3).
  void _skipQuestion() {
    switch (_step) {
      case 0:
        _lastPeriod = null;
        break;
      case 1:
        _periodLen = null;
        break;
      default:
        _cycleLen = null;
        _irregular = false;
    }
    if (_isLast) {
      _finish(saveAnswers: true);
    } else {
      _goTo(_step + 1);
    }
  }

  void _markIrregular() {
    _cycleLen = null;
    _irregular = true;
    _finish(saveAnswers: true);
  }

  /// [saveAnswers] false = Skip: tidak ada yang disimpan.
  Future<void> _finish({required bool saveAnswers}) async {
    if (_finishing) return;
    _finishing = true;

    // Ambil provider sebelum ada await
    final provider = context.read<CycleProvider>();

    if (saveAnswers) {
      CycleSettings.periodLength = _periodLen;
      CycleSettings.cycleLength = _cycleLen;
      CycleSettings.irregularCycle = _irregular;
      await CycleSettings.save();

      // Setelah lama haid tersimpan, catat haid terakhir
      if (_lastPeriod != null) {
        provider.setInitialPeriod(_lastPeriod!);
      }
    }
    await CycleSettings.markSurveyDone();
    provider.onSettingsChanged();

    if (!mounted) return;

    if (widget.onFinished != null) {
      widget.onFinished!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _totalSteps,
                    itemBuilder: (context, i) {
                      switch (i) {
                        case 0:
                          return _DatePage(
                            key: const ValueKey('page_date'),
                            selected: _lastPeriod,
                            onSelected: (d) => setState(() => _lastPeriod = d),
                          );
                        case 1:
                          return _NumberPage(
                            key: const ValueKey('page_period'),
                            question: _periodQuestion,
                            initialValue: _periodLen,
                            onChanged: (v) => setState(() => _periodLen = v),
                          );
                        default:
                          return _NumberPage(
                            key: const ValueKey('page_cycle'),
                            question: _cycleQuestion,
                            initialValue: _cycleLen,
                            onChanged: (v) => setState(() => _cycleLen = v),
                          );
                      }
                    },
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: _step > 0
                ? IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.darkText),
            )
                : null,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: (_step + 1) / _totalSteps),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => _finish(saveAnswers: false),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final List<Widget> secondary;
    if (_step == 0) {
      secondary = [_secondaryButton("I don't remember", _skipQuestion)];
    } else if (_step == 1) {
      secondary = [_secondaryButton("I'm not sure", _skipQuestion)];
    } else {
      secondary = [
        _secondaryButton('My cycle is irregular', _markIrregular),
        _secondaryButton("I'm not sure", _skipQuestion),
      ];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                disabledBackgroundColor: AppColors.primaryPurple.withValues(alpha: 0.35),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: _canContinue ? _next : null,
              child: Text(
                _isLast ? 'Finish' : 'Continue',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: secondary,
          ),
        ],
      ),
    );
  }

  Widget _secondaryButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkerSubText,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Layar 1: kapan haid terakhir dimulai
// -----------------------------------------------------------------------------

class _DatePage extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  const _DatePage({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_rounded, color: AppColors.primaryPurple, size: 32),
          ),
          const SizedBox(height: 18),
          const Text(
            'When did your last period start?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the first day of your most recent period.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.5),
          ),
          const SizedBox(height: 20),
          _PeriodDatePicker(selected: selected, onSelected: onSelected),
          const SizedBox(height: 14),
          Text(
            selected == null ? 'No date selected yet' : 'Selected: ${_fullDate(selected!)}',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: selected == null ? AppColors.subText : AppColors.primaryPink,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryPurple),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'A rough date is fine. You can correct it anytime in the Calendar tab.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.darkerSubText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodDatePicker extends StatefulWidget {
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  const _PeriodDatePicker({super.key, required this.selected, required this.onSelected});

  @override
  State<_PeriodDatePicker> createState() => _PeriodDatePickerState();
}

class _PeriodDatePickerState extends State<_PeriodDatePicker> {
  static const _weekdayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  late final DateTime _today;
  late final DateTime _earliest;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _today = DateTime(n.year, n.month, n.day);
    _earliest = DateTime(n.year, n.month, n.day - 180);
    final s = widget.selected ?? _today;
    _month = DateTime(s.year, s.month);
  }

  bool get _canGoPrev => _month.isAfter(DateTime(_earliest.year, _earliest.month));
  bool get _canGoNext => _month.isBefore(DateTime(_today.year, _today.month));

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    final cells = <int?>[
      ...List<int?>.filled(firstWeekday, null),
      for (int d = 1; d <= daysInMonth; d++) d,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(
        Row(
          children: cells.sublist(i, i + 7).map(_buildCell).toList(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _canGoPrev ? () => _changeMonth(-1) : null,
                icon: const Icon(Icons.chevron_left),
                color: AppColors.primaryPurple,
              ),
              Text(
                '${_monthLong[_month.month - 1]} ${_month.year}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                onPressed: _canGoNext ? () => _changeMonth(1) : null,
                icon: const Icon(Icons.chevron_right),
                color: AppColors.primaryPurple,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: _weekdayLabels
                .map((l) => Expanded(
              child: Center(
                child: Text(
                  l,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildCell(int? day) {
    return Expanded(
      child: SizedBox(
        height: 42,
        child: day == null ? null : Center(child: _buildDay(day)),
      ),
    );
  }

  Widget _buildDay(int day) {
    final date = DateTime(_month.year, _month.month, day);
    final enabled = !date.isAfter(_today) && !date.isBefore(_earliest);
    final isSelected = widget.selected != null && widget.selected == date;
    final isToday = date == _today;

    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (!enabled) {
      textColor = AppColors.subText.withValues(alpha: 0.45);
    } else {
      textColor = AppColors.darkText;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled
          ? () {
        HapticFeedback.selectionClick();
        widget.onSelected(date);
      }
          : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.primaryPink : Colors.transparent,
          border: (isToday && !isSelected)
              ? Border.all(color: AppColors.primaryPurple, width: 2)
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Layar 2 dan 3: kartu Shorter / Typical / Longer + roda angka
// -----------------------------------------------------------------------------

class _NumberPage extends StatefulWidget {
  final _NumberQuestion question;

  /// Jawaban sebelumnya (null = belum dijawab).
  final int? initialValue;
  final ValueChanged<int> onChanged;

  const _NumberPage({
    super.key,
    required this.question,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<_NumberPage> {
  late int _value;
  late bool _touched;
  late final FixedExtentScrollController _wheel;

  _NumberQuestion get _q => widget.question;

  @override
  void initState() {
    super.initState();
    _touched = widget.initialValue != null;
    _value = (widget.initialValue ?? _q.defaultValue).clamp(_q.min, _q.max).toInt();
    _wheel = FixedExtentScrollController(initialItem: _value - _q.min);
  }

  @override
  void dispose() {
    _wheel.dispose();
    super.dispose();
  }

  void _pickCategory(_Category c) {
    HapticFeedback.selectionClick();
    setState(() {
      _value = c.representative;
      _touched = true;
    });
    widget.onChanged(c.representative);
    _wheel.animateToItem(
      c.representative - _q.min,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _onWheelChanged(int index) {
    final v = _q.min + index;
    if (v == _value && _touched) return;
    HapticFeedback.selectionClick();
    setState(() {
      _value = v;
      _touched = true;
    });
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_q.icon, color: AppColors.primaryPurple, size: 32),
          ),
          const SizedBox(height: 18),
          Text(
            _q.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _q.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkerSubText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              for (int i = 0; i < _q.categories.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _buildCategoryCard(_q.categories[i])),
              ],
            ],
          ),
          const SizedBox(height: 18),
          _buildWheel(),
          const SizedBox(height: 14),
          if (_touched && _q.needsWarning(_value)) ...[
            _buildWarning(),
            const SizedBox(height: 10),
          ],
          _buildTip(),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_Category c) {
    final selected = _touched && c.contains(_value);

    return GestureDetector(
      onTap: () => _pickCategory(c),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryPurple.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryPurple : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              c.label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: selected ? AppColors.primaryPurple : AppColors.darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              c.rangeText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: AppColors.darkerSubText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel() {
    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sorotan di tengah roda
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryPurple.withValues(alpha: _touched ? 0.6 : 0.25),
                width: 1.5,
              ),
            ),
          ),
          ListWheelScrollView.useDelegate(
            controller: _wheel,
            itemExtent: 52,
            diameterRatio: 1.8,
            perspective: 0.003,
            overAndUnderCenterOpacity: 0.35,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: _onWheelChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: _q.max - _q.min + 1,
              builder: (context, index) {
                final n = _q.min + index;
                final selected = n == _value;
                return Center(
                  child: Text(
                    '$n ${n == 1 ? 'day' : 'days'}',
                    style: TextStyle(
                      fontSize: selected ? 24 : 20,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      color: selected ? AppColors.primaryPurple : AppColors.darkText,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFF0A868)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _q.warnText,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.darkerSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primaryPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _q.tip,
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: AppColors.darkerSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
