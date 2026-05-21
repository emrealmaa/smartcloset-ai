import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import 'verify_email_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLoading = false;
  bool _acceptedTerms = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      showScSnackbar(context, 'Kullanım koşullarını kabul etmelisin.',
          isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final result = await ref.read(authServiceProvider).register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      // ✅ Kayıt başarılı → Doğrulama bekleme ekranına yönlendir
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: _emailController.text),
        ),
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
          // Background glow - sol alt
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.neonGreen.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ── AppBar ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),

                            // ── Başlık ──────────────────────────
                            Text(
                              'Hesap oluştur.',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(height: 1.1),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'SmartCloset AI ',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      color: AppTheme.neonGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'gardırobunu bekliyor.',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // ── Ad Soyad ────────────────────────
                            _fieldLabel('Ad Soyad'),
                            ScTextField(
                              hint: 'Adın nedir?',
                              controller: _nameController,
                              prefixIcon: Icons.person_outline,
                              focusNode: _nameFocus,
                              onEditingComplete: () => FocusScope.of(context)
                                  .requestFocus(_emailFocus),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Ad gerekli';
                                }
                                if (v.trim().length < 2) {
                                  return 'En az 2 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Mail ────────────────────────────
                            _fieldLabel('Mail Adresi'),
                            ScTextField(
                              hint: 'ornek@mail.com',
                              controller: _emailController,
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              focusNode: _emailFocus,
                              onEditingComplete: () => FocusScope.of(context)
                                  .requestFocus(_passwordFocus),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Mail gerekli';
                                }
                                final emailRegex =
                                    RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
                                if (!emailRegex.hasMatch(v)) {
                                  return 'Geçerli bir mail adresi gir';
                                }
                                return null;
                              },
                            ),

                            // Mail doğrulama info kutusu
                            const SizedBox(height: 8),
                            _mailInfoBadge(),
                            const SizedBox(height: 16),

                            // ── Şifre ────────────────────────────
                            _fieldLabel('Şifre'),
                            ScTextField(
                              hint: 'En az 8 karakter',
                              controller: _passwordController,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              focusNode: _passwordFocus,
                              onEditingComplete: () => FocusScope.of(context)
                                  .requestFocus(_confirmFocus),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Şifre gerekli';
                                }
                                if (v.length < 8) {
                                  return 'En az 8 karakter olmalı';
                                }
                                if (!v.contains(RegExp(r'[0-9]'))) {
                                  return 'En az 1 rakam içermeli';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Şifre Tekrar ─────────────────────
                            _fieldLabel('Şifre Tekrar'),
                            ScTextField(
                              hint: 'Şifreni tekrar gir',
                              controller: _confirmController,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              focusNode: _confirmFocus,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: _register,
                              validator: (v) {
                                if (v != _passwordController.text) {
                                  return 'Şifreler eşleşmiyor';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ── Şartları Kabul Et ────────────────
                            _termsRow(),
                            const SizedBox(height: 28),

                            // ── Kayıt Ol Butonu ──────────────────
                            ScButton(
                              label: 'Hesap Oluştur',
                              onPressed: _register,
                              isLoading: _isLoading,
                              icon: Icons.check,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _mailInfoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            color: AppTheme.neonGreen,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kayıt sonrası bu adrese doğrulama maili gönderilecek.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.neonGreen.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _termsRow() {
    return GestureDetector(
      onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _acceptedTerms
                  ? AppTheme.neonGreen
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _acceptedTerms
                    ? AppTheme.neonGreen
                    : AppTheme.borderColor,
                width: 1.5,
              ),
            ),
            child: _acceptedTerms
                ? const Icon(Icons.check, color: AppTheme.black, size: 14)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kullanım Koşulları ve Gizlilik Politikası\'nı okudum, kabul ediyorum.',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
