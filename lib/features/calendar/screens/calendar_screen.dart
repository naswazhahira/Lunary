import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/widgets/app_profile_avatar.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/providers/cycle_provider.dart';
import '../widgets/calendar_month_card.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/cycle_status_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 20),
                      CalendarMonthCard(
                        month: cycle.selectedMonth,
                        days: cycle.currentMonthDays,
                        selectedDate: cycle.selectedDate,
                        onPrevMonth: cycle.goToPrevMonth,
                        onNextMonth: cycle.goToNextMonth,
                        onDaySelected: cycle.selectDate,
                      ),
                      const SizedBox(height: 16),
                      _buildTrackPeriodCard(context, cycle),
                      const SizedBox(height: 20),
                      const CalendarLegend(),
                      const SizedBox(height: 20),
                      CycleStatusCard(
                        stats: [
                          CycleStatusStat(
                            value: 'Day ${cycle.currentCycleDay}',
                            label: cycle.currentPhaseLabel,
                            icon: Icons.egg_outlined,
                          ),
                          CycleStatusStat(
                            value: cycle.daysUntilNextPeriod?.toString() ?? '-',
                            label: 'days to next period',
                            icon: Icons.calendar_month_outlined,
                          ),
                          CycleStatusStat(
                            value: cycle.daysUntilOvulation?.toString() ?? '-',
                            label: 'days to ovulation',
                            icon: Icons.egg,
                          ),
                        ],
                        onSeeMore: () => context.push(RoutePaths.cycleDetail),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              AppBottomNavBar(
                currentTab: AppNavTab.calendar,
                onTabSelected: (tab) => handleAppNavTap(context, tab),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.primaryPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  'Period Tracker',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Understand your cycle',
                style: TextStyle(fontSize: 13, color: AppColors.darkerSubText),
              ),
            ],
          ),
        ),
        // Cukup panggil reusable widget AppProfileAvatar di sini
        AppProfileAvatar(
          onTap: () => handleAppNavTap(context, AppNavTab.profile),
        ),
      ],
    );
  }

  Widget _buildTrackPeriodCard(BuildContext context, CycleProvider cycle) {
    final isPeriod = cycle.isSelectedDatePeriod;
    final canTrack = cycle.canTrackSelectedDate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPeriod ? AppColors.period : AppColors.primaryPurple).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPeriod ? Icons.water_drop_rounded : Icons.water_drop_outlined,
              color: isPeriod ? AppColors.period : AppColors.primaryPurple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatDate(cycle.selectedDate),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  !canTrack
                      ? "Can't log a future date"
                      : (isPeriod ? 'Marked as period' : 'Toggle period status'),
                  style: const TextStyle(fontSize: 11, color: AppColors.darkerSubText),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canTrack)
            InkWell(
              onTap: cycle.togglePeriodForSelectedDate,
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isPeriod ? AppColors.period.withOpacity(0.12) : AppColors.primaryPink,
                  borderRadius: BorderRadius.circular(20),
                  border: isPeriod
                      ? Border.all(color: AppColors.period, width: 1.2)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPeriod ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                      size: 15,
                      color: isPeriod ? AppColors.period : Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPeriod ? 'Period (On)' : 'Log Period',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                        color: isPeriod ? AppColors.period : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
