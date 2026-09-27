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
  final VoidCallback? onSeeMore;

  const CycleStatusCard({
    Key? key,
    required this.stats,
    this.onSeeMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stats.map((stat) => Expanded(child: _buildStatItem(stat))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Cycle Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryPurple,
          ),
        ),
        if (onSeeMore != null)
          GestureDetector(
            onTap: onSeeMore,
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primaryPurple,
              size: 22,
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(CycleStatusStat stat) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stat.icon,
              color: AppColors.primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(height: 10),
          // Nilai Angka / Status Utama
          Text(
            stat.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 4),
          // Label Penjelas (Bisa terlipat ke bawah jika panjang)
          Text(
            stat.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: AppColors.darkerSubText,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
