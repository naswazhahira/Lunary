import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
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
    );
  }
}
