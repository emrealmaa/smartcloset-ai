import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'login_screen.dart';
import '../home/home_screen.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  final String? email;
  const VerifyEmailScreen({super.key, this.email});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen>
    with TickerProviderStateMixin {
  Timer? _checkTimer;
  Timer? _resendCooldownTimer;
  bool _isCheckingVerification = false;
  bool _canResend = false;
  int _resendCooldown = 60; // saniye

  // Zarf animasyonu
  late AnimationController _envelopeController;
  late AnimationController _pulseController;
  late Animation<double> _envelopeBounce;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Zarf bounce animasyonu
    _envelopeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _envelopeBounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _envelopeController, curve: Curves.easeInOut),
    );

    // Pulse glow animasyonu
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Her 3 saniyede doğrulama kontrolü yap
    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkVerification();
    });

    // 60 saniye sonra tekrar gönder butonunu aç
    _startResendCooldown();
  }

  void _startResendCooldown() {
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _resendCooldown--);
      if (_resendCooldown <= 0) {
        timer.cancel();
        if (mounted) setState(() => _canResend = true);
      }
    });
  }

  Future<void> _checkVerification() async {
    if (_isCheckingVerification) return;
    setState(() => _isCheckingVerification = true);

    final verified = await ref.read(authServiceProvider).checkEmailVerified();

    if (!mounted) return;
    setState(() => _isCheckingVerification = false);

    if (verified) {
      // ✅ Mail doğrulandı → Ana ekrana yönlendir
      _checkTimer?.cancel();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    final result =
        await ref.read(authServiceProvider).resendVerificationEmail();
    if (!mounted) return;

    showScSnackbar(
      context,
      result.message,
      isSuccess: result.isSuccess,
      isError: result.isError,
    );

    if (result.isSuccess) {
      _startResendCooldown();
    }
  }

  Future<void> _cancelAndGoBack() async {
    await ref.read(authServiceProvider).signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _resendCooldownTimer?.cancel();
    _envelopeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email ??
        ref.read(authServiceProvider).currentUser?.email ??
        'mail adresine';

    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // Arka plan glow
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => CustomPaint(
                painter: _GlowPainter(opacity: _pulseAnim.value * 0.08),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // ── AppBar ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _cancelAndGoBack,
                          icon: const Icon(
                            Icons.close,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── Zarf Animasyonu ────────────────────────────
                  AnimatedBuilder(
                    animation: _envelopeBounce,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _envelopeBounce.value),
                      child: child,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse circle
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, __) => Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.neonGreen
                                  .withOpacity(_pulseAnim.value * 0.12),
                            ),
                          ),
                        ),
                        // İkon
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.cardSurface,
                            border: Border.all(
                              color: AppTheme.neonGreen.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.mark_email_unread,
                            color: AppTheme.neonGreen,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Başlık ─────────────────────────────────────
                  Text(
                    'Mailini kontrol et!',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Mail adresi kutusu
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.borderColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color: AppTheme.neonGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            email,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Yukarıdaki adrese bir doğrulama maili gönderdik.\nMaildeki linke tıkla, otomatik olarak giriş yapacaksın.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.7,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Otomatik kontrol bilgisi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isCheckingVerification)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.neonGreen),
                          ),
                        ),
                      if (_isCheckingVerification) const SizedBox(width: 8),
                      Text(
                        _isCheckingVerification
                            ? 'Doğrulama kontrol ediliyor...'
                            : 'Doğrulama bekleniyor',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),

                  // ── Manuel Kontrol Butonu ──────────────────────
                  ScButton(
                    label: 'Doğruladım, devam et',
                    onPressed: _checkVerification,
                    isLoading: _isCheckingVerification,
                    icon: Icons.check_circle_outline,
                  ),

                  const SizedBox(height: 16),

                  // ── Tekrar Gönder ─────────────────────────────
                  GestureDetector(
                    onTap: _canResend ? _resendEmail : null,
                    child: AnimatedOpacity(
                      opacity: _canResend ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          _canResend
                              ? 'Tekrar gönder'
                              : 'Tekrar gönder (${_resendCooldown}s)',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Spam uyarısı ──────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Mail gelmedi mi? Spam/Junk klasörünü kontrol et.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double opacity;
  _GlowPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          const Color(0xFFCCFF00).withOpacity(opacity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) => old.opacity != opacity;
}
