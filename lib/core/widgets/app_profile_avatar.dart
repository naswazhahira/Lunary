import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppProfileAvatar extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const AppProfileAvatar({Key? key, this.size = 45, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFB197FC),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
