import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _verificationId;
  int? _resendToken;
  String _phone = '';
  bool _loading = false;
  String? _error;

  bool get _codeStep => _verificationId != null;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// 0812-3456-7890 / 812... / 62812... -> +62812...
  String? _toE164(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('62')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length < 8 || digits.length > 13) return null;
    return '+62$digits';
  }

  Future<void> _sendCode({bool resend = false}) async {
    if (_loading) return;
    final phone = resend ? _phone : _toE164(_phoneController.text);
    if (phone == null) {
      setState(() => _error = 'Enter a valid phone number');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    await AuthService.instance.startPhoneVerification(
      phoneNumber: phone,
      forceResendingToken: resend ? _resendToken : null,
      onCodeSent: (id, token) {
        if (!mounted) return;
        setState(() {
          _verificationId = id;
          _resendToken = token;
          _phone = phone;
          _loading = false;
          if (resend) _codeController.clear();
        });
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() {
          _error = msg;
          _loading = false;
        });
      },
    );
  }

  Future<void> _verify() async {
    if (_loading) return;
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await AuthService.instance.confirmPhoneCode(_verificationId!, code);
      if (!mounted) return;
      Navigator.pop(context, user);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _changeNumber() {
    setState(() {
      _verificationId = null;
      _codeController.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2E2A4A),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _codeStep ? 'Enter the code' : 'Log in with phone',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2A4A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _codeStep
                    ? 'We sent a 6-digit code to $_phone'
                    : 'We will send a verification code by SMS.',
                style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 24),

              if (!_codeStep)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-]'))],
                  decoration: _decoration(hint: '812 3456 7890', prefix: '+62  '),
                )
              else
                TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 22, letterSpacing: 8),
                  decoration: _decoration(hint: '------').copyWith(counterText: ''),
                ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _loading ? null : (_codeStep ? _verify : _sendCode),
                  child: _loading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(
                    _codeStep ? 'Verify' : 'Send code',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              if (_codeStep) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _loading ? null : _changeNumber,
                      child: const Text('Change number'),
                    ),
                    TextButton(
                      onPressed: _loading ? null : () => _sendCode(resend: true),
                      child: const Text('Resend code'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({required String hint, String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}