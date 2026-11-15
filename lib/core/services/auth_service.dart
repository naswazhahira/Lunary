import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Error yang sudah diterjemahkan jadi pesan yang siap ditampilkan ke user.
class AuthException implements Exception {
  final String message;

  /// true kalau butuh password untuk konfirmasi ulang (mis. saat hapus akun).
  final bool needsPassword;

  AuthException(this.message, {this.needsPassword = false});

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Web client ID dari Firebase (client_type 3 di google-services.json)
  static const String _webClientId =
      '1027377779097-sv3b1ruv4f1lnouhj31lv944b52468bp.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _googleInitialized = false;

  User? get currentUser => _auth.currentUser;

  /// Pulihkan sesi login yang tersimpan (dipakai saat aplikasi dibuka).
  /// Return {'name','email'} kalau masih login, null kalau tidak.
  Future<Map<String, String>?> restoreSession() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      // Pastikan akunnya masih valid (belum dihapus/dinonaktifkan)
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'user-disabled' ||
          e.code == 'user-token-expired') {
        await signOut();
        return null;
      }
      // Error lain (mis. sedang offline): tetap dianggap login
    }

    final fresh = _auth.currentUser;
    if (fresh == null) return null;
    return _toMap(fresh);
  }

  Future<void> updateDisplayName(String name) async {
    try {
      await _auth.currentUser?.updateDisplayName(name);
    } catch (_) {}
  }

  /// Format yang sama dengan yang dipakai layar lain: {'name', 'email'}
  /// Akun nomor HP tidak punya email, jadi nomor HP dipakai sebagai pengenal akun.
  Map<String, String> _toMap(User user) {
    final phone = user.phoneNumber ?? '';
    final email = (user.email != null && user.email!.isNotEmpty) ? user.email! : phone;
    final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
        ? user.displayName!
        : (email.contains('@') ? email.split('@').first : 'Lunary User');
    return {'name': name, 'email': email};
  }

  // ---------------- Email & password ----------------

  Future<Map<String, String>> registerWithEmail(
      String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      await cred.user!.reload();
      return _toMap(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  Future<Map<String, String>> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toMap(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  // ---------------- Lupa password ----------------

  /// Kirim email reset password. Kalau email tidak terdaftar, sengaja
  /// diperlakukan sukses supaya orang lain tidak bisa mengecek email mana
  /// yang terdaftar.
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return;
      throw AuthException(_message(e));
    }
  }

  // ---------------- Google ----------------

  /// Dialog pilih akun Google. Return null kalau user membatalkan.
  Future<AuthCredential?> _googleCredential() async {
    try {
      final gsi = GoogleSignIn.instance;

      // google_sign_in v7: initialize() wajib dipanggil SEBELUM authenticate(),
      // dan cukup sekali.
      if (!_googleInitialized) {
        await gsi.initialize(serverClientId: _webClientId);
        _googleInitialized = true;
      }

      final account = await gsi.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AuthException('Could not get a Google token. Please try again.');
      }
      return GoogleAuthProvider.credential(idToken: idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw AuthException('Google sign-in failed (${e.code.name}). Please try again.');
    }
  }

  /// Return null kalau user membatalkan dialog Google.
  Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final credential = await _googleCredential();
      if (credential == null) return null;
      final cred = await _auth.signInWithCredential(credential);
      return _toMap(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  // ---------------- Nomor HP (OTP) ----------------

  /// Kirim kode OTP ke [phoneNumber] (format +62...).
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String message) onError,
    int? forceResendingToken,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        timeout: const Duration(seconds: 60),
        // User tetap mengetik kode sendiri supaya alurnya selalu sama
        verificationCompleted: (_) {},
        verificationFailed: (e) => onError(_message(e)),
        codeSent: (id, token) => onCodeSent(id, token),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (_) {
      onError('Could not send the code. Check your connection and try again.');
    }
  }

  Future<Map<String, String>> confirmPhoneCode(
      String verificationId, String smsCode) async {
    try {
      final cred = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        ),
      );
      return _toMap(cred.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  // ---------------- Logout ----------------

  Future<void> signOut() async {
    await _signOutGoogle();
    await _auth.signOut();
  }

  Future<void> _signOutGoogle() async {
    try {
      if (_googleInitialized) await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  // ---------------- Hapus akun ----------------

  Future<bool> deleteAccount({
    String? password,
    Future<void> Function()? beforeDelete,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return true;

    try {
      final providers = user.providerData.map((p) => p.providerId).toList();

      if (providers.contains('google.com')) {
        final credential = await _googleCredential();
        if (credential == null) return false;
        await user.reauthenticateWithCredential(credential);
      } else if (providers.contains('password')) {
        if (password == null || password.isEmpty) {
          throw AuthException('Enter your password to confirm',
              needsPassword: true);
        }
        await user.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: user.email!, password: password),
        );
      }

      // Hapus data cloud selagi masih login (aturan Firestore butuh login)
      if (beforeDelete != null) await beforeDelete();

      await user.delete();
      await _signOutGoogle();
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e));
    }
  }

  // ---------------- Pesan error ----------------

  String _message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Incorrect email or password, or the account does not exist';
      case 'email-already-in-use':
        return 'This email is already registered. Please log in';
      case 'weak-password':
        return 'Password is too weak (at least 6 characters)';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'No internet connection';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled, or SMS for your region is not allowed in Firebase Console';
      case 'account-exists-with-different-credential':
        return 'This email is already registered with a different sign-in method';
      case 'invalid-phone-number':
        return 'Invalid phone number';
      case 'invalid-verification-code':
        return 'Incorrect verification code';
      case 'session-expired':
        return 'The code has expired. Please request a new one';
      case 'quota-exceeded':
        return 'SMS limit reached. Please try again later';
      case 'requires-recent-login':
        return 'For security, please log out and log in again, then try deleting your account';
      default:
        return 'Something went wrong (${e.code})';
    }
  }
}