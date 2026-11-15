import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'social_login_row.dart';
import '../../../core/services/auth_service.dart';
import 'phone_login_screen.dart';

/// Akun yang didaftarkan, disimpan di memori selama aplikasi berjalan,
/// jadi tetap ada setelah LoginScreen ditutup (dibutuhkan agar bisa login ulang setelah logout).
class RegisteredAccount {
  static String? email;
  static String? password;
  static String? name;

  static void clear() {
    email = null;
    password = null;
    name = null;
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;
  bool _loading = false;

  static const Color _bgStart = Color(0xFFEEEBFF);
  static const Color _bgEnd = Color(0xFFF6D8E8);

  static const Color _primaryPurple = Color(0xFF7C3AED);
  static const Color _primaryGradientStart = Color(0xFF8B5CF6);
  static const Color _primaryGradientEnd = Color(0xFF6D28D9);
  static const Color _textDark = Color(0xFF2D1B69);
  static const Color _textSubtle = Color(0xFF6B7280);

  static final RegExp _emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _openRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (result == null || result is! Map) return;

    if (result['password'] != null) {
      // Daftar manual: simpan akun, tetap di halaman Login
      final email = result['email'] as String;
      RegisteredAccount.email = email;
      RegisteredAccount.password = result['password'] as String;
      RegisteredAccount.name = result['name'] as String;

      setState(() {
        _emailController.text = email;
        _passwordController.clear();
        _errorMessage = null;
      });
    } else {
      // Daftar lewat Google/Facebook/Phone: langsung dianggap login
      Navigator.pop(context, result);
    }
  }

  Future<void> _handleLogin() async {
    if (_loading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields!');
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.instance.signInWithEmail(email, password);
      if (!mounted) return;
      Navigator.pop(context, user);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogle() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (user != null) Navigator.pop(context, user); // null = dibatalkan
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handlePhone() async {
    final user = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
    );
    if (user != null && mounted) Navigator.pop(context, user);
  }

  Future<void> _showForgotPasswordDialog() async {
    final controller = TextEditingController(text: _emailController.text.trim());
    String? error;
    bool sending = false;

    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reset password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your email and we will send you a link to reset your password.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter your email', errorText: error),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: sending ? null : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _primaryPurple),
              onPressed: sending
                  ? null
                  : () async {
                final email = controller.text.trim();
                if (!_emailRegex.hasMatch(email)) {
                  setDialogState(() => error = 'Please enter a valid email address');
                  return;
                }
                setDialogState(() {
                  sending = true;
                  error = null;
                });
                try {
                  await AuthService.instance.sendPasswordReset(email);
                  if (dialogContext.mounted) Navigator.pop(dialogContext, true);
                } on AuthException catch (e) {
                  setDialogState(() {
                    sending = false;
                    error = e.message;
                  });
                }
              },
              child: const Text('Send link', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('If that email is registered, a reset link has been sent. Check your inbox and spam folder.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _socialComingSoon(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login is coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgStart, _bgEnd],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B46C1).withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFA78BFA),
                            Color(0xFF7C3AED),
                            Color(0xFF6D28D9),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInputGroup(
                      label: 'Email',
                      child: _buildTextField(
                        controller: _emailController,
                        hintText: 'Enter your email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => _clearError(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputGroup(
                      label: 'Password',
                      child: _buildTextField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        onChanged: (_) => _clearError(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(

                        onTap: _showForgotPasswordDialog,

                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize: 12,
                            color: _primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [_primaryGradientStart, _primaryGradientEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6D28D9).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _loading ? null : _handleLogin,
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('or continue with', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SocialLoginRow(
                      size: 44,
                      onGoogleTap: _handleGoogle,
                      onPhoneTap: _handlePhone,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 12, color: _textSubtle),
                        ),
                        GestureDetector(
                          onTap: _openRegister,
                          child: Row(
                            children: const [
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _primaryPurple,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _primaryPurple),
                            ],
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
    );
  }

  Widget _buildInputGroup({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    ValueChanged<String>? onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          prefixIcon: Icon(icon, color: _primaryPurple, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEEEBFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFEEEBFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _primaryPurple, width: 1.5),
          ),
        ),
      ),
    );
  }
}