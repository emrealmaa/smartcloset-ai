import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/weather_widget.dart';
import '../inspiration/inspiration_screen.dart';

// ── Shop Kategorileri ─────────────────────────────────────────────
const _shopCategories = [
  _ShopCategory(
    label: 'Günlük',
    icon: Icons.wb_sunny_outlined,
    searches: ['günlük tişört', 'casual pantolon', 'sneaker'],
  ),
  _ShopCategory(
    label: 'Ofis',
    icon: Icons.business_center_outlined,
    searches: ['blazer kadın', 'ofis pantolonu', 'oxford ayakkabı'],
  ),
  _ShopCategory(
    label: 'Spor',
    icon: Icons.fitness_center_outlined,
    searches: ['spor tayt', 'athletic tişört', 'spor ayakkabı'],
  ),
  _ShopCategory(
    label: 'Gece',
    icon: Icons.nights_stay_outlined,
    searches: ['gece elbisesi', 'elegant bluz', 'topuklu ayakkabı'],
  ),
  _ShopCategory(
    label: 'Kış',
    icon: Icons.ac_unit_outlined,
    searches: ['kışlık kaban', 'kalın kazak', 'bot'],
  ),
];

class _ShopCategory {
  final String label;
  final IconData icon;
  final List<String> searches;
  const _ShopCategory(
      {required this.label, required this.icon, required this.searches});
}

final selectedShopCategoryProvider = StateProvider<int>((ref) => 0);

// ── Shop Screen ───────────────────────────────────────────────────
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCat = ref.watch(selectedShopCategoryProvider);
    final category = _shopCategories[selectedCat];
    final analysisState = ref.watch(analysisProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Keşfet & Al',
                        style: Theme.of(context).textTheme.headlineLarge),
                    Text('Eksik parçaları bul, mağazaya git.',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Hava durumu
                    const WeatherWidget(),
                    const SizedBox(height: 20),

                    // AI analiz sonuçlarından gelen öneriler
                    if (analysisState.result != null) ...[
                      _AiResultBanner(analysis: analysisState.result!),
                      const SizedBox(height: 20),
                    ],

                    // Kategori seçici
                    Text('Stil Seç',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        )),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _shopCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final active = i == selectedCat;
                          final cat = _shopCategories[i];
                          return GestureDetector(
                            onTap: () => ref
                                .read(selectedShopCategoryProvider.notifier)
                                .state = i,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppTheme.neonGreen
                                    : AppTheme.warmWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: active
                                      ? AppTheme.neonGreen
                                      : AppTheme.softGray,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(cat.icon,
                                      color: active
                                          ? Colors.white
                                          : AppTheme.mediumGray,
                                      size: 22),
                                  const SizedBox(height: 4),
                                  Text(cat.label,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    Text('${category.label} — Öneriler',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Ürün Arama Kartları ─────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SearchProductCard(
                      keyword: category.searches[index],
                      index: index,
                    ),
                  ),
                  childCount: category.searches.length,
                ),
              ),
            ),

            // ── Mağaza Hızlı Erişim ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mağazalar',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    _StoreGrid(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

// ── AI Result Banner ──────────────────────────────────────────────
class _AiResultBanner extends StatelessWidget {
  final OutfitAnalysis analysis;
  const _AiResultBanner({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.neonGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.neonGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                'AI Analiz Sonucu — ${analysis.overallStyle}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                analysis.pieces.map((p) => _SearchableTag(piece: p)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SearchableTag extends StatelessWidget {
  final AnalyzedPiece piece;
  const _SearchableTag({required this.piece});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(
          'https://www.trendyol.com/sr?q=${Uri.encodeComponent(piece.searchKeyword)}',
        );
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.softGray),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search, size: 12, color: AppTheme.neonGreen),
            const SizedBox(width: 4),
            Text(
              piece.name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: AppTheme.charcoal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search Product Card ───────────────────────────────────────────
class _SearchProductCard extends StatelessWidget {
  final String keyword;
  final int index;
  const _SearchProductCard({required this.keyword, required this.index});

  static const _stores = [
    ('Trendyol', 'https://www.trendyol.com/sr?q=', 0xFFf27a1a),
    ('Zara', 'https://www.zara.com/tr/tr/search?searchTerm=', 0xFF1E1E1E),
    ('H&M', 'https://www2.hm.com/tr_tr/search-results.html?q=', 0xFFe50010),
    ('Koton', 'https://www.koton.com/tr/ara/?search=', 0xFF1B4F8A),
    ('Mango', 'https://shop.mango.com/tr/arama?term=', 0xFF8B6914),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    _categoryEmoji(index),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalize(keyword),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal,
                      ),
                    ),
                    Text(
                      '${_stores.length} mağazada ara',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _stores.map((store) {
              final color = Color(store.$3);
              final url = store.$2 + Uri.encodeComponent(keyword);
              return GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: color.withOpacity(0.25), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new, size: 11, color: color),
                      const SizedBox(width: 4),
                      Text(
                        store.$1,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _categoryEmoji(int i) {
    const emojis = ['👕', '👗', '🏃', '✨', '🧥'];
    return emojis[i % emojis.length];
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Store Grid ────────────────────────────────────────────────────
class _StoreGrid extends StatelessWidget {
  static const _stores = [
    _StoreInfo('Trendyol', 'https://www.trendyol.com', 0xFFf27a1a, '🛒'),
    _StoreInfo('Zara', 'https://www.zara.com/tr', 0xFF1E1E1E, '🛍️'),
    _StoreInfo('H&M', 'https://www2.hm.com/tr_tr', 0xFFe50010, '👗'),
    _StoreInfo('Mango', 'https://shop.mango.com/tr', 0xFF8B6914, '✨'),
    _StoreInfo('Koton', 'https://www.koton.com', 0xFF1B4F8A, '👕'),
    _StoreInfo('Mavi', 'https://www.mavi.com', 0xFF0055A5, '👖'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: _stores.length,
      itemBuilder: (_, i) => _StoreTile(store: _stores[i]),
    );
  }
}

class _StoreInfo {
  final String name;
  final String url;
  final int colorValue;
  final String emoji;
  const _StoreInfo(this.name, this.url, this.colorValue, this.emoji);
}

class _StoreTile extends StatelessWidget {
  final _StoreInfo store;
  const _StoreTile({required this.store});

  @override
  Widget build(BuildContext context) {
    final color = Color(store.colorValue);
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(store.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.softGray, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(store.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              store.name,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
