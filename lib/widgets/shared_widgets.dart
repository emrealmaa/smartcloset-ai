import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  const ScLogo({super.key, this.size = 1.0, this.showTagline = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'SMART',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 32 * size,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.charcoal,
                    letterSpacing: -0.5),
              ),
              TextSpan(
                text: 'CLOSET',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 32 * size,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.neonGreen,
                    letterSpacing: -0.5),
              ),
              TextSpan(
                text: ' AI',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 32 * size,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.mediumGray,
                    letterSpacing: -0.5),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 6),
          Text('Geleceğin Gardırop Deneyimi',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12 * size,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5)),
        ],
      ],
    );
  }
}

class ScButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  const ScButton(
      {super.key,
      required this.label,
      this.onPressed,
      this.isLoading = false,
      this.icon});

  @override
  State<ScButton> createState() => _ScButtonState();
}

class _ScButtonState extends State<ScButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp: (_) => _c.reverse(),
      onTapCancel: () => _c.reverse(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _s,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: (widget.onPressed == null || widget.isLoading)
                ? AppTheme.neonGreen.withOpacity(0.4)
                : AppTheme.neonGreen,
            borderRadius: BorderRadius.circular(14),
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8)
                  ],
                  Text(widget.label,
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3)),
                ]),
        ),
      ),
    );
  }
}

class ScOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const ScOutlineButton(
      {super.key, required this.label, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.softGray, width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[
            Icon(icon, color: AppTheme.charcoal, size: 20),
            const SizedBox(width: 8)
          ],
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal)),
        ]),
      ),
    );
  }
}

class ScTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const ScTextField(
      {super.key,
      required this.hint,
      required this.controller,
      this.isPassword = false,
      this.prefixIcon,
      this.validator,
      this.keyboardType = TextInputType.text,
      this.textInputAction = TextInputAction.next,
      this.focusNode,
      this.onEditingComplete});

  @override
  State<ScTextField> createState() => _ScTextFieldState();
}

class _ScTextFieldState extends State<ScTextField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      onEditingComplete: widget.onEditingComplete,
      style: GoogleFonts.spaceGrotesk(color: AppTheme.charcoal, fontSize: 15),
      validator: widget.validator,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                    size: 20, color: AppTheme.textMuted),
                onPressed: () => setState(() => _obscure = !_obscure))
            : null,
      ),
    );
  }
}

class ScDivider extends StatelessWidget {
  final String text;
  const ScDivider({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Divider()),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(text,
              style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textMuted, fontSize: 13))),
      const Expanded(child: Divider()),
    ]);
  }
}

void showScSnackbar(BuildContext context, String message,
    {bool isError = false, bool isSuccess = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(
          isError
              ? Icons.error_outline
              : isSuccess
                  ? Icons.check_circle_outline
                  : Icons.info_outline,
          color: isError
              ? AppTheme.errorRed
              : isSuccess
                  ? AppTheme.accentGreen
                  : AppTheme.mediumGray,
          size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message)),
    ]),
    duration: const Duration(seconds: 3),
  ));
}
