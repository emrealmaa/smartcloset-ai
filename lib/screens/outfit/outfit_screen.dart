import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/clothing_model.dart';
import '../../providers/clothing_provider.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

// ── Kombin oluşturucu state ───────────────────────────────────────
class OutfitBuilderState {
  final List<ClothingModel> selectedItems;
  final bool isAnalyzing;
  final OutfitAnalysis? aiSuggestion;

  const OutfitBuilderState({
    this.selectedItems = const [],
    this.isAnalyzing = false,
    this.aiSuggestion,
  });

  OutfitBuilderState copyWith({
    List<ClothingModel>? selectedItems,
    bool? isAnalyzing,
    OutfitAnalysis? aiSuggestion,
  }) =>
      OutfitBuilderState(
        selectedItems: selectedItems ?? this.selectedItems,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
        aiSuggestion: aiSuggestion ?? this.aiSuggestion,
      );
}

class OutfitBuilderNotifier extends StateNotifier<OutfitBuilderState> {
  final AiService _ai;
  OutfitBuilderNotifier(this._ai) : super(const OutfitBuilderState());

  void toggleItem(ClothingModel item) {
    final current = List<ClothingModel>.from(state.selectedItems);
    if (current.any((c) => c.id == item.id)) {
      current.removeWhere((c) => c.id == item.id);
    } else {
      current.add(item);
    }
    state = state.copyWith(selectedItems: current, aiSuggestion: null);
  }

  bool isSelected(String id) => state.selectedItems.any((c) => c.id == id);

  Future<void> analyzeSelectedOutfit() async {
    if (state.selectedItems.isEmpty) return;
    // Seçili kıyafetlerin ilk fotoğrafını analiz et
    final withImage =
        state.selectedItems.where((c) => c.imagePath != null).toList();
    if (withImage.isEmpty) return;

    state = state.copyWith(isAnalyzing: true);
    final result =
        await _ai.analyzeOutfitFromFile(File(withImage.first.imagePath!));
    state = state.copyWith(isAnalyzing: false, aiSuggestion: result);
  }

  void reset() => state = const OutfitBuilderState();
}

final outfitBuilderProvider =
    StateNotifierProvider<OutfitBuilderNotifier, OutfitBuilderState>((ref) {
  return OutfitBuilderNotifier(ref.read(aiServiceProvider));
});

// ── Outfit Screen ─────────────────────────────────────────────────
class OutfitScreen extends ConsumerWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clothingAsync = ref.watch(clothingListProvider);
    final builderState = ref.watch(outfitBuilderProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: clothingAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.neonGreen),
              strokeWidth: 2,
            ),
          ),
          error: (e, _) => Center(child: Text('Hata: $e')),
          data: (clothes) {
            if (clothes.isEmpty) return _EmptyState();
            return _OutfitBuilder(clothes: clothes, state: builderState);
          },
        ),
      ),
    );
  }
}

// ── Outfit Builder ────────────────────────────────────────────────
class _OutfitBuilder extends ConsumerWidget {
  final List<ClothingModel> clothes;
  final OutfitBuilderState state;
  const _OutfitBuilder({required this.clothes, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ['Tümü', ...ClothingModel.categories];
    final selectedCat = ref.watch(selectedCategoryProvider);

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kombin Oluştur',
                        style: Theme.of(context).textTheme.headlineLarge),
                    Text('Kıyafetlerini seç, AI analiz etsin.',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 20),

                    // Seçili kombin önizleme
                    if (state.selectedItems.isNotEmpty)
                      _SelectedPreview(state: state),

                    const SizedBox(height: 16),

                    // Kategori filtreleri
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final active = categories[i] == selectedCat;
                          return GestureDetector(
                            onTap: () => ref
                                .read(selectedCategoryProvider.notifier)
                                .state = categories[i],
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: active
                                    ? AppTheme.neonGreen
                                    : AppTheme.warmWhite,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? AppTheme.neonGreen
                                      : AppTheme.softGray,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(categories[i],
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: active
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    )),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Kıyafet grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SelectableClothingCard(
                    item: clothes[index],
                    isSelected: ref
                        .watch(outfitBuilderProvider.notifier)
                        .isSelected(clothes[index].id),
                  ),
                  childCount: clothes.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),

        // AI Öneri panel
        if (state.aiSuggestion != null)
          _AiSuggestionPanel(analysis: state.aiSuggestion!),
      ],
    );
  }
}

// ── Selected Preview ──────────────────────────────────────────────
class _SelectedPreview extends ConsumerWidget {
  final OutfitBuilderState state;
  const _SelectedPreview({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(16),
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
              Text(
                '${state.selectedItems.length} parça seçildi',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoal,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => ref.read(outfitBuilderProvider.notifier).reset(),
                child: Text('Temizle',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.errorRed,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.selectedItems.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final item = state.selectedItems[i];
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.softGray),
                    image: item.imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(item.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.imagePath == null
                      ? const Icon(Icons.checkroom_outlined,
                          size: 24, color: AppTheme.mediumGray)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: state.isAnalyzing
                ? null
                : () => ref
                    .read(outfitBuilderProvider.notifier)
                    .analyzeSelectedOutfit(),
            child: Container(
              height: 44,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: state.isAnalyzing
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'AI ile Kombin Analiz Et',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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

// ── Selectable Clothing Card ──────────────────────────────────────
class _SelectableClothingCard extends ConsumerWidget {
  final ClothingModel item;
  final bool isSelected;
  const _SelectableClothingCard({required this.item, required this.isSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(outfitBuilderProvider.notifier).toggleItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.neonGreen : AppTheme.softGray,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: item.imagePath != null
                        ? Image.file(
                            File(item.imagePath!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(item.category,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: AppTheme.mediumGray,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppTheme.neonGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
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
              color: AppTheme.mediumGray, size: 32),
        ),
      );
}

// ── AI Suggestion Panel ───────────────────────────────────────────
class _AiSuggestionPanel extends ConsumerWidget {
  final OutfitAnalysis analysis;
  const _AiSuggestionPanel({required this.analysis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
        decoration: const BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppTheme.neonGreen, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(analysis.overallStyle,
                              style: Theme.of(context).textTheme.titleMedium),
                        ),
                        GestureDetector(
                          onTap: () =>
                              ref.read(outfitBuilderProvider.notifier).reset(),
                          child: const Icon(Icons.close,
                              size: 18, color: AppTheme.mediumGray),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(analysis.occasion,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    ...analysis.pieces.map((piece) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _hexToColor(piece.colorHex),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(piece.name,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.charcoal,
                                    )),
                              ),
                              Text(piece.color,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    color: AppTheme.mediumGray,
                                  )),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppTheme.neonGreen;
    }
  }
}

// ── Empty State ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.warmWhite,
                border: Border.all(color: AppTheme.softGray, width: 1),
              ),
              child: const Icon(Icons.layers_outlined,
                  color: AppTheme.mediumGray, size: 36),
            ),
            const SizedBox(height: 20),
            Text('Henüz kıyafet yok',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Önce Gardırop sekmesine gidip kıyafet ekle.\nSonra buradan kombin oluşturabilirsin.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
