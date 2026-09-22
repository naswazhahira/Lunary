import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CycleStatusStat {
  final String value;
  final String label;
  final IconData icon;

  const CycleStatusStat({
    required this.value,
    required this.label,
    required this.icon,
  });
}

class CycleStatusCard extends StatelessWidget {
  final List<CycleStatusStat> stats;

  const CycleStatusCard({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Cycle Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.primaryPurple,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            // Menyejajarkan posisi atas lingkaran secara presisi
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.map((stat) => _buildStatItem(stat)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(CycleStatusStat stat) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lingkaran ikon dengan ukuran fixed
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.cycleStatusCircle,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                stat.icon,
                color: AppColors.darkText,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Nilai / Value Utama
          Text(
            stat.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 4),
          // Label deskripsi (dikecilkan & otomatis ke bawah jika panjang)
          Text(
            stat.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            softWrap: true,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.darkerSubText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
