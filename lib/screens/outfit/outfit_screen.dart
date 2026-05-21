import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/enums/clothing_enums.dart';
import '../../core/utils/color_utils.dart';
import '../../models/outfit_suggestion.dart';
import '../../models/style_explanation.dart';
import '../../models/wardrobe_gap.dart';
import '../../providers/clothing_provider.dart';
import '../../providers/outfit_provider.dart';
import '../../theme/app_theme.dart';
import '../closet/closet_screen.dart';

class OutfitScreen extends ConsumerWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(outfitSuggestionsProvider);
    final clothingAsync = ref.watch(clothingListProvider);
    final gapsAsync = ref.watch(wardrobeGapsProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kombinlerim',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.charcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    suggestionsAsync.when(
                      data: (list) => Text(
                        '${list.length} kombin önerisi',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ── İçerik ─────────────────────────────────────
            clothingAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.neonGreen),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Hata: $e')),
              ),
              data: (clothing) {
                final hasTops = clothing.any(
                    (i) => i.category.name == 'top');
                final hasBottoms = clothing.any(
                    (i) => i.category.name == 'bottom');

                if (!hasTops || !hasBottoms) {
                  return SliverFillRemaining(
                    child: _NotEnoughClothes(
                      hasTops: hasTops,
                      hasBottoms: hasBottoms,
                      onGoToCloset: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ClosetScreen()),
                      ),
                    ),
                  );
                }

                return suggestionsAsync.when(
                  loading: () => const SliverFillRemaining(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppTheme.neonGreen),
                    ),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('Hata: $e')),
                  ),
                  data: (suggestions) {
                    if (suggestions.isEmpty) {
                      return const SliverFillRemaining(
                        child: _NoSuggestions(),
                      );
                    }
                    return _SuggestionList(suggestions: suggestions);
                  },
                );
              },
            ),

            // ── Eksik Parça Bölümü ──────────────────────────
            gapsAsync.when(
              data: (gaps) => gaps.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverToBoxAdapter(child: _GapsSection(gaps: gaps)),
              loading: () =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
              error: (_, __) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Suggestion List ───────────────────────────────────────────────
class _SuggestionList extends StatelessWidget {
  final List<OutfitSuggestion> suggestions;
  const _SuggestionList({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: _OutfitCard(suggestion: suggestions[i], index: i),
        ),
        childCount: suggestions.length,
      ),
    );
  }
}

// ── Outfit Card ───────────────────────────────────────────────────
class _OutfitCard extends StatefulWidget {
  final OutfitSuggestion suggestion;
  final int index;

  const _OutfitCard({required this.suggestion, required this.index});

  @override
  State<_OutfitCard> createState() => _OutfitCardState();
}

class _OutfitCardState extends State<_OutfitCard> {
  bool _expanded = false;

  OutfitSuggestion get s => widget.suggestion;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.softGray),
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoal.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Ana içerik ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Renk sütunları
                _ColorColumn(suggestion: s),
                const SizedBox(width: 14),

                // Bilgi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${widget.index + 1} — ${s.top.subcategory.label} + ${s.bottom.subcategory.label}'
                        '${s.outerwear != null ? ' + ${s.outerwear!.subcategory.label}' : ''}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.charcoal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${s.top.name}  ·  ${s.bottom.name}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      _ScoreBadges(suggestion: s),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Neden Bu Kombin? ───────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              decoration: BoxDecoration(
                color: _expanded
                    ? AppTheme.charcoal.withOpacity(0.04)
                    : Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 14, color: AppTheme.neonGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Neden Bu Kombin?',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.neonGreen,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.neonGreen,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  if (_expanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: s.explanations
                            .map((e) => _ExplanationCard(exp: e))
                            .toList(),
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
}

// ── Color Column ──────────────────────────────────────────────────
class _ColorColumn extends StatelessWidget {
  final OutfitSuggestion suggestion;
  const _ColorColumn({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final items = suggestion.items;
    return Column(
      children: List.generate(items.length, (i) {
        final color = ColorUtils.fromHex(items[i].primaryColorHex);
        return Container(
          width: 52,
          height: items.length > 2 ? 48 : 60,
          margin: EdgeInsets.only(bottom: i < items.length - 1 ? 4 : 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _categoryEmoji(items[i].category.name),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      }),
    );
  }

  String _categoryEmoji(String category) => switch (category) {
        'top' => '👕',
        'bottom' => '👖',
        'outerwear' => '🧥',
        'shoes' => '👟',
        _ => '💍',
      };
}

// ── Score Badges ──────────────────────────────────────────────────
class _ScoreBadges extends StatelessWidget {
  final OutfitSuggestion suggestion;
  const _ScoreBadges({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Badge(
          label: 'Uyum',
          value: '${suggestion.harmonyScore}',
          color: _scoreColor(suggestion.harmonyScore),
        ),
        const SizedBox(width: 8),
        _Badge(
          label: 'Çok Yönlü',
          value: '${suggestion.versatilityScore}',
          color: _scoreColor(suggestion.versatilityScore),
        ),
      ],
    );
  }

  Color _scoreColor(int score) {
    if (score >= 75) return const Color(0xFF2D6B4A);
    if (score >= 55) return const Color(0xFFC9A227);
    return const Color(0xFFC0704A);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Badge(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 10, color: color, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Explanation Card ──────────────────────────────────────────────
class _ExplanationCard extends StatelessWidget {
  final StyleExplanation exp;
  const _ExplanationCard({required this.exp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.neonGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(exp.icon, size: 16, color: AppTheme.neonGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  exp.body,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gaps Section ──────────────────────────────────────────────────
class _GapsSection extends StatelessWidget {
  final List<WardrobeGap> gaps;
  const _GapsSection({required this.gaps});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppTheme.softGray, height: 32),
          Row(
            children: [
              const Icon(Icons.search, size: 16, color: AppTheme.charcoal),
              const SizedBox(width: 8),
              Text(
                'Gardırobu Tamamla',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Stil motorunun tespit ettiği eksik kilit parçalar:',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          ...gaps.map((gap) => _GapCard(gap: gap)),
        ],
      ),
    );
  }
}

class _GapCard extends StatelessWidget {
  final WardrobeGap gap;
  const _GapCard({required this.gap});

  @override
  Widget build(BuildContext context) {
    final priorityColor = gap.priority == 1
        ? AppTheme.errorRed
        : gap.priority == 2
            ? const Color(0xFFC9A227)
            : AppTheme.neonGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'P${gap.priority}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: priorityColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gap.subcategoryLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  gap.reason,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        size: 12, color: AppTheme.neonGreen),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        gap.tip,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Not Enough Clothes ────────────────────────────────────────────
class _NotEnoughClothes extends StatelessWidget {
  final bool hasTops;
  final bool hasBottoms;
  final VoidCallback onGoToCloset;

  const _NotEnoughClothes({
    required this.hasTops,
    required this.hasBottoms,
    required this.onGoToCloset,
  });

  @override
  Widget build(BuildContext context) {
    final missing = [
      if (!hasTops) 'üst kıyafet',
      if (!hasBottoms) 'alt kıyafet',
    ].join(' ve ');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.softGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.style_outlined,
                  color: AppTheme.mediumGray, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Kombin için yetersiz',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kombin önerisi üretmek için en az\nbir $missing gerekiyor.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onGoToCloset,
              icon: const Icon(Icons.checkroom_outlined, size: 18),
              label: const Text('Gardıroba Git'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.charcoal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No Suggestions ────────────────────────────────────────────────
class _NoSuggestions extends StatelessWidget {
  const _NoSuggestions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, color: AppTheme.mediumGray, size: 48),
            const SizedBox(height: 16),
            Text(
              'Uyumlu kombinasyon bulunamadı',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Mevcut parçalar vücut tipi ve renk kurallarına göre '
              'uyumlu çift oluşturmuyor. Gardıroba nötr renkli parçalar eklemeyi dene.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
