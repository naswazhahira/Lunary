import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/painters/dashed_circle_painter.dart';
import '../../../core/theme/app_colors.dart';
import '../../reports/widgets/report_widgets.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themes = context.watch<ThemeController>();

    return ReportScaffold(
      title: 'App settings',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReportCard(
            title: 'Theme',
            subtitle: 'Choose the colors Lunary uses across the whole app',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IntrinsicHeight supaya ketiga kartu selalu sama tinggi
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < AppPalette.all.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: _ThemeCard(
                            palette: AppPalette.all[i],
                            selected: AppPalette.all[i].id == themes.palette.id,
                            onTap: () => themes.select(AppPalette.all[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPreview(),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Your choice is saved on this device.',
              style: TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Contoh penanda kalender dengan warna tema yang sedang aktif.
  Widget _buildPreview() {
    const numberStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _previewItem(
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.period,
              shape: BoxShape.circle,
            ),
            child: const Text('12', style: numberStyle),
          ),
          'Period',
        ),
        _previewItem(
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.predictPeriod,
              shape: BoxShape.circle,
            ),
            child: const Text('19', style: numberStyle),
          ),
          'Predicted',
        ),
        _previewItem(
          SizedBox(
            width: 36,
            height: 36,
            child: CustomPaint(
              painter: DashedCirclePainter(color: AppColors.fertile),
              child: const Center(
                child: Text(
                  '20',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          'Fertile',
        ),
        _previewItem(
          SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.ovulation,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          'Ovulation',
        ),
      ],
    );
  }

  Widget _previewItem(Widget marker, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        marker,
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.darkerSubText),
        ),
      ],
    );
  }
}

/// Kartu pilihan tema: gradien latar + tiga titik warna + nama.
class _ThemeCard extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    Key? key,
    required this.palette,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  Widget _dot(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? palette.primaryPurple : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 64,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: palette.gradient,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dot(palette.primaryPink),
                        const SizedBox(width: 6),
                        _dot(palette.primaryPurple),
                        const SizedBox(width: 6),
                        _dot(palette.ovulation),
                      ],
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: palette.primaryPurple,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              palette.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              palette.subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.darkerSubText,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}