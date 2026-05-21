class WardrobeGap {
  final String subcategoryLabel;  // "Nötr Pantolon / Chino"
  final String colorSuggestion;   // "Lacivert veya bej"
  final int priority;             // 1=kritik, 2=önemli, 3=opsiyonel
  final String reason;            // "Gardırobunda hiç nötr alt yok..."
  final String tip;               // kısa aksiyon önerisi

  const WardrobeGap({
    required this.subcategoryLabel,
    required this.colorSuggestion,
    required this.priority,
    required this.reason,
    required this.tip,
  });
}
