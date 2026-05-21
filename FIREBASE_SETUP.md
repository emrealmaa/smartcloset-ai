# SmartCloset AI — Firebase Kurulum Kılavuzu

## 1. Firebase Projesi Oluştur

1. https://console.firebase.google.com → "Proje Oluştur"
2. Proje adı: `smartcloset-ai`
3. Google Analytics: İsteğe bağlı (açık bırakabilirsin)

---

## 2. Android Uygulamasını Ekle

Firebase Console → Proje Ayarları → "Android Uygulaması Ekle"

- **Paket adı:** `com.smartcloset.ai`
- **Uygulama takma adı:** SmartCloset AI
- **SHA-1:** (şimdilik boş bırakabilirsin)

`google-services.json` dosyasını indir ve şuraya koy:
```
android/app/google-services.json
```

---

## 3. Android Gradle Ayarları

### `android/build.gradle` → dependencies bloğuna ekle:
```groovy
classpath 'com.google.gms:google-services:4.4.1'
```

### `android/app/build.gradle` → en üste ekle:
```groovy
apply plugin: 'com.google.gms.google-services'
```

### `android/app/build.gradle` → defaultConfig:
```groovy
minSdkVersion 21   // Firebase için minimum 21
```

---

## 4. FlutterFire CLI ile Firebase Options Oluştur

```bash
# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Projeyi bağla (firebase_options.dart otomatik oluşur)
flutterfire configure --project=smartcloset-ai
```

Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturur.

---

## 5. main.dart'ta Firebase'i Aktive Et

`lib/main.dart` dosyasında şu iki satırı uncomment et:

```dart
import 'firebase_options.dart';  // ← yorum satırını kaldır

// ve:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);  // ← yorum satırını kaldır
```

---

## 6. Firebase Authentication'ı Aç

Firebase Console → Authentication → "Başlayın"
- **Email/Password** provider'ı etkinleştir ✅
- Email link (passwordless): kapalı bırak

---

## 7. Email Doğrulama Şablonunu Özelleştir (Opsiyonel ama Önerilen)

Firebase Console → Authentication → Templates → Email Verification

Şablonu SmartCloset AI markasıyla özelleştirebilirsin:
- **Konu:** SmartCloset AI - Mail Adresini Doğrula
- **Gönderen adı:** SmartCloset AI

---

## 8. Test Et

```bash
flutter run
```

Kayıt ekranında gerçek bir mail adresi gir.
→ Mail gelecek → Linke tıkla → Uygulama otomatik giriş yapacak ✅

---

## Klasör Yapısı

```
lib/
├── main.dart                    # Entry point
├── firebase_options.dart        # [FlutterFire CLI üretir]
├── theme/
│   └── app_theme.dart           # Siyah + neon yeşil tema
├── services/
│   └── auth_service.dart        # Firebase Auth servisi
├── widgets/
│   └── shared_widgets.dart      # Ortak UI bileşenleri
└── screens/
    ├── auth/
    │   ├── splash_screen.dart       # İlk açılış + auth kontrolü
    │   ├── login_screen.dart        # Giriş ekranı
    │   ├── register_screen.dart     # Kayıt ekranı
    │   ├── verify_email_screen.dart # Mail doğrulama bekleme ekranı ⭐
    │   └── forgot_password_screen.dart
    ├── home/
    │   ├── home_screen.dart         # Tab navigation
    │   └── profile_tab.dart
    ├── closet/
    │   └── closet_screen.dart       # Gardırop (Faz 2'de doldurulacak)
    ├── outfit/
    │   └── outfit_screen.dart       # Kombin (Faz 3'te doldurulacak)
    └── shop/
        └── shop_screen.dart         # Keşfet (Faz 4'te doldurulacak)
```

---

## Auth Flow Şeması

```
Uygulama Açılır
      ↓
  SplashScreen
      ↓
  user == null? → LoginScreen
      ↓
  !emailVerified? → VerifyEmailScreen
      ↓
  HomeScreen (Gardırop, Kombin, Keşfet, Profil)
```

## Email Verification Flow

```
Kayıt Ol (RegisterScreen)
      ↓
Firebase.createUser() → Firebase doğrulama maili gönderir
      ↓
VerifyEmailScreen göster
      ↓
Her 3 saniyede checkEmailVerified() çağır
      ↓
Mail doğrulandı? → HomeScreen
```
