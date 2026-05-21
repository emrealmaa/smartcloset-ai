import '../../core/enums/body_enums.dart';
import '../../core/enums/skin_enums.dart';
import '../../models/character_profile.dart';
import '../../models/style_lesson.dart';

class StyleEducationEngine {
  static List<StyleLesson> generate(CharacterProfile character) {
    return [
      ..._colorLessons(character),
      ..._fitLessons(character),
      ..._patternLessons(character),
    ];
  }

  // ── Renk Dersleri ───────────────────────────────────────────────

  static List<StyleLesson> _colorLessons(CharacterProfile character) => [
        _undertoneLesson(character.skinUndertone),
        _contrastLesson(character.skinDepth),
        _avoidColorsLesson(character.skinUndertone),
      ];

  static StyleLesson _undertoneLesson(SkinUndertone undertone) {
    return switch (undertone) {
      SkinUndertone.warm => const StyleLesson(
          id: 'color_undertone_warm',
          category: StyleLessonCategory.color,
          title: 'Sıcak Ton: Doğanın Renkleri Senin Renklerin',
          summary:
              'Sıcak alt tonun, toprak renklerini ve sıcak nötralleri mükemmel taşımanı sağlar.',
          bullets: [
            'Zeytuni yeşil, nar kırmızısı, hardal sarısı ve bakır — ana renk ailendir.',
            'Kırık beyaz ve krem, saf beyaza göre sana çok daha iyi durur.',
            'Lacivert yerine koyu yeşil ya da bordo tercih et.',
            'Altın rengi metal aksesuarlar gümüşe göre ten renginle daha uyumlu görünür.',
            'Turuncu bazlı ton renkleri (salmon, şeftali) soğuk pembeye göre daha iyi yakışır.',
          ],
          tip: 'Gardırobuna önce hardal sarısı veya zeytuni yeşil bir parça ekle. '
              'Bu renkler sıcak ton sahiplerinin "güçlü rengi"dir.',
        ),
      SkinUndertone.cool => const StyleLesson(
          id: 'color_undertone_cool',
          category: StyleLessonCategory.color,
          title: 'Soğuk Ton: Jewel Tonların Gücü',
          summary:
              'Soğuk alt tonun, jewel tones ve soğuk nötraller ile parlamasını sağlar.',
          bullets: [
            'Safir mavi, yakut kırmızısı, zümrüt yeşili, mor ve gül kurusu seni öne çıkarır.',
            'Saf beyaz, kremden çok daha iyi görünür — ten renginle netlik yaratır.',
            'Lacivert, siyah ve koyu gri — temel nötrallerin.',
            'Gümüş rengi metal aksesuarlar altına göre ten renginle daha uyumlu.',
            'Soğuk pembe (gül) ve leylak, sıcak somon pembesinden çok daha iyi yakışır.',
          ],
          tip: 'Bir jewel tone üst — safir mavi veya zümrüt yeşili bir gömlek — '
              'gardırobunun yıldız parçası olacak.',
        ),
      SkinUndertone.neutral => const StyleLesson(
          id: 'color_undertone_neutral',
          category: StyleLessonCategory.color,
          title: 'Nötr Ton: Evrensel Renk Esnekliği',
          summary:
              'Nötr alt tonun, hem sıcak hem soğuk renk ailelerini rahatlıkla taşıyabilmeni sağlar.',
          bullets: [
            'Toprak renkleri (hardal, bakır, terrakota) ve jewel tones (safir, zümrüt) ikisi de sana yakışır.',
            'Krem ve saf beyazın ikisi de giyilebilir — hangisi seni mutlu ediyorsa.',
            'Altın ve gümüş aksesuarları özgürce karıştırabilirsin.',
            'Renk kombinasyonlarında sıcak/soğuk kısıtlamayla bağlı değilsin.',
            'Doygun (vibrant) renkler yüksek kontrast, muted renkler sofistike duruş verir.',
          ],
          tip: 'Nötr ton olmanın gizli kuralı: doygunluk (saturation) ile oyna. '
              'Tüm renkler muted olunca monoton, vibrant olunca canlı görünürsün.',
        ),
    };
  }

  static StyleLesson _contrastLesson(SkinDepth depth) {
    return switch (depth) {
      SkinDepth.veryFair || SkinDepth.fair => const StyleLesson(
          id: 'color_contrast_light',
          category: StyleLessonCategory.color,
          title: 'Açık Ten: Kontrast Senin Güçlü Silahın',
          summary:
              'Açık tenin koyu renklerle güçlü bir kontrast oluşturur — bunu kullan.',
          bullets: [
            'Koyu pantolon + açık üst klasik yüksek kontrast kombindir, çok şık görünür.',
            'Tüm siyah veya tüm beyaz kombinler açık tende güçlü ve net bir etki yaratır.',
            'Pastel renkler tene yakın değerde olduğu için az kontrast yaratır — dikkatli kullan.',
            'Yüze yakın giysilerde orta veya koyu ton tercih et.',
            'Neon renkler fazla kontrast yaratabilir — daha dengeli bir etki için muted ton tercih et.',
          ],
          tip: 'Koyu lacivert veya grafite chino + açık renk üst açık tenin '
              'en sağlam kontrast kombinasyonudur.',
        ),
      SkinDepth.medium || SkinDepth.olive => const StyleLesson(
          id: 'color_contrast_medium',
          category: StyleLessonCategory.color,
          title: 'Orta Ten: Her Kontrastı Taşıyan Esneklik',
          summary:
              'Orta ten rengi hem düşük hem yüksek kontrast kombinleri rahat taşır.',
          bullets: [
            'Orta tondaki toprak renkleri (taupe, camel, tan) tene yakın değerle uyumlu görünür.',
            'Koyu-açık kontrast kombinler güçlü ve net bir görünüm sağlar.',
            'Tonal kombin (aynı rengin farklı tonları) sofistike bir etki yaratır.',
            'Vibrant renkler abartılı hissettirmeden taşınabilir.',
            'Hem high-contrast hem low-contrast kombinler seçeneğin dahilinde.',
          ],
          tip: 'Tonal kombini dene: açık gri üst + orta gri pantolon + koyu gri ayakkabı. '
              'Effortless şıklık.',
        ),
      SkinDepth.brown || SkinDepth.dark => const StyleLesson(
          id: 'color_contrast_dark',
          category: StyleLessonCategory.color,
          title: 'Koyu Ten: Zengin Renkler Parlar',
          summary:
              'Koyu ten, vibrant ve zengin renklere doğal bir tuval görevi görür.',
          bullets: [
            'Zümrüt, safir, mor, bordo gibi zengin doygun renkler koyu tende çarpıcı görünür.',
            'Beyaz koyu tenle çok yüksek kontrast yaratır — güçlü, net ve cesur görüntü.',
            'Tonal kombin (koyu kahveden açık kreme) şık ve organik görünür.',
            'Toprak renkleri koyu tenle doğal uyum içinde çalışır.',
            'Açık pastellerden kaçın — tende "kaybola" bilirler.',
          ],
          tip: 'Bir zengin jewel tone üst — nar kırmızısı veya zümrüt yeşili — '
              'koyu ten üzerinde muhteşem görünür.',
        ),
    };
  }

  static StyleLesson _avoidColorsLesson(SkinUndertone undertone) {
    return switch (undertone) {
      SkinUndertone.warm => const StyleLesson(
          id: 'color_avoid_warm',
          category: StyleLessonCategory.color,
          title: 'Sıcak Ton: Kaçın ve Neden',
          summary:
              'Bazı soğuk renkler sıcak alt tonun üzerinde soluk veya yorgun bir görüntü yaratabilir.',
          bullets: [
            'Kül grisi (cool grey) sıcak tende cildi soluk gösterebilir — sıcak gri veya beige tercih et.',
            'Leylak ve mor — özellikle makyajsız — sıcak tende yorgun görüntüsü verebilir.',
            'Buz mavisi (ice blue) sıcak tende renklerle çarpışarak "soğuk" bir kombinasyon oluşturur.',
            'Hot pink (magenta) sıcak tende kırmızılık veya leke izlenimi yaratabilir.',
          ],
          tip: 'Kaçındığın rengi seviyorsan tamamen vazgeçme: muted (daha az doygun) '
              'versiyonunu veya çok koyu/açık tonunu dene.',
        ),
      SkinUndertone.cool => const StyleLesson(
          id: 'color_avoid_cool',
          category: StyleLessonCategory.color,
          title: 'Soğuk Ton: Kaçın ve Neden',
          summary:
              'Bazı sıcak renkler soğuk alt tonun üzerinde çarpışma veya istenmeyen kırmızılık yaratabilir.',
          bullets: [
            'Turuncu ve sıcak mercan soğuk tende cildi kırmızımsı veya tahriş göşterişli gösterebilir.',
            'Hardal sarısı soğuk tende cildi sararmış gösterme riski taşır.',
            'Krem ve off-white soğuk tende "kirliymiş" algısı yaratabilir — saf beyaza geç.',
            'Sıcak bakır veya altın metaller soğuk tenle uyumsuz görünebilir.',
          ],
          tip: 'Sıcak bir rengi giymek istiyorsan soğuk bazlı versiyonu seç: '
              'somon yerine gül kurusu, mercan yerine bordo.',
        ),
      SkinUndertone.neutral => const StyleLesson(
          id: 'color_avoid_neutral',
          category: StyleLessonCategory.color,
          title: 'Nötr Ton: Kaçınılacak Çok Az Şey Var',
          summary:
              'Nötr ton olmanın ayrıcalığı: renk seçiminde minimum kısıtlama.',
          bullets: [
            'Aslında nötr ton için "kesinlikle kaçın" diyebileceğimiz renk çok azdır.',
            'Çok soluk "washed out" renkler her tende olduğu gibi sende de silik görünebilir.',
            'Kombinde renk orantısına dikkat et: 3 farklı vibrant renk aynı anda çok gürültülü hissettiribilir.',
            'En büyük tuzak: "hepsi yakışıyor" diye düşünüp renk kaosuna düşmek.',
          ],
          tip: '60-30-10 kuralını uygula: kombininde %60 baskın renk, '
              '%30 ikincil, %10 aksan rengi. Bu her tende çalışır.',
        ),
    };
  }

  // ── Fit Dersleri ────────────────────────────────────────────────

  static List<StyleLesson> _fitLessons(CharacterProfile character) => [
        _bodyTypeFitLesson(character.bodyType),
        _proportionLesson(character.bodyType),
        _layeringLesson(character.bodyType),
      ];

  static StyleLesson _bodyTypeFitLesson(BodyType bodyType) {
    return switch (bodyType) {
      BodyType.triangle => const StyleLesson(
          id: 'fit_body_triangle',
          category: StyleLessonCategory.fit,
          title: 'Üçgen Vücut: Üstü Dengele, Altı Yumuşat',
          summary:
              'Omuzlardan dar, kalçalardan geniş vücut tipinde amaç: görsel dengeyi yukarı taşımak.',
          bullets: [
            'Oversized veya relaxed fit üstler omuz genişliği izlenimi yaratır — dengeler.',
            'Slim fit üstlerden kaçın: dar omuz ile geniş kalça kontrastını vurgular.',
            'Alt için relaxed veya regular fit tercih et; slim fit paça kalçayı daraltmaz, vurgular.',
            'Koyu renkli alt giyim kalçayı görsel olarak küçültür.',
            'V-yaka ve geniş yaka üstler dikkat yukarı çeker.',
          ],
          tip: 'Bol bir gömlek veya sweatshirt + koyu chino klasik denge kombinasyonudur. '
              'Gömleği yarı içeri kat: omuzları belirginleştirir.',
        ),
      BodyType.invertedTriangle => const StyleLesson(
          id: 'fit_body_invertedTriangle',
          category: StyleLessonCategory.fit,
          title: 'Ters Üçgen Vücut: Omuzu Yumuşat',
          summary:
              'Geniş omuz, dar kalça tipinde amaç: omuzu vurgulamamak, alt vücuda hacim katmak.',
          bullets: [
            'Regular ve relaxed fit üstler omuzu yumuşatır; oversized tam tersi büyütür.',
            'V-yaka omuzları keskin gösterir — geniş yaka (ekarte) veya yuvarlak yaka daha iyi.',
            'Alt için slim, regular ya da geniş paça — hepsi alt hacmi dengeler.',
            'Çizgili veya desenli alt giyim kalçaya dikkat çekerek denge sağlar.',
            'Yapılandırılmış blazer omuzlara hacim katar — dikkatli kullan.',
          ],
          tip: 'Koyu üst + açık veya desenli alt dikkat merkezini aşağı taşır. '
              'Ters üçgenin en sevdiği şablondur.',
        ),
      BodyType.rectangle => const StyleLesson(
          id: 'fit_body_rectangle',
          category: StyleLessonCategory.fit,
          title: 'Dikdörtgen Vücut: Boyut Yarat, Karakter Ekle',
          summary:
              'Düz ve dengeli vücut için amaç: katmanlar ve kontrast ile görsel ilgi yaratmak.',
          bullets: [
            'Regular ve slim fit üstler temiz hat çizer — en esnek vücut tipisin.',
            'Katmanlama dikdörtgen için en güçlü araçtır: gömlek + kazak, t-shirt + ceket.',
            'Bel çizgisi vurgulayan kesimler, blazer, keskin kemer görsel bel yaratır.',
            'Koyu üst + açık alt ya da açık üst + koyu alt kontrast bölgeleme yapar.',
            'Yatay şeritler sana ekstra görsel hacim katar — gerektiğinde kullan.',
          ],
          tip: 'Slim fit gömlek + açık gri slim chino + beyaz sneaker dikdörtgen '
              'vücudun klasik formülüdür. Sadelik senin güçlü silahın.',
        ),
      BodyType.oval => const StyleLesson(
          id: 'fit_body_oval',
          category: StyleLessonCategory.fit,
          title: 'Oval Vücut: Uzun Hat, Dikey Çizgi',
          summary:
              'Orta gövdede dolgunluk olan oval vücut için amaç: uzayan dikey hatlar yaratmak.',
          bullets: [
            'Regular fit üstler en iyi seçim: slim çok yapışır, oversized hacim katar.',
            'V-yaka ve dikey çizgili desenler görsel uzunluk yaratır.',
            'Koyu renkler, özellikle monokrom kombin, vücudu uzun gösterir.',
            'Uzun cardigan veya açık ceket dikey hat sağlar.',
            'Geniş yatay şeritler ve bold desenler vücudu genişletir — kaçın.',
          ],
          tip: 'Koyu monokrom kombin (all navy veya all black) en güvenli ve şık seçim. '
              'Tek bir açık aksesuar veya ayakkabıyla kır.',
        ),
      BodyType.athletic => const StyleLesson(
          id: 'fit_body_athletic',
          category: StyleLessonCategory.fit,
          title: 'Atletik Vücut: Yapıyı Öne Çıkar',
          summary:
              'Kas kitlesi olan atletik vücut, slim ve regular fit ile şekli netleştirir.',
          bullets: [
            'Slim fit üstler kas yapısını belirginleştirir — en çok yakışan fit budur.',
            'Regular fit hem rahat hem şık alternatiftir, her ortamda geçerlidir.',
            'Oversized üstlerde göğüs ve omuz bölgesi kaybolabilir.',
            'Slim fit pantolon bacağı çerçeveler — iyi bir görünüm sağlar.',
            'Elastan karışımlı kumaşlar hem görünümü hem konforu optimize eder.',
          ],
          tip: 'Slim fit beyaz gömlek + koyu slim chino atletik vücudun klasik formülüdür. '
              'Manşetleri katla: hem rahat hem stylish.',
        ),
    };
  }

  static StyleLesson _proportionLesson(BodyType bodyType) {
    final (title, summary, bullets, tip) = switch (bodyType) {
      BodyType.triangle => (
        'Üçgen Vücut: Görsel Ağırlığı Yukarı Taşı',
        'Dikkat yukarıda toplandığında omuz–kalça dengesi görsel olarak iyileşir.',
        const <String>[
          'Cep, yaka detayı, desen — tüm dekoratif unsurları üste taşı.',
          'Geniş kemer veya bel çizgisi dikkat üst vücuda çeker ve altı ayırır.',
          'Üst parça rengi alttan bir tık daha açık veya vibrant olabilir.',
          'Uzun kollu üstler kol uzunluğunu vurgular — ince görünüm yaratır.',
          'Yarım tuck-in: üstün ön kısmını pantolona sokarak beli tanımla.',
        ],
        'Yarım tuck-in basit ama etkili bir tekniktir: beli tanımlar, '
            'omuza odaklanır, alt hacmi azaltır.',
      ),
      BodyType.invertedTriangle => (
        'Ters Üçgen: Dikkat Merkezini Aşağı Taşı',
        'Kalçaya yapılan vurgu omuz–kalça görsel dengesini iyileştirir.',
        const <String>[
          'Desen, cep ve dekoratif unsurları alt giyimde kullan.',
          'Cargo cep, yan dikişte detay alt giyimler kalçaya boyut katar.',
          'Üst giyimi dışarıda bırak (untuck) — kalçayı örter ve dengeye katkı sağlar.',
          'Açık veya renkli pantolon + koyu üst dikkat merkezini aşağıya taşır.',
          'Uzun ceket veya blazer omuzu daha az "keskin" gösterir.',
        ],
        'Uzun trençkot veya overcoat ters üçgenin en şık aracıdır. '
            'Dikey hat yaratır ve omuz genişliğini dağıtır.',
      ),
      BodyType.rectangle => (
        'Dikdörtgen: Kontrast ve Katmanla Form Yarat',
        'Doğal bel olmadığında kontrast ve katmanlarla görsel form oluşturulur.',
        const <String>[
          'Bel çizgisi vurgulu parçalar (cropped üst, blazer) görsel bel yaratır.',
          'Farklı uzunlukta üst ve alt oranları kırarak dinamik görünüm sağlar.',
          'Yüksek bel pantolon vücudu ikiye bölerek bacak uzunluğu hissi verir.',
          'İki renkli kombin (üst + alt farklı renk) yatay hat yaratarak şekillendirir.',
          'Katmanlama boyut katar: gömlek + kazak veya t-shirt + ceket dene.',
        ],
        'Crop veya kısa blazer + yüksek bel pantolon dikdörtgen için '
            'form yaratmanın en hızlı yoludur.',
      ),
      BodyType.oval => (
        'Oval Vücut: Dikey Hat ve Uzunluk',
        'Dikey görsel çizgiler vücudu uzatır ve daha ince görünüm yaratır.',
        const <String>[
          'Tek renk kombin (head-to-toe) en güçlü dikey hattı verir.',
          'Açık ceket veya cardigan üzerine giyme: düşey çizgiler oluşturur.',
          'Yüksek bel pantolon bacağı uzatır ve orantıyı iyileştirir.',
          'Bel vurgusu yapmayan düz kesim üstler daha rahat ve uyumlu görünür.',
          'Uzun kolye veya kravat gibi dikey aksesuarlar görsel uzunluk ekler.',
        ],
        'V-yaka koyu bir kazak + koyu regular fit pantolon + koyu ayakkabı: '
            'mükemmel dikey hat, minimum çaba.',
      ),
      BodyType.athletic => (
        'Atletik Vücut: Dengeli Oranı Koru',
        'Atletik vücutta amaç oranları bozmadan şekli şık bir şekilde vurgulamak.',
        const <String>[
          'Üst ve alt benzer renk değerinde olabilir — dengeli oranın var.',
          'Çok fazla katman şişirebilir; biri hafif, biri yapılandırılmış ol.',
          'Uzun ceket ve overcoat atletik yapıyı şık bir şekilde çerçeveler.',
          'Ayakkabı seçimi oranı tamamlar: sneaker rahat, loafer şık görünüm sağlar.',
          'Geniş pantolon paçası (wide-leg) alt orantıya farklı bir boyut ekler.',
        ],
        'Slim fit üst + wide-leg pantolon atletik vücudu daha moda odaklı gösterir. '
            'Trendi yakalamak istediğinde bu oranı kullan.',
      ),
    };

    return StyleLesson(
      id: 'fit_proportion_${bodyType.name}',
      category: StyleLessonCategory.fit,
      title: title,
      summary: summary,
      bullets: bullets,
      tip: tip,
    );
  }

  static StyleLesson _layeringLesson(BodyType bodyType) {
    return switch (bodyType) {
      BodyType.triangle => const StyleLesson(
          id: 'fit_layer_triangle',
          category: StyleLessonCategory.fit,
          title: 'Katmanlama: Üst Vücuda Odaklan',
          summary:
              'Üçgen vücut için katmanlama üst omuz bölgesine dikkat çekme fırsatıdır.',
          bullets: [
            'Açık veya bol bir dış ceket üst vücudu büyük gösterir — denge sağlar.',
            'Gömlek üzerine kazak veya hoodie: omuz hattını belirginleştirmeden hacim ekler.',
            'Belde biten bir ceket veya blazer alt ile üstü ayırır.',
            'Uzun kışlık mont kalçayı örter — oransal avantaj sağlar.',
            'Kravat ve şal gibi dikey aksesuarlar dikkat yukarıda tutar.',
          ],
          tip: 'Denim ceket + içinde gömlek veya hoodie üçgen vücudun en rahat '
              've şık layering kombinasyonudur.',
        ),
      BodyType.invertedTriangle => const StyleLesson(
          id: 'fit_layer_invertedTriangle',
          category: StyleLessonCategory.fit,
          title: 'Katmanlama: Omuzu Dağıt',
          summary:
              'Ters üçgen için katmanlama omuz genişliğini görsel olarak yumuşatır.',
          bullets: [
            'Uzun dökümlü dış giysiler (trençkot, overcoat) omuz hattını çerçeveler.',
            'Yapılandırılmış blazer omuzlara köşe katar — sadece gerekliyse kullan.',
            'İçine sıkıştırılmış (tucked) katman beli tanımlar, dikkat merkeze çeker.',
            'Açık bir ceket içindeki üsten daha koyu olursa dışı çerçeve görevi görür.',
            'Uzun şal veya atkı omuzların önünde dikey hat yaratır.',
          ],
          tip: 'Uzun trençkot veya overcoat ters üçgenin en şık katmanlama aracıdır. '
              'Düğmelerini aç: içindeki kombini gösterir, dış hattı yumuşatır.',
        ),
      BodyType.rectangle => const StyleLesson(
          id: 'fit_layer_rectangle',
          category: StyleLessonCategory.fit,
          title: 'Katmanlama: Boyut Yarat',
          summary:
              'Dikdörtgen vücut katmanlamayla en fazla fayda sağlayan tiptir.',
          bullets: [
            'İki farklı doku (pamuk tişört + örgü kazak) görsel zenginlik katar.',
            'Belden kısa bir ceket veya blazer bel çizgisini tanımlar.',
            'Gömlek eteklerini dışarıda bırakmak (untuck) uzunluk ve boyut hissi verir.',
            'Çok renkli katmanlar renk bloklama görevi görür — vücuda form verir.',
            'Açık bir dış ceket içindeki kontrastla keskin bir look yaratır.',
          ],
          tip: 'Düz tişört + açık gömlek + slim ceket. Üç katman, her katman görünür: '
              'dikdörtgenin en güçlü looku.',
        ),
      BodyType.oval => const StyleLesson(
          id: 'fit_layer_oval',
          category: StyleLessonCategory.fit,
          title: 'Katmanlama: Dikey Hatla Uzat',
          summary:
              'Oval vücutta katmanlama dikey hat oluşturmak için kullanılır.',
          bullets: [
            'Uzun cardigan veya açık ceket — kapatmadan giymek — dikey hat oluşturur.',
            'İç katman dış katmandan daha koyu olursa dış giysi dikey çerçeve görevi görür.',
            'Uzun kollu iç + kısa dış orantıyı kırar — kaçın.',
            'Tek renk katman (tonal layering) en az gürültülü ve en şık sonuç verir.',
            'Belden uzun bir dış giysi dikkat merkezini aşağıya taşır.',
          ],
          tip: 'Koyu iç giysi + aynı tonun açık uzun cardiganı veya yeleği. '
              'Tonal katman, mükemmel dikey hat.',
        ),
      BodyType.athletic => const StyleLesson(
          id: 'fit_layer_athletic',
          category: StyleLessonCategory.fit,
          title: 'Katmanlama: Şekli Kontrol Et',
          summary:
              'Atletik vücutta katmanlama şekli abartmadan göstermek için bilinçli yapılır.',
          bullets: [
            'İlk katman slim: kas yapısını belirler.',
            'Üst katman bir tık daha bol: şekli bozmadan rahat ve şık görünüm sağlar.',
            'Belden uzun ceket bacak uzunluğunu "kısar" — dikkatli ol.',
            'Belden kısa ceket oranı iyileştirir ve üst vücudu çerçeveler.',
            'Merino veya performance blend kumaşlar hem çekici hem işlevsel.',
          ],
          tip: 'Slim fit beyaz tişört + açık denim ceket + slim chino atletik vücudun '
              'günlük casual masterpiece kombinasyonudur.',
        ),
    };
  }

  // ── Desen Dersleri ──────────────────────────────────────────────

  static List<StyleLesson> _patternLessons(CharacterProfile character) => [
        _patternBodyTypeLesson(character.bodyType),
        _patternMixingLesson(),
        _patternScaleLesson(),
      ];

  static StyleLesson _patternBodyTypeLesson(BodyType bodyType) {
    return switch (bodyType) {
      BodyType.triangle => const StyleLesson(
          id: 'pattern_triangle',
          category: StyleLessonCategory.pattern,
          title: 'Üçgen: Deseni Üste Taşı',
          summary:
              'Üçgen vücutta desen üst giyimde dikkat çeker ve omuz–kalça dengesini sağlar.',
          bullets: [
            'Çizgili gömlek, ekose, baskılı tişört — desenler üstte mükemmel çalışır.',
            'Alt giyimde koyu ve solid renkler kalçayı görsel olarak küçültür.',
            'Yatay çizgili üstler omuz genişliğini artırır — güçlü denge aracı.',
            'Dikey çizgili üstler dikkat yukarı çeker.',
            'Büyük baskı ve bold desen ince boyutlu desenlerden daha dikkat çekicidir.',
          ],
          tip: 'Büyük ekose flannel gömlek + koyu düz jean üçgen vücudun desen rehber kombinasyonu.',
        ),
      BodyType.invertedTriangle => const StyleLesson(
          id: 'pattern_invertedTriangle',
          category: StyleLessonCategory.pattern,
          title: 'Ters Üçgen: Deseni Alta Taşı',
          summary:
              'Ters üçgen vücutta desenli alt, dikkat merkezini kalçaya çekerek dengeler.',
          bullets: [
            'Desenli pantolon, kareli veya ekose alt giyim kalçaya hacim katar.',
            'Üstte solid renkler omuzları daha az vurgular.',
            'Çizgili üstlerden kaçın: yatay çizgiler omuzları genişletir.',
            'Küçük ve orta ölçekli desen en uygun — çok büyük baskı abartılı olabilir.',
            'Dekoratif cep veya detay alt giyimde daha güçlü görünüm yaratır.',
          ],
          tip: 'Düz koyu bir üst + ince çizgili veya ekose pantolon ters üçgen için desen formülü.',
        ),
      BodyType.rectangle => const StyleLesson(
          id: 'pattern_rectangle',
          category: StyleLessonCategory.pattern,
          title: 'Dikdörtgen: Desenle Form Yarat',
          summary:
              'Dikdörtgen vücut deseni hem üst hem alt giyimde özgürce kullanabilir.',
          bullets: [
            'Yatay çizgiler görsel genişlik katar — bel algısı oluşturmak için kullan.',
            'Büyük baskı ve bold desen görsel hacim katar.',
            'Ekose kalıplar yapılandırılmış bir görünüm sağlar.',
            'Üst desenli + alt solid veya tam tersi — her ikisi de çalışır.',
            'Renk bloklama desensiz ama form oluşturmak için etkilidir.',
          ],
          tip: 'İnce çizgili gömlek + düz pantolon dikdörtgen için desen giriş noktası.',
        ),
      BodyType.oval => const StyleLesson(
          id: 'pattern_oval',
          category: StyleLessonCategory.pattern,
          title: 'Oval: Desen Seçiminde Dikkatli Ol',
          summary:
              'Oval vücutta desen seçimi görünümü iyileştirir veya zorlaştırabilir.',
          bullets: [
            'Dikey çizgiler ve ince desenler uzayan görünüm yaratır — tercih et.',
            'Büyük yatay desenler vücudu genişletir — kaçın.',
            'Küçük ve orta ölçekli desen (small check, micro print) güvenli seçimdir.',
            'Solid giyimle tek desenli parça — gürültüyü en aza indir.',
            'Koyu renkli desenli parça, açık zemin üzerine desenli parçadan daha iyi çalışır.',
          ],
          tip: 'İnce çizgili koyu renk gömlek oval vücudu hem şık hem ince gösterir: '
              'koyu zemin + ince çizgi = maksimum dikey hat.',
        ),
      BodyType.athletic => const StyleLesson(
          id: 'pattern_athletic',
          category: StyleLessonCategory.pattern,
          title: 'Atletik: Desen Özgürlüğü',
          summary:
              'Atletik vücut desen konusunda en az kısıtlamaya sahip tiptir.',
          bullets: [
            'Yatay çizgiler bile atletik vücutta uyumlu ve şık görünür.',
            'Büyük baskı ve bold desen, atletik yapıya güçlü ve iddialı bir görünüm katar.',
            'Ekose ve plaid düzenli bir görünüm için harika seçimdir.',
            'Desen üstte veya altta eşit özgürlükle kullanılabilir.',
            'Karmaşık çok renkli desenler iyi duran yapı sayesinde taşınabilir.',
          ],
          tip: 'Büyük ekose gömlek veya grafik baskılı tişört: atletik vücudun desen playground\'ı.',
        ),
    };
  }

  static StyleLesson _patternMixingLesson() => const StyleLesson(
        id: 'pattern_mixing',
        category: StyleLessonCategory.pattern,
        title: 'Desen Karıştırmanın 3 Altın Kuralı',
        summary:
            'Birden fazla desen aynı kombinasyonda çarpışmak yerine uyum yaratabilir.',
        bullets: [
          'Kural 1 — Ölçek farkı: büyük + küçük desen karıştır; iki büyük veya iki küçük çarpışır.',
          'Kural 2 — Renk uyumu: her iki desende en az bir ortak renk bulunmalı.',
          'Kural 3 — Biri lider, biri yardımcı: bir desen baskın, diğeri sade olsun.',
          'En güvenli mix: çizgili + solid (çizginin kendisi de bir desen sayılır).',
          'İkinci güvenli: ince ekose + düz çizgili — iki düzenli ama farklı ölçek.',
        ],
        tip: 'İlk desen mix\'ini dene: ince çizgili gömlek + orta ölçek ekose ceket. '
            'Ortak renk + ölçek farkı = iki kural sağlandı.',
      );

  static StyleLesson _patternScaleLesson() => const StyleLesson(
        id: 'pattern_scale',
        category: StyleLessonCategory.pattern,
        title: 'Desen Ölçeği Nasıl Seçilir?',
        summary:
            'Desenin boyutu kadar türü de bir mesaj taşır.',
        bullets: [
          'Küçük (micro) desen — mesafeden solid gibi görünür, yakında ortaya çıkar. Sofistike.',
          'Orta desen — en çok yönlü: casual ve smart casual\'ın ikisinde çalışır.',
          'Büyük (bold) desen — güçlü bir statement yapar; geri kalanı solid tut.',
          'Büyük vücut tipleri büyük deseni küçük vücut tiplerine göre daha rahat taşır.',
          'Desen ölçeği renk değerine paralel yürür: açık zemin hafif, koyu zemin ağır hissettirir.',
        ],
        tip: 'Emin değilsen her zaman orta ölçek deseni seç. Hiç yanıltmaz.',
      );
}
