import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final result = await ref.read(authServiceProvider).sendPasswordReset(
          email: _emailController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      setState(() => _sent = true);
    } else {
      showScSnackbar(context, result.message, isError: true);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textSecondary, size: 20),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _sent ? _successView() : _formView(),
      ),
    );
  }

  Widget _formView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Şifreni mi\nunuttun?',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(height: 1.1)),
          const SizedBox(height: 12),
          Text(
            'Mail adresini gir, sıfırlama linkini gönderelim.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          ScTextField(
            hint: 'Mail adresi',
            controller: _emailController,
            prefixIcon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onEditingComplete: _send,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Mail gerekli';
              if (!v.contains('@')) return 'Geçersiz mail';
              return null;
            },
          ),
          const SizedBox(height: 24),
          ScButton(
            label: 'Sıfırlama Maili Gönder',
            onPressed: _send,
            isLoading: _isLoading,
            icon: Icons.send_outlined,
          ),
        ],
      ),
    );
  }

  Widget _successView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardSurface,
            border: Border.all(
              color: AppTheme.neonGreen.withOpacity(0.4),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.check, color: AppTheme.neonGreen, size: 44),
        ),
        const SizedBox(height: 32),
        Text('Mail gönderildi!',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          '${_emailController.text} adresine\nsıfırlama linki gönderildi.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        ScButton(
          label: 'Giriş ekranına dön',
          onPressed: () => Navigator.pop(context),
          icon: Icons.arrow_back,
        ),
      ],
    );
  }
}
