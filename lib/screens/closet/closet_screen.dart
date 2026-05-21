import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/clothing_model.dart';
import '../../providers/clothing_provider.dart';
import '../../services/weather_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../widgets/weather_widget.dart';
import 'add_clothing_screen.dart';

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothingAsync = ref.watch(clothingListProvider);
    final countAsync = ref.watch(clothingCountProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Dashboard Header ──────────────────────────────────
            SliverToBoxAdapter(
              child: _DashboardHeader(
                countAsync: countAsync,
                weatherAsync: weatherAsync,
              ),
            ),

            // ── Kategori Chips ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _CategoryChips(),
              ),
            ),

            // ── Gardırop Grid ─────────────────────────────────────
            clothingAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppTheme.neonGreen),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Hata: $e')),
              ),
              data: (clothes) {
                if (clothes.isEmpty) {
                  return SliverToBoxAdapter(child: _EmptyCloset());
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: clothes.length,
                    itemBuilder: (context, index) => _ClothingCard(
                      item: clothes[index],
                      onDelete: () => ref
                          .read(clothingActionsProvider)
                          .deleteClothing(clothes[index].id),
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButton: _AddFab(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddClothingScreen()),
        ).then((_) => ref.invalidate(clothingListProvider)),
      ),
    );
  }
}

// ── Dashboard Header ──────────────────────────────────────────────
class _DashboardHeader extends ConsumerWidget {
  final AsyncValue<int> countAsync;
  final AsyncValue<WeatherData?> weatherAsync;

  const _DashboardHeader({
    required this.countAsync,
    required this.weatherAsync,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String _firstName() {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'Kullanıcı';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = countAsync.valueOrNull ?? 0;
    final weather = weatherAsync.valueOrNull;

    return Container(
      color: AppTheme.cream,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Selamlama + Bildirim ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, ${_firstName()} 👋',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _dateLabel(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              // Bildirim ikonu
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.warmWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.softGray),
                ),
                child: const Icon(Icons.notifications_none_rounded,
                    color: AppTheme.textSecondary, size: 22),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Hava + Kombin Önerisi Kartı ─────────────────────────
          if (weather != null) _WeatherOutfitCard(weather: weather),
          if (weather == null) const WeatherWidget(),

          const SizedBox(height: 16),

          // ── Hızlı İstatistikler ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.checkroom_outlined,
                  iconColor: AppTheme.neonGreen,
                  value: '$count',
                  label: 'Kıyafet',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.layers_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  value: '0',
                  label: 'Kombin',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickStatCard(
                  icon: Icons.auto_awesome_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  value: '∞',
                  label: 'İlham',
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Gardırop başlığı ────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gardırobum',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoal,
                ),
              ),
              if (count > 0)
                Text(
                  '$count parça',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppTheme.mediumGray,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  String _dateLabel() {
    final now = DateTime.now();
    const months = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    const days = [
      '',
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    return '${days[now.weekday]}, ${now.day} ${months[now.month]}';
  }
}

// ── Weather + Outfit Card ─────────────────────────────────────────
class _WeatherOutfitCard extends StatelessWidget {
  final WeatherData weather;
  const _WeatherOutfitCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withOpacity(0.15),
            AppTheme.neonGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Hava info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.weatherEmoji,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 4),
              Text(
                '${weather.tempC.round()}°C',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoal,
                ),
              ),
              Text(
                weather.city,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          Container(
            width: 1,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppTheme.neonGreen.withOpacity(0.2),
          ),

          // Kombin önerisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 14, color: AppTheme.neonGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Bugün için öneri',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neonGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  weather.outfitSuggestion,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: AppTheme.charcoal,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _tagColor(weather.weatherTag).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    weather.weatherTagLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _tagColor(weather.weatherTag),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'very_cold':
        return const Color(0xFF60A5FA);
      case 'cold':
        return const Color(0xFF93C5FD);
      case 'mild':
        return const Color(0xFF86EFAC);
      case 'warm':
        return const Color(0xFFFBBF24);
      case 'hot':
        return const Color(0xFFF87171);
      default:
        return AppTheme.neonGreen;
    }
  }
}

// ── Quick Stat Card ───────────────────────────────────────────────
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _QuickStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.charcoal,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category Chips ────────────────────────────────────────────────
class _CategoryChips extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedCategoryProvider);
    final cats = ['Tümü', ...ClothingModel.categories];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = selected == cats[i];
          return GestureDetector(
            onTap: () =>
                ref.read(selectedCategoryProvider.notifier).state = cats[i],
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? AppTheme.neonGreen : AppTheme.warmWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppTheme.neonGreen : AppTheme.softGray,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  cats[i],
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Clothing Card ─────────────────────────────────────────────────
class _ClothingCard extends StatelessWidget {
  final ClothingModel item;
  final VoidCallback onDelete;
  const _ClothingCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.softGray, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotoğraf
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: item.imagePath != null
                  ? AspectRatio(
                      aspectRatio: _ratio(item.id),
                      child: Image.file(
                        File(item.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: 0.85,
                      child: _placeholder(),
                    ),
            ),

            // Bilgi
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.brand != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.brand!,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.neonGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item.category,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                      ),
                      if (item.price != null)
                        Text(
                          '₺${item.price!.toStringAsFixed(0)}',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.charcoal,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: AppTheme.softGray,
        child: const Center(
          child: Icon(Icons.checkroom_outlined,
              color: AppTheme.mediumGray, size: 40),
        ),
      );

  double _ratio(String id) {
    final h = id.hashCode.abs() % 3;
    return h == 0
        ? 0.75
        : h == 1
            ? 0.9
            : 1.1;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Kıyafeti Sil',
          style: GoogleFonts.spaceGrotesk(
            color: AppTheme.charcoal,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '"${item.name}" gardıroptan silinsin mi?',
          style: GoogleFonts.spaceGrotesk(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: Text(
              'Sil',
              style: GoogleFonts.spaceGrotesk(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty Closet ──────────────────────────────────────────────────
class _EmptyCloset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.warmWhite,
              border: Border.all(color: AppTheme.softGray),
            ),
            child: const Icon(Icons.checkroom_outlined,
                color: AppTheme.mediumGray, size: 40),
          ),
          const SizedBox(height: 16),
          Text('Gardırop boş',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.charcoal,
              )),
          const SizedBox(height: 8),
          Text(
            'Sağ alttaki + butonuna basarak\nilk kıyafetini ekle.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────
class _AddFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.neonGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
