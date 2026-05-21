import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/enums/clothing_enums.dart';
import '../../core/utils/color_utils.dart';
import '../../providers/clothing_provider.dart';
import '../../theme/app_theme.dart';

class AddClothingScreen extends ConsumerStatefulWidget {
  const AddClothingScreen({super.key});

  @override
  ConsumerState<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends ConsumerState<AddClothingScreen> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _notesCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (file != null) {
      ref.read(addClothingProvider.notifier).setImagePath(file.path);
    }
  }

  Future<void> _save() async {
    final notifier = ref.read(addClothingProvider.notifier);
    notifier.setName(_nameCtrl.text);
    notifier.setBrand(_brandCtrl.text.isEmpty ? null : _brandCtrl.text);
    notifier.setNotes(_notesCtrl.text.isEmpty ? null : _notesCtrl.text);

    final ok = await notifier.save(() {
      ref.invalidate(clothingListProvider);
      ref.invalidate(clothingCountProvider);
    });

    if (ok && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addClothingProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('Kıyafet Ekle'),
        backgroundColor: AppTheme.cream,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: state.isValid && !state.isSaving ? _save : null,
              child: Text(
                'Kaydet',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: state.isValid
                      ? AppTheme.neonGreen
                      : AppTheme.mediumGray,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Fotoğraf ─────────────────────────────────────────
          _PhotoPicker(
            imagePath: state.imagePath,
            onTap: _pickImage,
          ),
          const SizedBox(height: 24),

          // ── İsim & Marka ─────────────────────────────────────
          _label('Kıyafet Adı *'),
          const SizedBox(height: 8),
          _input(
            controller: _nameCtrl,
            hint: 'ör. Lacivert Oxford Gömlek',
            onChanged: (v) => ref.read(addClothingProvider.notifier).setName(v),
          ),
          const SizedBox(height: 14),
          _label('Marka (opsiyonel)'),
          const SizedBox(height: 8),
          _input(controller: _brandCtrl, hint: 'ör. Zara, H&M, Mango'),

          const SizedBox(height: 24),

          // ── Kategori ─────────────────────────────────────────
          _label('Kategori *'),
          const SizedBox(height: 10),
          _CategorySelector(
            selected: state.category,
            onSelect: (c) =>
                ref.read(addClothingProvider.notifier).setCategory(c),
          ),

          // ── Alt Kategori ─────────────────────────────────────
          if (state.category != null) ...[
            const SizedBox(height: 16),
            _label('Alt Kategori *'),
            const SizedBox(height: 10),
            _ChipWrap<ClothingSubcategory>(
              values: state.category!.subcategories,
              selected: state.subcategory,
              labelOf: (e) => e.label,
              onSelect: (v) =>
                  ref.read(addClothingProvider.notifier).setSubcategory(v),
            ),
          ],

          const SizedBox(height: 24),

          // ── Renk ─────────────────────────────────────────────
          _label('Renk *'),
          const SizedBox(height: 10),
          _ColorPicker(
            selectedHex: state.primaryColorHex,
            onSelect: (hex, name) =>
                ref.read(addClothingProvider.notifier).setColor(hex, name),
          ),

          const SizedBox(height: 24),

          // ── Kalıp ────────────────────────────────────────────
          _label('Kalıp (Fit)'),
          const SizedBox(height: 10),
          _ChipWrap<FitType>(
            values: FitType.values,
            selected: state.fitType,
            labelOf: (e) => e.label,
            onSelect: (v) =>
                ref.read(addClothingProvider.notifier).setFitType(v),
          ),

          const SizedBox(height: 20),

          // ── Kumaş ────────────────────────────────────────────
          _label('Kumaş'),
          const SizedBox(height: 10),
          _ChipWrap<FabricType>(
            values: FabricType.values,
            selected: state.fabricType,
            labelOf: (e) => e.label,
            onSelect: (v) =>
                ref.read(addClothingProvider.notifier).setFabricType(v),
          ),
          const SizedBox(height: 14),
          _SegRow<FabricWeight>(
            label: 'Kumaş Ağırlığı',
            values: FabricWeight.values,
            selected: state.fabricWeight,
            labelOf: (e) => e.label,
            onSelect: (v) =>
                ref.read(addClothingProvider.notifier).setFabricWeight(v),
          ),

          const SizedBox(height: 20),

          // ── Desen ────────────────────────────────────────────
          _label('Desen'),
          const SizedBox(height: 10),
          _ChipWrap<PatternType>(
            values: PatternType.values,
            selected: state.patternType,
            labelOf: (e) => e.label,
            onSelect: (v) =>
                ref.read(addClothingProvider.notifier).setPatternType(v),
          ),
          if (state.patternType != PatternType.solid) ...[
            const SizedBox(height: 10),
            _SegRow<PatternScale>(
              label: 'Desen Ölçeği',
              values: PatternScale.values,
              selected: state.patternScale,
              labelOf: (e) => switch (e) {
                PatternScale.small => 'Küçük',
                PatternScale.medium => 'Orta',
                PatternScale.large => 'Büyük',
              },
              onSelect: (v) =>
                  ref.read(addClothingProvider.notifier).setPatternScale(v),
            ),
          ],

          const SizedBox(height: 24),

          // ── Ortam Etiketleri ─────────────────────────────────
          _label('Kullanım Ortamı'),
          const SizedBox(height: 10),
          _MultiChipWrap<OccasionTag>(
            values: OccasionTag.values,
            selected: state.occasionTags,
            labelOf: (e) => e.label,
            onToggle: (v) =>
                ref.read(addClothingProvider.notifier).toggleOccasionTag(v),
          ),

          const SizedBox(height: 20),

          // ── Mevsim ───────────────────────────────────────────
          _label('Mevsim'),
          const SizedBox(height: 10),
          _MultiChipWrap<SeasonTag>(
            values: SeasonTag.values,
            selected: state.seasonTags,
            labelOf: (e) => e.label,
            onToggle: (v) =>
                ref.read(addClothingProvider.notifier).toggleSeasonTag(v),
          ),

          const SizedBox(height: 24),

          // ── Notlar ───────────────────────────────────────────
          _label('Notlar (opsiyonel)'),
          const SizedBox(height: 8),
          _input(
            controller: _notesCtrl,
            hint: 'ör. Kuru temizleme gerektirir',
            maxLines: 2,
          ),

          const SizedBox(height: 32),

          // ── Hata ─────────────────────────────────────────────
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.error!,
                style: GoogleFonts.spaceGrotesk(
                    color: AppTheme.errorRed, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),

          // ── Kaydet butonu ─────────────────────────────────────
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: state.isValid && !state.isSaving ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.charcoal,
                disabledBackgroundColor: AppTheme.softGray,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: state.isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Gardıroba Ekle',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.charcoal),
      );

  Widget _input({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.spaceGrotesk(fontSize: 15, color: AppTheme.charcoal),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppTheme.warmWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.softGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.softGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.neonGreen, width: 1.5),
        ),
      ),
    );
  }
}

// ── Photo Picker ──────────────────────────────────────────────────
class _PhotoPicker extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _PhotoPicker({this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: imagePath != null ? AppTheme.neonGreen : AppTheme.softGray,
            style: imagePath != null ? BorderStyle.solid : BorderStyle.solid,
            width: imagePath != null ? 2 : 1,
          ),
        ),
        child: imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(imagePath!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder()),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_photo_alternate_outlined,
            color: AppTheme.mediumGray, size: 32),
        const SizedBox(height: 8),
        Text(
          'Fotoğraf Ekle (opsiyonel)',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 13, color: AppTheme.mediumGray),
        ),
      ],
    );
  }
}

// ── Category Selector ─────────────────────────────────────────────
class _CategorySelector extends StatelessWidget {
  final ClothingCategory? selected;
  final void Function(ClothingCategory) onSelect;

  const _CategorySelector({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ClothingCategory.values.map((cat) {
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.charcoal : AppTheme.warmWhite,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.charcoal
                        : AppTheme.softGray,
                  ),
                ),
                child: Text(
                  cat.label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.charcoal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Color Picker ──────────────────────────────────────────────────
class _ColorPicker extends StatelessWidget {
  final String? selectedHex;
  final void Function(String hex, String name) onSelect;

  const _ColorPicker({this.selectedHex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seçili renk önizleme
        if (selectedHex != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ColorUtils.fromHex(selectedHex!),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.softGray),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ColorUtils.presetColors
                      .firstWhere(
                        (c) =>
                            c.hex.toLowerCase() ==
                            selectedHex!.toLowerCase(),
                        orElse: () =>
                            (hex: selectedHex!, name: selectedHex!),
                      )
                      .name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.charcoal,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ${ColorUtils.computeFamily(selectedHex!).label}',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),

        // Renk ızgarası
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ColorUtils.presetColors.map((c) {
            final isSelected =
                c.hex.toLowerCase() == (selectedHex?.toLowerCase() ?? '');
            return GestureDetector(
              onTap: () => onSelect(c.hex, c.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ColorUtils.fromHex(c.hex),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.charcoal
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Chip Wrap (single select) ─────────────────────────────────────
class _ChipWrap<T> extends StatelessWidget {
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;

  const _ChipWrap({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final isSel = v == selected;
        return GestureDetector(
          onTap: () => onSelect(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel ? AppTheme.charcoal : AppTheme.warmWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: isSel ? AppTheme.charcoal : AppTheme.softGray),
            ),
            child: Text(
              labelOf(v),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSel ? Colors.white : AppTheme.charcoal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Multi Chip Wrap ───────────────────────────────────────────────
class _MultiChipWrap<T> extends StatelessWidget {
  final List<T> values;
  final List<T> selected;
  final String Function(T) labelOf;
  final void Function(T) onToggle;

  const _MultiChipWrap({
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final isSel = selected.contains(v);
        return GestureDetector(
          onTap: () => onToggle(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel
                  ? AppTheme.neonGreen.withOpacity(0.12)
                  : AppTheme.warmWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSel ? AppTheme.neonGreen : AppTheme.softGray,
                width: isSel ? 1.5 : 1,
              ),
            ),
            child: Text(
              labelOf(v),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSel ? AppTheme.neonGreen : AppTheme.charcoal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Segment Row (üçlü toggle) ─────────────────────────────────────
class _SegRow<T> extends StatelessWidget {
  final String label;
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final void Function(T) onSelect;

  const _SegRow({
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: Row(
            children: values.map((v) {
              final isSel = v == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.charcoal : AppTheme.warmWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isSel
                              ? AppTheme.charcoal
                              : AppTheme.softGray),
                    ),
                    child: Text(
                      labelOf(v),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : AppTheme.charcoal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
