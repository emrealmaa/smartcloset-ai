import 'package:uuid/uuid.dart';

class ClothingModel {
  final String id;
  final String name;
  final String? brand;
  final double? price;
  final String category;
  final String? color;
  final String? season;
  final String? imagePath;
  final String? weatherTag;
  final int createdAt;

  const ClothingModel({
    required this.id,
    required this.name,
    this.brand,
    this.price,
    required this.category,
    this.color,
    this.season,
    this.imagePath,
    this.weatherTag,
    required this.createdAt,
  });

  factory ClothingModel.create({
    required String name,
    required String category,
    String? brand,
    double? price,
    String? color,
    String? season,
    String? imagePath,
    String? weatherTag,
  }) {
    return ClothingModel(
      id: const Uuid().v4(),
      name: name,
      brand: brand,
      price: price,
      category: category,
      color: color,
      season: season,
      imagePath: imagePath,
      weatherTag: weatherTag,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'price': price,
        'category': category,
        'color': color,
        'season': season,
        'image_path': imagePath,
        'weather_tag': weatherTag,
        'created_at': createdAt,
      };

  factory ClothingModel.fromMap(Map<String, dynamic> map) => ClothingModel(
        id: map['id'] as String,
        name: map['name'] as String,
        brand: map['brand'] as String?,
        price: map['price'] as double?,
        category: map['category'] as String,
        color: map['color'] as String?,
        season: map['season'] as String?,
        imagePath: map['image_path'] as String?,
        weatherTag: map['weather_tag'] as String?,
        createdAt: map['created_at'] as int,
      );

  static const List<String> categories = [
    'Üst',
    'Alt',
    'Dış Giyim',
    'Ayakkabı',
    'Aksesuar',
  ];

  static const List<String> seasons = [
    'İlkbahar',
    'Yaz',
    'Sonbahar',
    'Kış',
    'Tüm Sezonlar',
  ];

  static const List<String> colors = [
    'Siyah',
    'Beyaz',
    'Gri',
    'Lacivert',
    'Mavi',
    'Kırmızı',
    'Yeşil',
    'Sarı',
    'Turuncu',
    'Mor',
    'Pembe',
    'Kahverengi',
    'Bej',
    'Haki',
    'Diğer',
  ];
}
