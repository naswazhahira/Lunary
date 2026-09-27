import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppNotificationButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const AppNotificationButton({Key? key, required this.onTap, this.size = 42}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(Icons.notifications_none_rounded, color: AppColors.darkText, size: size * 0.5),
      ),
    );
  }
}