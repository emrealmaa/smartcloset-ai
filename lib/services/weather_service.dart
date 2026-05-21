import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// ── Providers ─────────────────────────────────────────────────────
final weatherServiceProvider =
    Provider<WeatherService>((ref) => WeatherService());

final weatherProvider = FutureProvider<WeatherData?>((ref) async {
  return ref.watch(weatherServiceProvider).getWeather();
});

// ── Weather Model ─────────────────────────────────────────────────
class WeatherData {
  final String city;
  final double tempC;
  final String condition;
  final String conditionCode; // rain, cloud, sunny vs.
  final int humidity;
  final double windKph;
  final bool isDay;

  const WeatherData({
    required this.city,
    required this.tempC,
    required this.condition,
    required this.conditionCode,
    required this.humidity,
    required this.windKph,
    required this.isDay,
  });

  // Kombin önerisi için hava kategorisi
  String get weatherTag {
    if (tempC < 5) return 'very_cold';
    if (tempC < 12) return 'cold';
    if (tempC < 20) return 'mild';
    if (tempC < 28) return 'warm';
    return 'hot';
  }

  String get weatherTagLabel {
    switch (weatherTag) {
      case 'very_cold':
        return 'Çok Soğuk';
      case 'cold':
        return 'Soğuk';
      case 'mild':
        return 'Serin';
      case 'warm':
        return 'Ilık';
      case 'hot':
        return 'Sıcak';
      default:
        return '';
    }
  }

  String get outfitSuggestion {
    switch (weatherTag) {
      case 'very_cold':
        return 'Mont, kalın kazak, bot önerilir';
      case 'cold':
        return 'Kaban veya trençkot, hırka önerilir';
      case 'mild':
        return 'Hafif ceket veya sweatshirt ideal';
      case 'warm':
        return 'Tişört ve ince pantolon yeterli';
      case 'hot':
        return 'Yazlık, nefes alan kumaşlar önerilir';
      default:
        return '';
    }
  }

  String get weatherEmoji {
    final code = conditionCode.toLowerCase();
    if (code.contains('sunny') || code.contains('clear')) {
      return isDay ? '☀️' : '🌙';
    }
    if (code.contains('rain') || code.contains('drizzle')) return '🌧️';
    if (code.contains('snow') || code.contains('blizzard')) return '❄️';
    if (code.contains('thunder') || code.contains('storm')) return '⛈️';
    if (code.contains('cloud') || code.contains('overcast')) return '☁️';
    if (code.contains('mist') || code.contains('fog')) return '🌫️';
    return '🌤️';
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final condition = current['condition'] as Map<String, dynamic>;

    return WeatherData(
      city: location['name'] as String,
      tempC: (current['temp_c'] as num).toDouble(),
      condition: condition['text'] as String,
      conditionCode: condition['text'] as String,
      humidity: current['humidity'] as int,
      windKph: (current['wind_kph'] as num).toDouble(),
      isDay: current['is_day'] == 1,
    );
  }
}

// ── Weather Service ───────────────────────────────────────────────
class WeatherService {
  // ⚠️ Buraya kendi API key'ini yaz:
  static const String _apiKey = '8d5072644447447e866144248260205';
  static const String _baseUrl = 'https://api.weatherapi.com/v1/current.json';

  Future<WeatherData?> getWeather() async {
    try {
      final position = await _getLocation();
      if (position == null) return null;

      final url = Uri.parse(
        '$_baseUrl?key=$_apiKey&q=${position.latitude},${position.longitude}&lang=tr',
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Position?> _getLocation() async {
    try {
      // Konum servisi açık mı?
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // İzin durumunu kontrol et
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      // Konumu al (düşük hassasiyet = daha hızlı)
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 8));
    } catch (e) {
      return null;
    }
  }
}
