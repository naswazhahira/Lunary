import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Simpan data akun yang terdaftar sementara di memori
  String? _registeredEmail;
  String? _registeredPassword;
  String? _registeredName;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleAuth() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    bool isValid = true;

    // 1. Validasi Email wajib menggunakan @gmail.com
    if (email.isEmpty || !email.endsWith('@gmail.com')) {
      _emailError = 'Email harus menggunakan @gmail.com';
      isValid = false;
    }

    if (isSignUp) {
      // Validasi Sign Up
      if (password.length < 6) {
        _passwordError = 'Password minimal 6 karakter';
        isValid = false;
      }
      if (confirmPassword != password) {
        _confirmPasswordError = 'Konfirmasi password tidak cocok';
        isValid = false;
      }

      if (!isValid) return;

      // Simpan data pendaftaran
      _registeredEmail = email;
      _registeredPassword = password;
      _registeredName = _nameController.text.isNotEmpty ? _nameController.text : 'Pengguna Lunary';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun berhasil dibuat! Silakan login dengan password yang dibuat.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Pindah ke halaman Log In dan kosongkan field password
      setState(() {
        isSignUp = false;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } else {
      // Validasi Log In
      if (password.isEmpty) {
        _passwordError = 'Masukkan password Anda';
        isValid = false;
      }

      if (!isValid) return;

      // Cek apakah akun sudah pernah didaftarkan
      if (_registeredEmail == null) {
        _emailError = 'Akun belum terdaftar. Silakan Sign Up terlebih dahulu';
        setState(() {});
        return;
      }

      // Cek kesesuaian Email dan Password
      if (email != _registeredEmail) {
        _emailError = 'Email tidak terdaftar';
        setState(() {});
        return;
      }

      if (password != _registeredPassword) {
        _passwordError = 'Password tidak sesuai';
        setState(() {});
        return;
      }

      // Login berhasil jika email dan password cocok
      Navigator.pop(context, {
        'name': _registeredName ?? 'Pengguna Lunary',
        'email': _registeredEmail,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                elevation: 10,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Avatar Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryPurple,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSignUp ? 'Sign Up' : 'Login',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (isSignUp) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nama Lengkap',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 16),
                      ],

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        errorText: _emailError,
                        trailingWidget: !isSignUp
                            ? GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lupa password ditekan'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        isObscure: true,
                        errorText: _passwordError,
                      ),

                      if (isSignUp) ...[
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Konfirmasi Password',
                          icon: Icons.lock_outline_rounded,
                          isObscure: true,
                          errorText: _confirmPasswordError,
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Main Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _handleAuth,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isSignUp ? 'Sign Up' : 'Log In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Social Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Social Login Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            color: Colors.redAccent,
                            text: 'G',
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            color: Colors.blue.shade800,
                            text: 'f',
                            onTap: () {},
                          ),
                          const SizedBox(width: 16),
                          _buildSocialButton(
                            color: Colors.green,
                            icon: Icons.phone_android_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Switch Login / Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSignUp ? 'Already registered? ' : 'Not registered yet? ',
                            style: const TextStyle(fontSize: 13, color: AppColors.darkerSubText),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSignUp = !isSignUp;
                                _emailError = null;
                                _passwordError = null;
                                _confirmPasswordError = null;
                              });
                            },
                            child: Text(
                              isSignUp ? 'Log In >' : 'Sign Up >',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    String? errorText,
    Widget? trailingWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: const TextStyle(fontSize: 14, color: AppColors.darkText),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 20),
            filled: true,
            fillColor: const Color(0xFFF9F9FB),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : AppColors.primaryPurple,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 12, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text(
                errorText,
                style: const TextStyle(fontSize: 11, color: Colors.redAccent),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSocialButton({
    required Color color,
    String? text,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.white,
        ),
        child: Center(
          child: text != null
              ? Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          )
              : Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}
