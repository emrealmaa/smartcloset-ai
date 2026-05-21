import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider ──────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── Auth Service ──────────────────────────────────────────────────
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ── Kayıt Ol ──────────────────────────────────────────────────
  // 1. Kullanıcıyı Firebase'e kaydet
  // 2. Otomatik olarak doğrulama maili gönder
  // 3. Kullanıcıyı doğrulama bekleme ekranına yönlendir
  Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Display name kaydet
      await credential.user?.updateDisplayName(displayName.trim());

      // Doğrulama mailini gönder
      await credential.user?.sendEmailVerification();

      return AuthResult.success(
        message: 'Doğrulama maili $email adresine gönderildi.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _mapFirebaseError(e.code));
    } catch (e) {
      return AuthResult.error(message: 'Beklenmeyen bir hata oluştu.');
    }
  }

  // ── Giriş Yap ─────────────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Mail doğrulanmamışsa uyar
      if (credential.user != null && !credential.user!.emailVerified) {
        return AuthResult.unverified(
          message: 'Mail adresin henüz doğrulanmamış. Gelen kutunu kontrol et.',
        );
      }

      return AuthResult.success(message: 'Hoş geldin!');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _mapFirebaseError(e.code));
    }
  }

  // ── Doğrulama Maili Tekrar Gönder ─────────────────────────────
  Future<AuthResult> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthResult.error(message: 'Oturum bulunamadı.');

      await user.sendEmailVerification();
      return AuthResult.success(message: 'Doğrulama maili tekrar gönderildi.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        return AuthResult.error(
          message: 'Çok fazla istek. Lütfen birkaç dakika bekle.',
        );
      }
      return AuthResult.error(message: _mapFirebaseError(e.code));
    }
  }

  // ── Mail Doğrulama Durumunu Yenile ────────────────────────────
  // Kullanıcı maili doğruladıktan sonra bu metodu çağırıyoruz
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // ── Şifremi Unuttum ───────────────────────────────────────────
  Future<AuthResult> sendPasswordReset({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(
        message: 'Şifre sıfırlama maili $email adresine gönderildi.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(message: _mapFirebaseError(e.code));
    }
  }

  // ── Çıkış Yap ─────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Firebase Hata Kodlarını Türkçeleştir ──────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Bu mail adresi zaten kullanımda.';
      case 'invalid-email':
        return 'Geçersiz mail adresi formatı.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalıdır.';
      case 'user-not-found':
        return 'Bu mail adresiyle kayıtlı hesap bulunamadı.';
      case 'wrong-password':
        return 'Hatalı şifre. Tekrar dene.';
      case 'invalid-credential':
        return 'Mail veya şifre hatalı.';
      case 'too-many-requests':
        return 'Çok fazla başarısız deneme. Lütfen bekle.';
      case 'network-request-failed':
        return 'İnternet bağlantını kontrol et.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar dene.';
    }
  }
}

// ── Auth Result Model ─────────────────────────────────────────────
enum AuthStatus { success, error, unverified }

class AuthResult {
  final AuthStatus status;
  final String message;

  const AuthResult._({required this.status, required this.message});

  factory AuthResult.success({required String message}) =>
      AuthResult._(status: AuthStatus.success, message: message);

  factory AuthResult.error({required String message}) =>
      AuthResult._(status: AuthStatus.error, message: message);

  factory AuthResult.unverified({required String message}) =>
      AuthResult._(status: AuthStatus.unverified, message: message);

  bool get isSuccess => status == AuthStatus.success;
  bool get isError => status == AuthStatus.error;
  bool get isUnverified => status == AuthStatus.unverified;
}
