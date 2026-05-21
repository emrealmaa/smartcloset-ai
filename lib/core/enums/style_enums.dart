enum StyleGoal {
  minimal,
  smartCasual,
  casual,
  streetwear,
  formal,
  sporty,
}

extension StyleGoalX on StyleGoal {
  String get label => switch (this) {
        StyleGoal.minimal => 'Minimalist',
        StyleGoal.smartCasual => 'Smart Casual',
        StyleGoal.casual => 'Casual / Günlük',
        StyleGoal.streetwear => 'Streetwear',
        StyleGoal.formal => 'Formal / Klasik',
        StyleGoal.sporty => 'Sporty / Aktif',
      };

  String get description => switch (this) {
        StyleGoal.minimal =>
          'Az parça, yüksek kalite. Nötr renkler, temiz kesimler.',
        StyleGoal.smartCasual =>
          'İş ve günlük arası. Blazer + chino gibi kombinler.',
        StyleGoal.casual =>
          'Rahat, gündelik. T-shirt, jeans, sneaker ağırlıklı.',
        StyleGoal.streetwear =>
          'Oversize, grafik baskılar, hoodie, sneaker kültürü.',
        StyleGoal.formal =>
          'Takım elbise, gömlek, klasik ayakkabı. Kurumsal görünüm.',
        StyleGoal.sporty =>
          'Performans kumaşları, eşofman, spor ayakkabı kombinleri.',
      };

  String get emoji => switch (this) {
        StyleGoal.minimal => '◻️',
        StyleGoal.smartCasual => '🧥',
        StyleGoal.casual => '👕',
        StyleGoal.streetwear => '🧢',
        StyleGoal.formal => '👔',
        StyleGoal.sporty => '🏃',
      };
}
