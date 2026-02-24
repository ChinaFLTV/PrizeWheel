---

<p align="center">
  <img src="https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/logo/prize_wheel.png" alt="PrizeWheel Logo" width="128" height="128">
</p>

<h1 align="center">🎰 PrizeWheel</h1>

<p align="center">
  A beautiful, fully customizable prize wheel app with rich styles, probability control, multi-spin mode, and complete spin history.
</p>

<p align="center">
  Your pocket lucky wheel 🎡
</p>

<p align="center">
  Whether it's party games, classroom picks, or everyday decisions, PrizeWheel makes randomness fun.<br>
  Runs entirely on-device. No data uploaded. Your privacy is safe.
</p>

<p align="center">
  <a href="README.md">简体中文</a> · English
</p>

<p align="center">
  <a href="https://github.com/ChinaFLTV/PrizeWheel/releases"><img src="https://img.shields.io/github/v/release/ChinaFLTV/PrizeWheel?style=flat-square&logo=github&label=Release" alt="Release"></a>
  <a href="https://github.com/ChinaFLTV/PrizeWheel/stargazers"><img src="https://img.shields.io/github/stars/ChinaFLTV/PrizeWheel?style=flat-square&logo=github" alt="Stars"></a>
  <a href="https://github.com/ChinaFLTV/PrizeWheel/network/members"><img src="https://img.shields.io/github/forks/ChinaFLTV/PrizeWheel?style=flat-square&logo=github" alt="Forks"></a>
  <a href="https://github.com/ChinaFLTV/PrizeWheel/issues"><img src="https://img.shields.io/github/issues/ChinaFLTV/PrizeWheel?style=flat-square" alt="Issues"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blueviolet?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=flat-square&logo=flutter" alt="Platform">
  <img src="https://img.shields.io/badge/Flutter-3.16+-blue?style=flat-square&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.11+-blue?style=flat-square&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Material%20Design%203-enabled-purple?style=flat-square&logo=materialdesign" alt="Material Design 3">
</p>

---

<details>
<summary>Table of Contents</summary>

- [Why PrizeWheel?](#why-prizewheel)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Build from Source](#build-from-source)
- [Architecture](#architecture)
- [Internationalization](#internationalization)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)
- [Acknowledgments](#acknowledgments)

</details>

## Why PrizeWheel?

Most prize wheel apps out there are either ad-ridden or too basic. PrizeWheel is different — it's open-source, free, ad-free, and packed with customization options.

Define your own prizes, probabilities, colors, wheel styles, and even pointer designs. With single spin and multi-spin modes, plus full spin history and statistics, every spin is tracked and meaningful.

## Features

| Feature                  | Description                                                                                       |
|:-------------------------|:--------------------------------------------------------------------------------------------------|
| 🎨 12 Wheel Styles       | Classic, Neon, Candy, Elegant, Gradient, Retro, Ocean, Sunset, Metallic, Pastel, Dark, Rainbow    |
| 🔷 4 Wheel Forms         | Standard, Petal, Star, Polygon                                                                    |
| 📐 3 Wheel Sizes         | Small, Medium, Large — adapts to different screens                                                |
| 🎯 5 Pointer Styles      | Classic, Arrow, Diamond, Dot, Flag — positionable at top, right, bottom, or left                  |
| 🎲 Probability Control   | Set individual probability and area ratio per prize, with one-tap auto-balance                    |
| 🔄 Multi-Spin Mode       | Preset 3/5/10 spins or custom count (up to 999), with optional animation skip for instant results |
| 🃏 Card Reveal Animation | Multi-spin results revealed one by one with elegant flip animations and prize summary             |
| 📊 Spin Records          | Full history of every spin, grouped by batch, with statistics and batch delete                    |
| 🖼️ Custom Background    | Set a background image with adjustable Gaussian blur, opacity, and overlay tint                   |
| 🧊 3D Mode               | Enables 3D perspective on the wheel with gesture-based tilt interaction                           |
| 🔊 Sound Effects         | Toggle spin sound effects on or off                                                               |
| 🌍 Multilingual UI       | Simplified Chinese, Traditional Chinese, English, French, German, Japanese                        |
| 🎨 Material Design 3     | Clean, modern UI with light/dark/system theme modes                                               |
| 💾 Local Persistence     | All data stored in local SQLite database — no network required, fully private                     |

## Screenshots

|                                                                                                                |                                                                                                                |                                                                                                                |
|:--------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------:|
| ![Screenshot 1](https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/screenshots/screenshot-1.jpg) | ![Screenshot 2](https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/screenshots/screenshot-2.jpg) | ![Screenshot 3](https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/screenshots/screenshot-3.jpg) |
| ![Screenshot 4](https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/screenshots/screenshot-4.jpg) | ![Screenshot 5](https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/screenshots/screenshot-5.jpg) | ![Screenshot 6](https://raw.githubusercontent.com/ChinaFLTV/PrizeWheel/main/docs/screenshots/screenshot-6.jpg) |

## Getting Started

### Prerequisites

| Requirement | Version                |
|:------------|:-----------------------|
| Flutter     | ≥ 3.16.0               |
| Dart        | ≥ 3.11.0               |
| Android SDK | API 21+ (Android 5.0+) |

### Installation

Download the latest APK from the [Releases](https://github.com/ChinaFLTV/PrizeWheel/releases) page and install it on your Android device.

### Build from Source

1. Clone the repository:

    ```bash
    git clone https://github.com/ChinaFLTV/PrizeWheel.git
    cd PrizeWheel
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Run the app:

    ```bash
    flutter run
    ```

4. Build a release APK:

    ```bash
    flutter build apk --release
    ```

## Architecture

```
lib/
├── db/                # SQLite via sqflite
├── l10n/              # Localization (ARB files + generated Dart)
├── models/            # Data models (Wheel, Segment, SpinRecord)
├── providers/         # Provider state management (Settings, WheelList)
├── screens/           # Pages
│   ├── home_page.dart          # Home (bottom navigation)
│   ├── wheel_list_page.dart    # Wheel list (create/edit/delete/batch ops)
│   ├── wheel_edit_page.dart    # Wheel editor (style/prizes/probability/background)
│   ├── wheel_spin_page.dart    # Spin page (single/multi-spin/result reveal)
│   ├── spin_records_page.dart  # Spin records (grouping/stats/batch delete)
│   └── settings_page.dart      # Settings (theme/language/about)
├── widgets/           # Reusable components
│   ├── spinning_wheel.dart     # Core spinning wheel (animation/3D/gestures)
│   ├── wheel_painter.dart      # Wheel rendering (12 styles/4 forms)
│   └── color_picker_dialog.dart # Color picker
└── main.dart          # Entry point
```

- State management: [Provider](https://pub.dev/packages/provider)
- Local storage: SQLite via [sqflite](https://pub.dev/packages/sqflite)
- Internationalization: Flutter built-in `flutter_localizations` + ARB files
- Image picking: [image_picker](https://pub.dev/packages/image_picker)

## Internationalization

PrizeWheel supports 6 languages out of the box:

| Language | Code      |
|:---------|:----------|
| 简体中文     | `zh`      |
| 繁體中文     | `zh_Hant` |
| English  | `en`      |
| Français | `fr`      |
| Deutsch  | `de`      |
| 日本語      | `ja`      |

To add a new language, create an `app_<code>.arb` file in `lib/l10n/` and run `flutter gen-l10n`.

## Contributing

We welcome contributions of all kinds — bug fixes, new features, translations, documentation improvements.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure your code follows the existing style and passes `flutter analyze` before submitting.

## FAQ

**Q: What platforms are supported?**
A: Primarily Android and iOS. Built with Flutter, so it can theoretically run on Web, macOS, Windows, and Linux as well.

**Q: Where is data stored?**
A: All data (wheel configurations, spin records) is stored in a local SQLite database on your device. Nothing is uploaded to any server.

**Q: How many prizes can I add?**
A: There's no hard limit, but we recommend no more than 20 for the best visual experience. A minimum of 2 prizes is required to spin.

**Q: What's the maximum multi-spin count?**
A: Up to 999 spins. For large counts, enable "Skip spin animation" for instant results.

**Q: What if probabilities don't add up to 100%?**
A: The app automatically normalizes probabilities proportionally when saving, ensuring they sum to exactly 100%.

**Q: What image formats are supported for backgrounds?**
A: Common formats from your device gallery (JPG, PNG, etc.). Images are automatically compressed and saved to the app directory.

## License

This project is released under the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

PrizeWheel is built on these great open-source projects:

- [Flutter](https://flutter.dev/) — UI framework
- [Provider](https://pub.dev/packages/provider) — State management
- [sqflite](https://pub.dev/packages/sqflite) — SQLite database
- [image_picker](https://pub.dev/packages/image_picker) — Image picking
- [shared_preferences](https://pub.dev/packages/shared_preferences) — Lightweight key-value storage

---

*Made with ❤️ for fun randomness*
