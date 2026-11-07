import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/cycle_settings.dart';

class CycleSurveyScreen extends StatefulWidget {
  const CycleSurveyScreen({Key? key}) : super(key: key);

  @override
  State<CycleSurveyScreen> createState() => _CycleSurveyScreenState();
}

class _CycleSurveyScreenState extends State<CycleSurveyScreen> {
  int? _cycleLength = CycleSettings.cycleLength;
  int? _periodLength = CycleSettings.periodLength;
  int? _lutealPhase = CycleSettings.lutealPhase;

  /// [saveAnswers] false = Skip: tidak ada yang disimpan, kolom di Profile tetap kosong.
  Future<void> _finish({required bool saveAnswers}) async {
    if (saveAnswers) {
      CycleSettings.cycleLength = _cycleLength;
      CycleSettings.periodLength = _periodLength;
      CycleSettings.lutealPhase = _lutealPhase;
      await CycleSettings.save();
    }
    await CycleSettings.markSurveyDone();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _finish(saveAnswers: false);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _finish(saveAnswers: false),
                    child: const Text('Skip',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPurple.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.water_drop_outlined,
                                color: AppColors.primaryPurple, size: 36),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text('Tell us about your cycle',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkText)),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'This is optional and helps Lunary predict more accurately. '
                                'You can change it anytime in Profile > Cycle and ovulation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.darkerSubText, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildQuestion(
                                title: 'How long is your cycle?',
                                hint: 'Days from the first day of one period to the first day of the next.',
                                value: _cycleLength,
                                min: 20,
                                max: 100,
                                onChanged: (v) => setState(() => _cycleLength = v),
                              ),
                              const SizedBox(height: 20),
                              _buildQuestion(
                                title: 'How long does your period last?',
                                hint:
                                'Shorter periods, such as 3 to 4 days, are common. Just pick what is usual for you.',
                                value: _periodLength,
                                min: 1,
                                max: 12,
                                onChanged: (v) => setState(() => _periodLength = v),
                              ),
                              const SizedBox(height: 20),
                              _buildQuestion(
                                title: 'How long is your luteal phase?',
                                hint:
                                'The time between ovulation and your next period. Skip if you do not know.',
                                value: _lutealPhase,
                                min: 8,
                                max: 17,
                                onChanged: (v) => setState(() => _lutealPhase = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => _finish(saveAnswers: true),
                      child: const Text('Continue',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion({
    required String title,
    required String hint,
    required int? value,
    required int min,
    required int max,
    required ValueChanged<int?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        const SizedBox(height: 4),
        Text(hint, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              menuMaxHeight: 300,
              hint: Text('Select (optional)',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Not sure', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ),
                ...List.generate(max - min + 1, (i) {
                  final n = min + i;
                  return DropdownMenuItem<int>(
                    value: n,
                    child: Text('$n days',
                        style: const TextStyle(fontSize: 14, color: AppColors.darkText)),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}