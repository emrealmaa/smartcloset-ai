import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/ai_service.dart';
import '../../theme/app_theme.dart';

// ── Unsplash Model ────────────────────────────────────────────────
class UnsplashPhoto {
  final String id;
  final String imageUrl;
  final String thumbUrl;
  final String photographerName;

  const UnsplashPhoto({
    required this.id,
    required this.imageUrl,
    required this.thumbUrl,
    required this.photographerName,
  });

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    final urls = json['urls'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;
    return UnsplashPhoto(
      id: json['id'] as String,
      imageUrl: urls['regular'] as String,
      thumbUrl: urls['small'] as String,
      photographerName: user['name'] as String,
    );
  }
}

// ── Infinite Feed State ───────────────────────────────────────────
class FeedState {
  final List<UnsplashPhoto> photos;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String query;

  const FeedState({
    this.photos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.query = 'fashion outfit style',
  });

  FeedState copyWith({
    List<UnsplashPhoto>? photos,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? query,
  }) =>
      FeedState(
        photos: photos ?? this.photos,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        query: query ?? this.query,
      );
}

class FeedNotifier extends StateNotifier<FeedState> {
  // ⚠️ Unsplash Access Key'ini buraya yaz:
  // https://unsplash.com/developers → "New Application" → ücretsiz
  static const String _accessKey = 'yMeNF1JLNsOpidBOonmwMTWFnwb4CGiiBTFbbkb8xE';
  static const int _perPage = 20;

  FeedNotifier() : super(const FeedState()) {
    loadInitial();
  }

  Future<void> loadInitial({String? query}) async {
    final q = query ?? state.query;
    state = FeedState(isLoading: true, query: q);
    final photos = await _fetchPhotos(q, 1);
    state = state.copyWith(
      photos: photos,
      isLoading: false,
      currentPage: 1,
      hasMore: photos.length >= _perPage,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;
    final more = await _fetchPhotos(state.query, nextPage);
    state = state.copyWith(
      photos: [...state.photos, ...more],
      isLoadingMore: false,
      currentPage: nextPage,
      hasMore: more.length >= _perPage,
    );
  }

  Future<List<UnsplashPhoto>> _fetchPhotos(String query, int page) async {
    // API key yoksa geniş statik havuzdan döndür
    if (_accessKey == 'YOUR_UNSPLASH_ACCESS_KEY') {
      return _staticPool(query, page);
    }

    try {
      final url = Uri.parse(
        'https://api.unsplash.com/search/photos'
        '?query=${Uri.encodeComponent("$query fashion outfit")}'
        '&per_page=$_perPage'
        '&page=$page'
        '&orientation=portrait'
        '&content_filter=high',
      );
      final response = await http.get(
        url,
        headers: {'Authorization': 'Client-ID $_accessKey'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return _staticPool(query, page);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;
      if (results.isEmpty) return [];
      return results
          .map((r) => UnsplashPhoto.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _staticPool(query, page);
    }
  }

  // 40 farklı fotoğraf — sayfaya göre rotate eder, sonsuz hissi verir
  static const _pool = [
    (
      'a',
      'https://images.unsplash.com/photo-1552374196-1ab2a1c593e8?w=600&q=80',
      'Taylor Simpson'
    ),
    (
      'b',
      'https://images.unsplash.com/photo-1516826957135-700dedea698c?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'c',
      'https://images.unsplash.com/photo-1503341504253-dff4815485f1?w=600&q=80',
      'Ryan Jacobson'
    ),
    (
      'd',
      'https://images.unsplash.com/photo-1487222477894-8943e31ef7b2?w=600&q=80',
      'Ali Pazani'
    ),
    (
      'e',
      'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'f',
      'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=600&q=80',
      'Hannah Morgan'
    ),
    (
      'g',
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=80',
      'Ussama Azam'
    ),
    (
      'h',
      'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'i',
      'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&q=80',
      'freestocks'
    ),
    (
      'j',
      'https://images.unsplash.com/photo-1470259078422-826894b933aa?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'k',
      'https://images.unsplash.com/photo-1467043237213-65f2da53396f?w=600&q=80',
      'Ali Pazani'
    ),
    (
      'l',
      'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'm',
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&q=80',
      'Becca McHaffie'
    ),
    (
      'n',
      'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'o',
      'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=600&q=80',
      'Hannah Morgan'
    ),
    (
      'p',
      'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'q',
      'https://images.unsplash.com/photo-1445205170230-053b83016050?w=600&q=80',
      'Lauren Fleischmann'
    ),
    (
      'r',
      'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      's',
      'https://images.unsplash.com/photo-1566206091558-7f218b696731?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      't',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=600&q=80',
      'Dom Hill'
    ),
    (
      'u',
      'https://images.unsplash.com/photo-1542295669297-4d352b042bca?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'v',
      'https://images.unsplash.com/photo-1550614000-4895a10e1bfd?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'w',
      'https://images.unsplash.com/photo-1571513800374-df1bbe650e56?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'x',
      'https://images.unsplash.com/photo-1576995853123-5a10305d93c0?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'y',
      'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'z',
      'https://images.unsplash.com/photo-1475180098004-ca77a66827be?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'aa',
      'https://images.unsplash.com/photo-1536766820879-059fec98ec0a?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'ab',
      'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'ac',
      'https://images.unsplash.com/photo-1544441893-675973e31985?w=600&q=80',
      'Tamara Bellis'
    ),
    (
      'ad',
      'https://images.unsplash.com/photo-1519657337289-077653f724ed?w=600&q=80',
      'Tamara Bellis'
    ),
  ];

  List<UnsplashPhoto> _staticPool(String query, int page) {
    // Her sayfa farklı 12 fotoğraf döndürür, döngüsel
    final startIndex = ((page - 1) * 12) % _pool.length;
    final result = <UnsplashPhoto>[];
    for (int i = 0; i < 12; i++) {
      final item = _pool[(startIndex + i) % _pool.length];
      result.add(UnsplashPhoto(
        id: '${item.$1}_p${page}_$i',
        imageUrl: item.$2,
        thumbUrl: item.$2.replaceAll('w=600', 'w=300'),
        photographerName: item.$3,
      ));
    }
    return result;
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(),
);

// ── Style Filters ─────────────────────────────────────────────────
const _styleFilters = [
  ('Tümü', 'fashion outfit style'),
  ('Casual', 'casual street style outfit'),
  ('Ofis', 'office smart casual outfit'),
  ('Yaz', 'summer fashion outfit'),
  ('Spor', 'sporty athletic outfit'),
  ('Gece', 'evening going out outfit'),
];

final selectedStyleProvider = StateProvider<int>((ref) => 0);

// ── AI Analysis State ─────────────────────────────────────────────
class AnalysisState {
  final bool isLoading;
  final OutfitAnalysis? result;
  final String? error;
  final String? analyzedImageUrl;

  const AnalysisState({
    this.isLoading = false,
    this.result,
    this.error,
    this.analyzedImageUrl,
  });

  AnalysisState copyWith({
    bool? isLoading,
    OutfitAnalysis? result,
    String? error,
    String? analyzedImageUrl,
  }) =>
      AnalysisState(
        isLoading: isLoading ?? this.isLoading,
        result: result ?? this.result,
        error: error ?? this.error,
        analyzedImageUrl: analyzedImageUrl ?? this.analyzedImageUrl,
      );
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AiService _ai;
  AnalysisNotifier(this._ai) : super(const AnalysisState());

  Future<void> analyzeUrl(String imageUrl) async {
    state = AnalysisState(isLoading: true, analyzedImageUrl: imageUrl);
    final result = await _ai.analyzeOutfitFromUrl(imageUrl);
    if (result != null) {
      state = AnalysisState(result: result, analyzedImageUrl: imageUrl);
    } else {
      state = AnalysisState(
        error: 'Analiz başarısız. İnternet bağlantını kontrol et.',
        analyzedImageUrl: imageUrl,
      );
    }
  }

  Future<void> analyzeFile(File file) async {
    state = const AnalysisState(isLoading: true);
    final result = await _ai.analyzeOutfitFromFile(file);
    if (result != null) {
      state = AnalysisState(result: result);
    } else {
      state = const AnalysisState(error: 'Fotoğraf analiz edilemedi.');
    }
  }

  void reset() => state = const AnalysisState();
}

final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) => AnalysisNotifier(ref.read(aiServiceProvider)),
);

// ── Main Screen ───────────────────────────────────────────────────
class InspirationScreen extends ConsumerStatefulWidget {
  const InspirationScreen({super.key});

  @override
  ConsumerState<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends ConsumerState<InspirationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Listenin sonuna %90 yaklaşınca daha fazla yükle
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(feedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);
    final analysisState = ref.watch(analysisProvider);
    final selectedStyle = ref.watch(selectedStyleProvider);

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // ── Header ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('İlham Al',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge),
                                Text('Kombine tıkla, parçayı bul.',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            _UploadButton(),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Style Chips ───────────────────────────
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _styleFilters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final active = i == selectedStyle;
                              return GestureDetector(
                                onTap: () {
                                  ref
                                      .read(selectedStyleProvider.notifier)
                                      .state = i;
                                  ref.read(feedProvider.notifier).loadInitial(
                                        query: _styleFilters[i].$2,
                                      );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? AppTheme.neonGreen
                                        : AppTheme.warmWhite,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: active
                                          ? AppTheme.neonGreen
                                          : AppTheme.softGray,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _styleFilters[i].$1,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? Colors.white
                                            : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // ── Loading ilk yükleme ───────────────────────────
                if (feedState.isLoading)
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation(AppTheme.neonGreen),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),

                // ── Photo Grid ────────────────────────────────────
                if (!feedState.isLoading && feedState.photos.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _PhotoCard(photo: feedState.photos[index]),
                        childCount: feedState.photos.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.65,
                      ),
                    ),
                  ),

                // ── Load more spinner ─────────────────────────────
                if (feedState.isLoadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(AppTheme.neonGreen),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Sona gelindi mesajı ───────────────────────────
                if (!feedState.hasMore && feedState.photos.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'Hepsi bu kadar 👗',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 13,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            // ── Analysis Overlay ──────────────────────────────────
            if (analysisState.isLoading ||
                analysisState.result != null ||
                analysisState.error != null)
              _AnalysisOverlay(state: analysisState),
          ],
        ),
      ),
    );
  }
}

// ── Upload Button ─────────────────────────────────────────────────
class _UploadButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
            source: ImageSource.gallery, imageQuality: 85);
        if (picked == null) return;
        ref.read(analysisProvider.notifier).analyzeFile(File(picked.path));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.neonGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.neonGreen.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: AppTheme.neonGreen, size: 18),
            const SizedBox(width: 6),
            Text(
              'Fotoğraf Analiz Et',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.neonGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Photo Card ────────────────────────────────────────────────────
class _PhotoCard extends ConsumerWidget {
  final UnsplashPhoto photo;
  const _PhotoCard({required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(analysisProvider.notifier).analyzeUrl(photo.imageUrl),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.warmWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.softGray, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                photo.thumbUrl,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, prog) => prog == null
                    ? child
                    : Container(
                        color: AppTheme.softGray,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(AppTheme.neonGreen),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.softGray,
                  child: const Icon(Icons.image_outlined,
                      color: AppTheme.mediumGray, size: 32),
                ),
              ),
              // Gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
              // AI etiketi
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Text('AI Analiz',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              // Fotoğrafçı
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Text(
                  photo.photographerName,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 10, color: Colors.white.withOpacity(0.8)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Analysis Overlay ──────────────────────────────────────────────
class _AnalysisOverlay extends ConsumerWidget {
  final AnalysisState state;
  const _AnalysisOverlay({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          if (!state.isLoading) ref.read(analysisProvider.notifier).reset();
        },
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: _AnalysisSheet(state: state),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalysisSheet extends ConsumerWidget {
  final AnalysisState state;
  const _AnalysisSheet({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: const BoxDecoration(
        color: AppTheme.warmWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.softGray,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          if (state.isLoading) _LoadingView(),
          if (state.error != null) _ErrorView(error: state.error!),
          if (state.result != null)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _ResultView(analysis: state.result!),
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.neonGreen),
            strokeWidth: 2.5,
          ),
          const SizedBox(height: 20),
          Text('AI kombini analiz ediyor...',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 15, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Text('Kıyafet parçaları tespit ediliyor',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 12, color: AppTheme.mediumGray)),
        ],
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 40),
          const SizedBox(height: 12),
          Text(error,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => ref.read(analysisProvider.notifier).reset(),
            child: Text('Kapat',
                style: GoogleFonts.spaceGrotesk(color: AppTheme.neonGreen)),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends ConsumerWidget {
  final OutfitAnalysis analysis;
  const _ResultView({required this.analysis});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(analysis.overallStyle,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.event_note_outlined,
                          size: 14, color: AppTheme.mediumGray),
                      const SizedBox(width: 4),
                      Text(analysis.occasion,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ref.read(analysisProvider.notifier).reset(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.softGray),
                ),
                child: const Icon(Icons.close,
                    size: 16, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.neonGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome,
                  size: 12, color: AppTheme.neonGreen),
              const SizedBox(width: 5),
              Text('${analysis.pieces.length} parça tespit edildi',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neonGreen)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...analysis.pieces.map((piece) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PieceCard(piece: piece),
            )),
      ],
    );
  }
}

class _PieceCard extends StatelessWidget {
  final AnalyzedPiece piece;
  const _PieceCard({required this.piece});

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    try {
      dotColor = Color(
          int.parse('FF${piece.colorHex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      dotColor = AppTheme.neonGreen;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.softGray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.softGray, width: 0.5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(piece.name,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoal)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.warmWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.softGray),
                ),
                child: Text(piece.category,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text('${piece.color}  ·  ${piece.fit}',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12, color: AppTheme.mediumGray)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                piece.storeLinks.map((l) => _StoreLinkChip(link: l)).toList(),
          ),
        ],
      ),
    );
  }
}

class _StoreLinkChip extends StatelessWidget {
  final StoreLink link;
  const _StoreLinkChip({required this.link});

  @override
  Widget build(BuildContext context) {
    final color = Color(link.color);
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(link.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_in_new, size: 11, color: color),
            const SizedBox(width: 4),
            Text(link.name,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
