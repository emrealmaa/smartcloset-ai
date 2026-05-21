import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

// ── Provider ──────────────────────────────────────────────────────
final aiServiceProvider = Provider<AiService>((ref) => AiService());

// ── Models ────────────────────────────────────────────────────────
class AnalyzedPiece {
  final String name;
  final String category;
  final String color;
  final String colorHex;
  final String fit;
  final String searchKeyword;
  final List<StoreLink> storeLinks;

  const AnalyzedPiece({
    required this.name,
    required this.category,
    required this.color,
    required this.colorHex,
    required this.fit,
    required this.searchKeyword,
    required this.storeLinks,
  });

  factory AnalyzedPiece.fromJson(Map<String, dynamic> json) {
    final keyword = json['searchKeyword'] as String? ?? json['name'] as String;
    return AnalyzedPiece(
      name: json['name'] as String,
      category: json['category'] as String,
      color: json['color'] as String,
      colorHex: json['colorHex'] as String? ?? '#888888',
      fit: json['fit'] as String? ?? '',
      searchKeyword: keyword,
      storeLinks: _buildStoreLinks(keyword),
    );
  }

  static List<StoreLink> _buildStoreLinks(String keyword) {
    final encoded = Uri.encodeComponent(keyword);
    return [
      StoreLink(
          name: 'Trendyol',
          url: 'https://www.trendyol.com/sr?q=$encoded',
          color: 0xFFf27a1a),
      StoreLink(
          name: 'Zara',
          url: 'https://www.zara.com/tr/tr/search?searchTerm=$encoded',
          color: 0xFF1E1E1E),
      StoreLink(
          name: 'H&M',
          url: 'https://www2.hm.com/tr_tr/search-results.html?q=$encoded',
          color: 0xFFe50010),
      StoreLink(
          name: 'Mango',
          url: 'https://shop.mango.com/tr/arama?term=$encoded',
          color: 0xFF8B6914),
    ];
  }
}

class StoreLink {
  final String name;
  final String url;
  final int color;
  const StoreLink({required this.name, required this.url, required this.color});
}

class OutfitAnalysis {
  final String overallStyle;
  final String occasion;
  final List<AnalyzedPiece> pieces;

  const OutfitAnalysis({
    required this.overallStyle,
    required this.occasion,
    required this.pieces,
  });
}

// ── AI Service (Gemini) ───────────────────────────────────────────
class AiService {
  static const String _apiKey = 'AIzaSyDGaqJ_rhFWYaM_atZf5J2JU2-AyU4hq_Q';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Max boyut: 800px, max dosya: ~500KB
  static const int _maxDimension = 512;
  static const int _jpegQuality = 60;

  /// Görüntüyü küçült ve sıkıştır
  Uint8List _compressImage(Uint8List bytes) {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) return bytes;

      // Büyükse küçült
      img.Image resized = image;
      if (image.width > _maxDimension || image.height > _maxDimension) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? _maxDimension : null,
          height: image.height >= image.width ? _maxDimension : null,
        );
      }

      return Uint8List.fromList(img.encodeJpg(resized, quality: _jpegQuality));
    } catch (_) {
      return bytes;
    }
  }

  /// Unsplash URL'sinden kombin analizi
  Future<OutfitAnalysis?> analyzeOutfitFromUrl(String imageUrl) async {
    try {
      final imgResp = await http.get(Uri.parse(imageUrl)).timeout(
            const Duration(seconds: 15),
          );
      if (imgResp.statusCode != 200) return null;

      final compressed = _compressImage(imgResp.bodyBytes);
      final base64Image = base64Encode(compressed);

      return await _callGeminiVision(
        base64Image: base64Image,
        mediaType: 'image/jpeg',
      );
    } catch (e) {
      return null;
    }
  }

  /// Kullanıcının kendi fotoğrafından analiz
  Future<OutfitAnalysis?> analyzeOutfitFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final compressed = _compressImage(bytes);
      final base64Image = base64Encode(compressed);

      return await _callGeminiVision(
        base64Image: base64Image,
        mediaType: 'image/jpeg',
      );
    } catch (e) {
      return null;
    }
  }

  Future<OutfitAnalysis?> _callGeminiVision({
    required String base64Image,
    required String mediaType,
  }) async {
    const prompt = '''
Bu fotoğraftaki kıyafet kombinini analiz et.

Yanıtını SADECE JSON olarak ver, başka hiçbir metin olmadan, markdown backtick olmadan:
{
  "overallStyle": "kombinin genel stili (örn: Casual Sokak Stili)",
  "occasion": "hangi ortam için uygun (örn: Günlük, Ofis, Gece)",
  "pieces": [
    {
      "name": "parça adı Türkçe (örn: Oversize Tişört)",
      "category": "Üst / Alt / Dış Giyim / Ayakkabı / Aksesuar",
      "color": "renk adı Türkçe",
      "colorHex": "#RRGGBB hex kodu",
      "fit": "kesim bilgisi (örn: Slim Fit, Oversize)",
      "searchKeyword": "Trendyol araması için Türkçe anahtar kelime"
    }
  ]
}

Sadece görünür kıyafet parçalarını listele. Maksimum 5 parça.
''';

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {
                      'inline_data': {
                        'mime_type': mediaType,
                        'data': base64Image,
                      },
                    },
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.2,
                'maxOutputTokens': 1024,
              },
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        // Hata detayını logla
        print('Gemini error ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      if (content == null) return null;

      final parts = content['parts'] as List?;
      if (parts == null || parts.isEmpty) return null;

      final text = parts[0]['text'] as String? ?? '';

      // JSON'u temizle ve parse et
      final cleaned =
          text.replaceAll('```json', '').replaceAll('```', '').trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final pieces = (json['pieces'] as List)
          .map((p) => AnalyzedPiece.fromJson(p as Map<String, dynamic>))
          .toList();

      return OutfitAnalysis(
        overallStyle: json['overallStyle'] as String,
        occasion: json['occasion'] as String,
        pieces: pieces,
      );
    } catch (e) {
      print('Gemini call error: $e');
      return null;
    }
  }
}
