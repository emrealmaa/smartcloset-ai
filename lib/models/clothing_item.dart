import 'dart:convert';
import '../core/enums/clothing_enums.dart';

class ClothingItem {
  final int? id;
  final String userId;

  // Kimlik
  final String name;
  final String? brand;
  final ClothingCategory category;
  final ClothingSubcategory subcategory;

  // Renk
  final String primaryColorHex;
  final String primaryColorName;
  final ColorFamily colorFamily;
  final ColorSaturation colorSaturation;
  final ColorValue colorValue;
  final String? secondaryColorHex;

  // Kalıp & Kumaş
  final FitType fitType;
  final LengthType? lengthType;
  final FabricType fabricType;
  final FabricWeight fabricWeight;
  final PatternType patternType;
  final PatternScale? patternScale;

  // Etiketler
  final List<OccasionTag> occasionTags;
  final List<SeasonTag> seasonTags;

  // Meta
  final ClothingCondition condition;
  final String? imagePath;
  final String? notes;
  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ClothingItem({
    this.id,
    required this.userId,
    required this.name,
    this.brand,
    required this.category,
    required this.subcategory,
    required this.primaryColorHex,
    required this.primaryColorName,
    required this.colorFamily,
    required this.colorSaturation,
    required this.colorValue,
    this.secondaryColorHex,
    required this.fitType,
    this.lengthType,
    required this.fabricType,
    required this.fabricWeight,
    required this.patternType,
    this.patternScale,
    required this.occasionTags,
    required this.seasonTags,
    this.condition = ClothingCondition.good,
    this.imagePath,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'brand': brand,
      'category': category.name,
      'subcategory': subcategory.name,
      'primary_color_hex': primaryColorHex,
      'primary_color_name': primaryColorName,
      'color_family': colorFamily.name,
      'color_saturation': colorSaturation.name,
      'color_value': colorValue.name,
      'secondary_color_hex': secondaryColorHex,
      'fit_type': fitType.name,
      'length_type': lengthType?.name,
      'fabric_type': fabricType.name,
      'fabric_weight': fabricWeight.name,
      'pattern_type': patternType.name,
      'pattern_scale': patternScale?.name,
      'occasion_tags':
          jsonEncode(occasionTags.map((e) => e.name).toList()),
      'season_tags': jsonEncode(seasonTags.map((e) => e.name).toList()),
      'condition': condition.name,
      'image_path': imagePath,
      'notes': notes,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    List<T> _decodeList<T>(String json, T Function(String) fromName) {
      final raw = jsonDecode(json) as List;
      return raw.map((e) => fromName(e as String)).toList();
    }

    return ClothingItem(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      category:
          ClothingCategory.values.byName(map['category'] as String),
      subcategory:
          ClothingSubcategory.values.byName(map['subcategory'] as String),
      primaryColorHex: map['primary_color_hex'] as String,
      primaryColorName: map['primary_color_name'] as String,
      colorFamily:
          ColorFamily.values.byName(map['color_family'] as String),
      colorSaturation:
          ColorSaturation.values.byName(map['color_saturation'] as String),
      colorValue: ColorValue.values.byName(map['color_value'] as String),
      secondaryColorHex: map['secondary_color_hex'] as String?,
      fitType: FitType.values.byName(map['fit_type'] as String),
      lengthType: map['length_type'] != null
          ? LengthType.values.byName(map['length_type'] as String)
          : null,
      fabricType:
          FabricType.values.byName(map['fabric_type'] as String),
      fabricWeight:
          FabricWeight.values.byName(map['fabric_weight'] as String),
      patternType:
          PatternType.values.byName(map['pattern_type'] as String),
      patternScale: map['pattern_scale'] != null
          ? PatternScale.values.byName(map['pattern_scale'] as String)
          : null,
      occasionTags: _decodeList<OccasionTag>(
        map['occasion_tags'] as String? ?? '[]',
        OccasionTag.values.byName,
      ),
      seasonTags: _decodeList<SeasonTag>(
        map['season_tags'] as String? ?? '[]',
        SeasonTag.values.byName,
      ),
      condition: map['condition'] != null
          ? ClothingCondition.values.byName(map['condition'] as String)
          : ClothingCondition.good,
      imagePath: map['image_path'] as String?,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  ClothingItem copyWith({
    int? id,
    String? userId,
    String? name,
    String? brand,
    ClothingCategory? category,
    ClothingSubcategory? subcategory,
    String? primaryColorHex,
    String? primaryColorName,
    ColorFamily? colorFamily,
    ColorSaturation? colorSaturation,
    ColorValue? colorValue,
    String? secondaryColorHex,
    FitType? fitType,
    LengthType? lengthType,
    FabricType? fabricType,
    FabricWeight? fabricWeight,
    PatternType? patternType,
    PatternScale? patternScale,
    List<OccasionTag>? occasionTags,
    List<SeasonTag>? seasonTags,
    ClothingCondition? condition,
    String? imagePath,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      primaryColorName: primaryColorName ?? this.primaryColorName,
      colorFamily: colorFamily ?? this.colorFamily,
      colorSaturation: colorSaturation ?? this.colorSaturation,
      colorValue: colorValue ?? this.colorValue,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      fitType: fitType ?? this.fitType,
      lengthType: lengthType ?? this.lengthType,
      fabricType: fabricType ?? this.fabricType,
      fabricWeight: fabricWeight ?? this.fabricWeight,
      patternType: patternType ?? this.patternType,
      patternScale: patternScale ?? this.patternScale,
      occasionTags: occasionTags ?? this.occasionTags,
      seasonTags: seasonTags ?? this.seasonTags,
      condition: condition ?? this.condition,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
