enum ClothingCategory { top, bottom, outerwear, shoes, accessory }

enum ClothingSubcategory {
  // Top
  tShirt, shirt, polo, sweater, hoodie, tank, blouse,
  // Bottom
  jeans, chinos, trousers, shorts, sweatpants, skirt,
  // Outerwear
  jacket, coat, blazer, zipHoodie, vest,
  // Shoes
  sneakers, boots, loafers, dressShoes, sandals,
  // Accessory
  belt, hat, scarf, watch, bag,
}

enum FitType { slim, regular, relaxed, oversized }

enum LengthType { cropped, regular, long }

enum FabricType { cotton, linen, wool, polyester, denim, leather, knit, silk, syntheticBlend }

enum FabricWeight { lightweight, medium, heavy }

enum PatternType { solid, stripes, plaid, geometric, abstract, logo, floral, camo }

enum PatternScale { small, medium, large }

enum ColorFamily { warm, cool, neutral, earth, achromatic }

enum ColorSaturation { muted, medium, vibrant }

enum ColorValue { light, medium, dark }

enum OccasionTag { casual, work, formal, sport, outdoor, date }

enum SeasonTag { spring, summer, autumn, winter }

enum ClothingCondition { excellent, good, fair, worn }

// ── Extensions ────────────────────────────────────────────────────

extension ClothingCategoryX on ClothingCategory {
  String get label => switch (this) {
        ClothingCategory.top => 'Üst',
        ClothingCategory.bottom => 'Alt',
        ClothingCategory.outerwear => 'Dış Giyim',
        ClothingCategory.shoes => 'Ayakkabı',
        ClothingCategory.accessory => 'Aksesuar',
      };

  List<ClothingSubcategory> get subcategories => switch (this) {
        ClothingCategory.top => [
            ClothingSubcategory.tShirt,
            ClothingSubcategory.shirt,
            ClothingSubcategory.polo,
            ClothingSubcategory.sweater,
            ClothingSubcategory.hoodie,
            ClothingSubcategory.tank,
            ClothingSubcategory.blouse,
          ],
        ClothingCategory.bottom => [
            ClothingSubcategory.jeans,
            ClothingSubcategory.chinos,
            ClothingSubcategory.trousers,
            ClothingSubcategory.shorts,
            ClothingSubcategory.sweatpants,
            ClothingSubcategory.skirt,
          ],
        ClothingCategory.outerwear => [
            ClothingSubcategory.jacket,
            ClothingSubcategory.coat,
            ClothingSubcategory.blazer,
            ClothingSubcategory.zipHoodie,
            ClothingSubcategory.vest,
          ],
        ClothingCategory.shoes => [
            ClothingSubcategory.sneakers,
            ClothingSubcategory.boots,
            ClothingSubcategory.loafers,
            ClothingSubcategory.dressShoes,
            ClothingSubcategory.sandals,
          ],
        ClothingCategory.accessory => [
            ClothingSubcategory.belt,
            ClothingSubcategory.hat,
            ClothingSubcategory.scarf,
            ClothingSubcategory.watch,
            ClothingSubcategory.bag,
          ],
      };
}

extension ClothingSubcategoryX on ClothingSubcategory {
  String get label => switch (this) {
        ClothingSubcategory.tShirt => 'T-Shirt',
        ClothingSubcategory.shirt => 'Gömlek',
        ClothingSubcategory.polo => 'Polo',
        ClothingSubcategory.sweater => 'Kazak',
        ClothingSubcategory.hoodie => 'Hoodie',
        ClothingSubcategory.tank => 'Atlet',
        ClothingSubcategory.blouse => 'Bluz',
        ClothingSubcategory.jeans => 'Jean',
        ClothingSubcategory.chinos => 'Chino',
        ClothingSubcategory.trousers => 'Pantolon',
        ClothingSubcategory.shorts => 'Şort',
        ClothingSubcategory.sweatpants => 'Eşofman Altı',
        ClothingSubcategory.skirt => 'Etek',
        ClothingSubcategory.jacket => 'Ceket',
        ClothingSubcategory.coat => 'Palto',
        ClothingSubcategory.blazer => 'Blazer',
        ClothingSubcategory.zipHoodie => 'Fermuarlı Hoodie',
        ClothingSubcategory.vest => 'Yelek',
        ClothingSubcategory.sneakers => 'Sneaker',
        ClothingSubcategory.boots => 'Bot',
        ClothingSubcategory.loafers => 'Loafer',
        ClothingSubcategory.dressShoes => 'Klasik Ayakkabı',
        ClothingSubcategory.sandals => 'Sandalet',
        ClothingSubcategory.belt => 'Kemer',
        ClothingSubcategory.hat => 'Şapka',
        ClothingSubcategory.scarf => 'Eşarp/Atkı',
        ClothingSubcategory.watch => 'Saat',
        ClothingSubcategory.bag => 'Çanta',
      };
}

extension FitTypeX on FitType {
  String get label => switch (this) {
        FitType.slim => 'Slim',
        FitType.regular => 'Regular',
        FitType.relaxed => 'Relaxed',
        FitType.oversized => 'Oversized',
      };
}

extension FabricTypeX on FabricType {
  String get label => switch (this) {
        FabricType.cotton => 'Pamuk',
        FabricType.linen => 'Keten',
        FabricType.wool => 'Yün',
        FabricType.polyester => 'Polyester',
        FabricType.denim => 'Denim',
        FabricType.leather => 'Deri',
        FabricType.knit => 'Örme',
        FabricType.silk => 'İpek',
        FabricType.syntheticBlend => 'Sentetik Karışım',
      };
}

extension FabricWeightX on FabricWeight {
  String get label => switch (this) {
        FabricWeight.lightweight => 'Hafif',
        FabricWeight.medium => 'Orta',
        FabricWeight.heavy => 'Ağır',
      };
}

extension PatternTypeX on PatternType {
  String get label => switch (this) {
        PatternType.solid => 'Düz',
        PatternType.stripes => 'Çizgili',
        PatternType.plaid => 'Ekose',
        PatternType.geometric => 'Geometrik',
        PatternType.abstract => 'Soyut',
        PatternType.logo => 'Logo/Baskı',
        PatternType.floral => 'Çiçekli',
        PatternType.camo => 'Kamuflaj',
      };
}

extension OccasionTagX on OccasionTag {
  String get label => switch (this) {
        OccasionTag.casual => 'Günlük',
        OccasionTag.work => 'İş',
        OccasionTag.formal => 'Resmi',
        OccasionTag.sport => 'Spor',
        OccasionTag.outdoor => 'Outdoor',
        OccasionTag.date => 'Buluşma',
      };
}

extension SeasonTagX on SeasonTag {
  String get label => switch (this) {
        SeasonTag.spring => 'İlkbahar',
        SeasonTag.summer => 'Yaz',
        SeasonTag.autumn => 'Sonbahar',
        SeasonTag.winter => 'Kış',
      };
}

extension ColorFamilyX on ColorFamily {
  String get label => switch (this) {
        ColorFamily.warm => 'Sıcak',
        ColorFamily.cool => 'Soğuk',
        ColorFamily.neutral => 'Nötr',
        ColorFamily.earth => 'Toprak',
        ColorFamily.achromatic => 'Akromatik',
      };
}
