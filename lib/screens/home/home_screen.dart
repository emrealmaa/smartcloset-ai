import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/character_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/enums/skin_enums.dart';
import '../../core/enums/body_enums.dart';
import '../../core/enums/face_enums.dart';
import '../../models/character_profile.dart';
import '../closet/closet_screen.dart';
import '../education/education_screen.dart';
import '../outfit/outfit_screen.dart';
import '../profile/profile_edit_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(characterProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.neonGreen),
          ),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (profile) {
            if (profile == null) {
              return const Center(child: Text('Profil bulunamadı.'));
            }
            return _HomeBody(profile: profile);
          },
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final CharacterProfile profile;
  const _HomeBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba 👋',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stil koçun hazır.',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.charcoal,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => FirebaseAuth.instance.signOut(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.warmWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.softGray),
                        ),
                        child: const Icon(Icons.logout,
                            size: 18, color: AppTheme.charcoal),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                _ProfileSummaryCard(profile: profile),

                const SizedBox(height: 24),
                Text(
                  'Özellikler',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 12),
                _ActiveFeatureCard(
                  icon: Icons.checkroom_outlined,
                  title: 'Dijital Gardırop',
                  subtitle: 'Kıyafetlerini ekle, envanterini yönet',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ClosetScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _ActiveFeatureCard(
                  icon: Icons.style_outlined,
                  title: 'Kombin Motoru',
                  subtitle: 'Vücut tipine özel kombinler + NEDEN açıklaması',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const OutfitScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                _ActiveFeatureCard(
                  icon: Icons.school_outlined,
                  title: 'Stil Eğitimi',
                  subtitle:
                      'Kişisel renk kuralların, fit rehberin, desen dersleri',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const EducationScreen()),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Profile Summary Card ──────────────────────────────────────────
class _ProfileSummaryCard extends StatelessWidget {
  final CharacterProfile profile;
  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final undertone = profile.skinUndertone;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: AppTheme.neonGreen, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karakter Profili',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 11, color: Colors.white38),
                    ),
                    Text(
                      '${profile.bodyType.label} · ${undertone.label} Ton',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white60, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          Text(
            'RENK PALETİN',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 10, color: Colors.white38, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Row(
            children: undertone.palette.asMap().entries.map((entry) {
              return Expanded(
                child: Tooltip(
                  message: undertone.paletteLabels[entry.key],
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '${profile.heightCm} cm · ${profile.weightKg.round()} kg · '
            '${profile.faceShape.label} yüz · ${profile.beardStyle.label} sakal',
            style:
                GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// ── Active Feature Card ───────────────────────────────────────────
class _ActiveFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActiveFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.neonGreen, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}
