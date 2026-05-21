import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final result = await ref.read(authServiceProvider).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (result.isUnverified) {
      // Mail doğrulanmamış → doğrulama ekranına gönder
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    } else {
      showScSnackbar(context, result.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonGreen.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 48),

                        // ── Logo ──────────────────────────────────
                        const Center(child: ScLogo()),
                        const SizedBox(height: 56),

                        // ── Başlık ────────────────────────────────
                        Text(
                          'Tekrar hoş\ngeldin.',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gardırobuna devam et.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 40),

                        // ── Mail ──────────────────────────────────
                        ScTextField(
                          hint: 'Mail adresi',
                          controller: _emailController,
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          focusNode: _emailFocus,
                          onEditingComplete: () =>
                              FocusScope.of(context).requestFocus(_passwordFocus),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Mail gerekli';
                            if (!v.contains('@')) return 'Geçersiz mail';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Şifre ─────────────────────────────────
                        ScTextField(
                          hint: 'Şifre',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _login,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Şifre gerekli';
                            return null;
                          },
                        ),

                        // ── Şifremi Unuttum ───────────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            ),
                            child: const Text('Şifremi unuttum'),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Giriş Yap Butonu ─────────────────────
                        ScButton(
                          label: 'Giriş Yap',
                          onPressed: _login,
                          isLoading: _isLoading,
                          icon: Icons.arrow_forward,
                        ),

                        const SizedBox(height: 32),

                        // ── Divider ───────────────────────────────
                        const ScDivider(text: 'veya'),
                        const SizedBox(height: 32),

                        // ── Kayıt Ol ──────────────────────────────
                        ScOutlineButton(
                          label: 'Yeni hesap oluştur',
                          icon: Icons.person_add_outlined,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ── Alt yazı ──────────────────────────────
                        Center(
                          child: Text(
                            'SmartCloset AI\'a giriş yaparak\nGizlilik Politikası\'nı kabul etmiş olursun.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
