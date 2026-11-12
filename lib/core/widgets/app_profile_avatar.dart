import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppProfileAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const AppProfileAvatar({
    Key? key,
    this.size = 44,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Supaya avatar digambar ulang saat tema berganti
    context.watchTheme();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.avatar,
          border: Border.all(
            color: Colors.white,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.avatar.withOpacity(0.35),
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
    );
  }
}
