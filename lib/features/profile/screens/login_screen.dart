import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showEmailLoginForm = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State untuk menyimpan pesan error
  String? _errorMessage;

  Map<String, String>? _registeredAccount;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        _registeredAccount = result;
        _emailController.text = result['email'] ?? '';
        _passwordController.clear();
        _errorMessage = null; // Reset error saat berpindah dari register
        _showEmailLoginForm = true;
      });

      _showSnackBar('Akun berhasil dibuat! Silakan ketik ulang password Anda untuk masuk.');
    }
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
              _buildHeader(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _showEmailLoginForm ? _buildEmailLoginForm() : _buildLoginOptions(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
            onPressed: () {
              if (_showEmailLoginForm) {
                setState(() {
                  _showEmailLoginForm = false;
                  _errorMessage = null;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Text(
              _showEmailLoginForm ? 'Masuk dengan Email' : 'Masuk / Daftar Akun',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLoginOptions() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: AppColors.primaryPurple),
          const SizedBox(height: 16),
          const Text(
            'Pilih Metode Masuk',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih metode yang kamu inginkan untuk mengakses akun milikmu.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.darkerSubText),
          ),
          const SizedBox(height: 32),

          _buildSocialButton(
            icon: Icons.email_outlined,
            text: 'Lanjutkan dengan Email',
            color: AppColors.primaryPurple,
            textColor: Colors.white,
            onTap: () => setState(() => _showEmailLoginForm = true),
          ),
          const SizedBox(height: 12),

          _buildSocialButton(
            icon: Icons.g_mobiledata_rounded,
            text: 'Lanjutkan dengan Google',
            color: Colors.white,
            textColor: AppColors.darkText,
            borderColor: Colors.grey.shade300,
            onTap: () {
              Navigator.pop(context, {
                'name': 'User Google',
                'email': 'user.google@gmail.com',
              });
            },
          ),
          const SizedBox(height: 12),

          _buildSocialButton(
            icon: Icons.phone_android_rounded,
            text: 'Lanjutkan dengan No. HP',
            color: Colors.white,
            textColor: AppColors.darkText,
            borderColor: Colors.grey.shade300,
            onTap: () => _showSnackBar('Fitur masuk dengan No. HP belum tersedia.'),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun? ', style: TextStyle(color: AppColors.darkerSubText, fontSize: 13)),
              GestureDetector(
                onTap: _navigateToRegister,
                child: const Text('Daftar Akun', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selamat Datang Kembali!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkText)),
          const SizedBox(height: 6),
          const Text('Masukkan email dan kata sandi akun Anda.', style: TextStyle(fontSize: 13, color: AppColors.darkerSubText)),
          const SizedBox(height: 28),

          _buildInputField(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Password',
            controller: _passwordController,
            icon: Icons.lock_outline,
            isPassword: true,
            hasError: _errorMessage != null,
            onChanged: (_) {
              if (_errorMessage != null) setState(() => _errorMessage = null);
            },
          ),

          // Peringatan Merah Jika Password / Email Salah
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                const SizedBox(width: 6),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                if (email.isEmpty || password.isEmpty) {
                  setState(() {
                    _errorMessage = 'Email dan password tidak boleh kosong';
                  });
                  return;
                }

                // Cek jika terdaftar lewat pendaftaran baru
                if (_registeredAccount != null) {
                  if (email == _registeredAccount!['email']) {
                    if (password == _registeredAccount!['password']) {
                      setState(() => _errorMessage = null);
                      Navigator.pop(context, {
                        'name': _registeredAccount!['name']!,
                        'email': _registeredAccount!['email']!,
                      });
                    } else {
                      // Jika password salah
                      setState(() {
                        _errorMessage = 'password yang anda masukkan salah';
                      });
                    }
                  } else {
                    setState(() {
                      _errorMessage = 'Email belum terdaftar';
                    });
                  }
                }
                // Cek akun demo default
                else if (email == 'user@lunary.com') {
                  if (password == '123456') {
                    setState(() => _errorMessage = null);
                    Navigator.pop(context, {
                      'name': 'Awa',
                      'email': 'user@lunary.com',
                    });
                  } else {
                    setState(() {
                      _errorMessage = 'password yang anda masukkan salah';
                    });
                  }
                } else {
                  setState(() {
                    _errorMessage = 'Email belum terdaftar';
                  });
                }
              },
              child: const Text('Masuk', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Belum punya akun? ', style: TextStyle(color: AppColors.darkerSubText, fontSize: 13)),
              GestureDetector(
                onTap: _navigateToRegister,
                child: const Text('Daftar Sekarang', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10),
            Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool hasError = false,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: hasError ? Colors.redAccent : AppColors.primaryPurple),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? Colors.redAccent : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? Colors.redAccent : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? Colors.redAccent : AppColors.primaryPurple, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}