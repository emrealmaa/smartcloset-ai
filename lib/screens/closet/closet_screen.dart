import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/enums/clothing_enums.dart';
import '../../core/utils/color_utils.dart';
import '../../models/clothing_item.dart';
import '../../providers/clothing_provider.dart';
import '../../theme/app_theme.dart';
import 'add_clothing_screen.dart';

class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  ClothingCategory? _selectedCategory; // null = Tümü

  @override
  Widget build(BuildContext context) {
    final itemsAsync =
        ref.watch(clothingByCategoryProvider(_selectedCategory));

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gardırobum',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.charcoal,
                          letterSpacing: -0.5,
                        ),
                      ),
                      ref.watch(clothingCountProvider).when(
                            data: (count) => Text(
                              '$count parça',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                    ],
                  ),
                  _AddButton(onTap: _openAddScreen),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Kategori Filtreleri ───────────────────────────
            _CategoryTabs(
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
            ),

            const SizedBox(height: 16),

            // ── İçerik ───────────────────────────────────────
            Expanded(
              child: itemsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.neonGreen),
                ),
                error: (e, _) => Center(child: Text('Hata: $e')),
                data: (items) => items.isEmpty
                    ? _EmptyState(
                        category: _selectedCategory,
                        onAdd: _openAddScreen,
                      )
                    : _ClothingGrid(items: items),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        backgroundColor: AppTheme.charcoal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddClothingScreen()),
    );
    if (result == true) {
      ref.invalidate(clothingListProvider);
      ref.invalidate(clothingByCategoryProvider);
      ref.invalidate(clothingCountProvider);
    }
  }
}

// ── Add Button ────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              'Ekle',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category Tabs ─────────────────────────────────────────────────
class _CategoryTabs extends StatelessWidget {
  final ClothingCategory? selected;
  final void Function(ClothingCategory?) onSelect;

  const _CategoryTabs({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _Tab(label: 'Tümü', isSelected: selected == null,
              onTap: () => onSelect(null)),
          ...ClothingCategory.values.map(
            (cat) => _Tab(
              label: cat.label,
              isSelected: selected == cat,
              onTap: () => onSelect(cat),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.charcoal : AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppTheme.charcoal : AppTheme.softGray),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.charcoal,
          ),
        ),
      ),
    );
  }
}

// ── Clothing Grid ─────────────────────────────────────────────────
class _ClothingGrid extends StatelessWidget {
  final List<ClothingItem> items;
  const _ClothingGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ClothingCard(item: items[i]),
    );
  }
}

// ── Clothing Card ─────────────────────────────────────────────────
class _ClothingCard extends StatelessWidget {
  final ClothingItem item;
  const _ClothingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(item.primaryColorHex);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Renk bloğu / fotoğraf
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
            child: item.imagePath != null
                ? SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Image.asset(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _colorBlock(color),
                    ),
                  )
                : _colorBlock(color),
          ),

          // Bilgiler
          Expanded(
            child: Padding(
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
                  const SizedBox(height: 2),
                  Text(
                    item.subcategory.label,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                  const Spacer(),
                  // Fit badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.softGray,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.fitType.label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
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

  Widget _colorBlock(Color color) {
    return Container(
      height: 120,
      width: double.infinity,
      color: color,
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final ClothingCategory? category;
  final VoidCallback onAdd;

  const _EmptyState({this.category, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final label = category?.label ?? 'Gardırobun';

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
              child: const Icon(Icons.checkroom_outlined,
                  color: AppTheme.mediumGray, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              '$label boş',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'İlk kıyafetini ekleyerek\nstil analizini başlat.',
              textAlign: TextAlign.center,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Kıyafet Ekle'),
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
