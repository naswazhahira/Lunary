import 'package:flutter/material.dart';

class SocialLoginRow extends StatelessWidget {
  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onPhoneTap;
  final double size;

  const SocialLoginRow({
    Key? key,
    this.onGoogleTap,
    this.onFacebookTap,
    this.onPhoneTap,
    this.size = 46,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circle(child: const _GoogleLogo(), onTap: onGoogleTap),
        const SizedBox(width: 16),
        _circle(child: const _FacebookLogo(), onTap: onFacebookTap),
        const SizedBox(width: 16),
        _circle(child: const _PhoneLogo(), onTap: onPhoneTap),
      ],
    );
  }

  Widget _circle({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF0EBF8), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B46C1).withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

/// Logo Google "G" 4 warna (tanpa gambar / internet)
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const SweepGradient(
        colors: [
          Color(0xFF4285F4), // biru
          Color(0xFF4285F4),
          Color(0xFF34A853), // hijau
          Color(0xFF34A853),
          Color(0xFFFBBC05), // kuning
          Color(0xFFFBBC05),
          Color(0xFFEA4335), // merah
          Color(0xFFEA4335),
        ],
        stops: [0.0, 0.25, 0.25, 0.5, 0.5, 0.75, 0.75, 1.0],
      ).createShader(bounds),
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Logo Facebook (lingkaran biru + huruf "f")
class _FacebookLogo extends StatelessWidget {
  const _FacebookLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1877F2),
      ),
      alignment: Alignment.bottomCenter,
      child: const Padding(
        padding: EdgeInsets.only(left: 2),
        child: Text(
          'f',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Logo Nomor HP (lingkaran hijau + ikon telepon)
class _PhoneLogo extends StatelessWidget {
  const _PhoneLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF10B981),
      ),
      child: const Icon(Icons.phone, color: Colors.white, size: 16),
    );
  }
}