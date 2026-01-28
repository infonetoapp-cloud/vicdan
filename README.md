# VİCDAN App

Vicdan Arkadaşı - Modern bir ibadet takip uygulaması.

## Kurulum

1. Flutter bağımlılıklarını yükle:
```bash
flutter pub get
```

2. Font dosyalarını indir ve `assets/fonts/` klasörüne koy:
   - Inter-Regular.ttf
   - Inter-Medium.ttf
   - Inter-SemiBold.ttf
   - Inter-Bold.ttf

3. Uygulamayı çalıştır:
```bash
flutter run
```

## Proje Yapısı

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # App configuration
├── core/
│   └── theme/                # Twilight Garden theme system
├── features/
│   ├── home/                 # Ana ekran (Ağaç Tab)
│   └── tree/                 # Ağaç widget ve animasyonlar
└── shared/
    └── widgets/              # Glassmorphism components
```

## Mimari

- **State Management:** Riverpod
- **Database:** Drift (SQLite)
- **Design System:** Twilight Garden + Glassmorphism
