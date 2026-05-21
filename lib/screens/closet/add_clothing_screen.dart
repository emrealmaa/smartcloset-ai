import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/clothing_model.dart';
import '../../providers/clothing_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class AddClothingScreen extends ConsumerStatefulWidget {
  const AddClothingScreen({super.key});

  @override
  ConsumerState<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends ConsumerState<AddClothingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();

  String? _imagePath;
  String _selectedCategory = ClothingModel.categories.first;
  String _selectedColor = ClothingModel.colors.first;
  String _selectedSeason = ClothingModel.seasons.last;
  bool _isLoading = false;

  final _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _imagePath = picked.path);
      }
    } catch (e) {
      if (mounted) {
        showScSnackbar(context, 'Fotoğraf seçilemedi.', isError: true);
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Fotoğraf Seç',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      showScSnackbar(context, 'Lütfen bir fotoğraf ekle.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final clothing = ClothingModel.create(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      price: _priceController.text.isEmpty
          ? null
          : double.tryParse(_priceController.text.replaceAll(',', '.')),
      color: _selectedColor,
      season: _selectedSeason,
      imagePath: _imagePath,
    );

    await ref.read(clothingActionsProvider).addClothing(clothing);

    if (!mounted) return;
    setState(() => _isLoading = false);

    showScSnackbar(context, '${clothing.name} gardıroba eklendi!',
        isSuccess: true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: AppTheme.textSecondary),
        ),
        title:
            Text('Kıyafet Ekle', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _isLoading ? null : _save,
              child: Text(
                'Kaydet',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neonGreen,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),

            // ── Fotoğraf Alanı ────────────────────────────────
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 260,
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _imagePath != null
                        ? AppTheme.neonGreen.withOpacity(0.4)
                        : AppTheme.borderColor,
                    width: 1.5,
                  ),
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.neonGreen.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppTheme.neonGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Fotoğraf Ekle',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kamera veya galeriden seç',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            if (_imagePath != null) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _showImageSourceSheet,
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Fotoğrafı Değiştir'),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── İsim ─────────────────────────────────────────
            _label('Kıyafet Adı *'),
            ScTextField(
              hint: 'Örn: Oversize Beyaz Tişört',
              controller: _nameController,
              prefixIcon: Icons.checkroom_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'İsim gerekli' : null,
            ),
            const SizedBox(height: 16),

            // ── Kategori ──────────────────────────────────────
            _label('Kategori *'),
            _DropdownField(
              value: _selectedCategory,
              items: ClothingModel.categories,
              onChanged: (v) => setState(() => _selectedCategory = v!),
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 16),

            // ── Marka ─────────────────────────────────────────
            _label('Marka'),
            ScTextField(
              hint: 'Örn: Zara, H&M, Koton...',
              controller: _brandController,
              prefixIcon: Icons.local_offer_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // ── Fiyat ─────────────────────────────────────────
            _label('Fiyat (₺)'),
            ScTextField(
              hint: 'Örn: 299',
              controller: _priceController,
              prefixIcon: Icons.attach_money,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),

            // ── Renk ──────────────────────────────────────────
            _label('Renk'),
            _ColorPicker(
              selected: _selectedColor,
              onChanged: (v) => setState(() => _selectedColor = v),
            ),
            const SizedBox(height: 16),

            // ── Sezon ─────────────────────────────────────────
            _label('Sezon'),
            _DropdownField(
              value: _selectedSeason,
              items: ClothingModel.seasons,
              onChanged: (v) => setState(() => _selectedSeason = v!),
              icon: Icons.wb_sunny_outlined,
            ),
            const SizedBox(height: 32),

            // ── Kaydet ────────────────────────────────────────
            ScButton(
              label: 'Gardıroba Ekle',
              onPressed: _save,
              isLoading: _isLoading,
              icon: Icons.add,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Dropdown ──────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData icon;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppTheme.cardSurface,
          icon: const Icon(Icons.expand_more, color: AppTheme.textMuted),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Row(
                      children: [
                        Icon(icon, color: AppTheme.textMuted, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: GoogleFonts.spaceGrotesk(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Renk Seçici ──────────────────────────────────────────────────
class _ColorPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ColorPicker({required this.selected, required this.onChanged});

  static const Map<String, Color> _colorMap = {
    'Siyah': Color(0xFF1A1A1A),
    'Beyaz': Color(0xFFF5F5F5),
    'Gri': Color(0xFF9E9E9E),
    'Lacivert': Color(0xFF1A237E),
    'Mavi': Color(0xFF2196F3),
    'Kırmızı': Color(0xFFF44336),
    'Yeşil': Color(0xFF4CAF50),
    'Sarı': Color(0xFFFFEB3B),
    'Turuncu': Color(0xFFFF9800),
    'Mor': Color(0xFF9C27B0),
    'Pembe': Color(0xFFE91E63),
    'Kahverengi': Color(0xFF795548),
    'Bej': Color(0xFFD7CCC8),
    'Haki': Color(0xFF8D6E63),
    'Diğer': Color(0xFF607D8B),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: ClothingModel.colors.map((color) {
          final isSelected = selected == color;
          return GestureDetector(
            onTap: () => onChanged(color),
            child: Tooltip(
              message: color,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _colorMap[color] ?? AppTheme.borderColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.neonGreen : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.neonGreen.withOpacity(0.4),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check,
                        color: AppTheme.neonGreen, size: 16)
                    : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Kaynak Seçim Kutusu ───────────────────────────────────────────
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.neonGreen, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
