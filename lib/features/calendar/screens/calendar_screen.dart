import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../core/navigation/app_navigation.dart';
import '../models/calendar_day.dart';
import '../widgets/calendar_month_card.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/cycle_status_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime(2026, 9);

  void _goToPrevMonth() {
    setState(() => _month = DateTime(_month.year, _month.month - 1));
  }

  void _goToNextMonth() {
    setState(() => _month = DateTime(_month.year, _month.month + 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.homeBackgroundGradient,
        ),
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
                      _buildHeader(),
                      const SizedBox(height: 16),
                      CalendarMonthCard(
                        month: _month,
                        days: mockCalendarDaysFor(_month),
                        onPrevMonth: _goToPrevMonth,
                        onNextMonth: _goToNextMonth,
                      ),
                      const SizedBox(height: 16),
                      const CalendarLegend(),
                      const SizedBox(height: 20),
                      CycleStatusCard(
                        stats: const [
                          CycleStatusStat(
                            value: 'Day 9',
                            label: 'Follicular',
                            icon: Icons.egg_outlined,
                          ),
                          CycleStatusStat(
                            value: '19',
                            label: 'days to next',
                            icon: Icons.calendar_month_outlined,
                          ),
                          CycleStatusStat(
                            value: '5',
                            label: 'days to ovulation',
                            icon: Icons.egg,
                          ),
                        ],
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AppColors.primaryPink,
                  AppColors.primaryPurple,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: const Text(
                'Period Tracker',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Understand your cycle',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkerSubText,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFB197FC),
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB197FC).withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
