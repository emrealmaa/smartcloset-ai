import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/weather_service.dart';
import '../../theme/app_theme.dart';

class WeatherWidget extends ConsumerWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    return weatherAsync.when(
      loading: () => _WeatherSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (weather) {
        if (weather == null) return const SizedBox.shrink();
        return _WeatherCard(weather: weather);
      },
    );
  }
}

// ── Asıl Kart ─────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final WeatherData weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ── Emoji + Sıcaklık ──────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.weatherEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${weather.tempC.round()}°',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3, left: 2),
                    child: Text(
                      'C',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 16),

          // ── Dikey çizgi ───────────────────────────────────────
          Container(
            width: 1,
            height: 60,
            color: AppTheme.borderColor,
          ),

          const SizedBox(width: 16),

          // ── Şehir + Durum + Öneri ─────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.neonGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      weather.city,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Hava etiketi
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tagColor(weather.weatherTag).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        weather.weatherTagLabel,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _tagColor(weather.weatherTag),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  weather.condition,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                // Kombin önerisi
                Row(
                  children: [
                    const Icon(
                      Icons.checkroom_outlined,
                      color: AppTheme.neonGreen,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        weather.outfitSuggestion,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: AppTheme.neonGreen.withOpacity(0.8),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'very_cold':
        return const Color(0xFF60A5FA); // mavi
      case 'cold':
        return const Color(0xFF93C5FD);
      case 'mild':
        return const Color(0xFF86EFAC); // yeşil
      case 'warm':
        return const Color(0xFFFBBF24); // sarı
      case 'hot':
        return const Color(0xFFF87171); // kırmızı
      default:
        return AppTheme.neonGreen;
    }
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────
class _WeatherSkeleton extends StatefulWidget {
  @override
  State<_WeatherSkeleton> createState() => _WeatherSkeletonState();
}

class _WeatherSkeletonState extends State<_WeatherSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: double.infinity,
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor, width: 1),
        ),
        child: Row(
          children: [
            _box(50, 50, radius: 12),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _box(80, 12),
                const SizedBox(height: 8),
                _box(120, 10),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 6}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: AppTheme.borderColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}
