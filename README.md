<div style="text-align: center;">

<img src="https://img.icons8.com/color/128/prize-wheel.png" alt="PrizeWheel Logo" width="128" height="128">

# 🎰 PrizeWheel 抽奖转盘

一款精美的自定义抽奖转盘应用，支持丰富的转盘样式、概率控制、连抽模式和完整的抽奖记录。

你的口袋里的幸运转盘 🎡

无论是聚会游戏、课堂点名还是日常决策，PrizeWheel 都能让随机变得有趣。<br>
完全本地运行，数据不上传，隐私有保障。

简体中文 · [English](README_EN.md)

[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=flat-square&logo=flutter)](.)
[![Flutter](https://img.shields.io/badge/Flutter-3.16+-blue?style=flat-square&logo=flutter)](.)
[![Dart](https://img.shields.io/badge/Dart-3.11+-blue?style=flat-square&logo=dart)](.)
[![License](https://img.shields.io/badge/License-MIT-blueviolet?style=flat-square)](.)
[![Material Design 3](https://img.shields.io/badge/Material%20Design%203-enabled-purple?style=flat-square&logo=materialdesign)](.)

</div>

---

<details>
<summary>目录</summary>

- [为什么选择 PrizeWheel？](#为什么选择-prizewheel)
- [功能特性](#功能特性)
- [快速开始](#快速开始)
  - [环境要求](#环境要求)
  - [从源码构建](#从源码构建)
- [项目结构](#项目结构)
- [国际化](#国际化)
- [参与贡献](#参与贡献)
- [常见问题](#常见问题)
- [许可证](#许可证)
- [致谢](#致谢)

</details>

## 为什么选择 PrizeWheel？

市面上的抽奖转盘应用要么广告满天飞，要么功能单一。PrizeWheel 不一样——它开源、免费、无广告，同时提供了极其丰富的自定义能力。

你可以自由定义奖品、概率、颜色、转盘样式，甚至指针风格。支持单次抽奖和连抽模式，完整的抽奖记录和统计分析让每一次抽奖都有据可查。

## 功能特性

| 特性                   | 说明                                         |
|:---------------------|:-------------------------------------------|
| 🎨 12 种转盘风格          | 经典、霓虹、糖果、优雅、渐变、复古、海洋、日落、金属、柔和、暗黑、彩虹        |
| 🔷 4 种转盘形式           | 标准、花瓣、星形、多边形                               |
| 📐 3 种转盘尺寸           | 小、中、大，适配不同屏幕                               |
| 🎯 5 种指针风格           | 经典、箭头、钻石、圆点、旗帜，指针可放置在上下左右四个方向              |
| 🎲 概率控制              | 每个奖品独立设置中奖概率和面积比例，支持一键自动均分                 |
| 🔄 连抽模式              | 支持 3/5/10 次预设连抽或自定义次数（最多 999 次），可跳过动画快速出结果 |
| 🃏 翻牌揭晓动画            | 连抽结果以精美的翻牌动画逐一揭晓，附带奖品统计摘要                  |
| 📊 抽奖记录              | 完整记录每次抽奖结果，支持按批次分组查看、统计分析、批量删除             |
| 🖼️ 自定义背景            | 支持设置背景图片，可调节高斯模糊、透明度和叠加色调                  |
| 🧊 3D 模式             | 开启后转盘具有 3D 透视效果，支持手势倾斜交互                   |
| 🔊 音效支持              | 可开关旋转音效                                    |
| 🌍 多语言界面             | 支持简体中文、繁體中文、English、Français、Deutsch、日本語   |
| 🎨 Material Design 3 | 简洁现代的 UI，支持亮色/暗色/跟随系统主题切换                  |
| 💾 本地持久化             | 所有数据存储在本地 SQLite 数据库，无需网络，隐私安全             |

## 快速开始

### 环境要求

| 依赖          | 版本                    |
|:------------|:----------------------|
| Flutter     | ≥ 3.16.0              |
| Dart        | ≥ 3.11.0              |
| Android SDK | API 21+（Android 5.0+） |

### 从源码构建

1. 克隆仓库：

    ```bash
    git clone https://github.com/your-username/PrizeWheel.git
    cd PrizeWheel
    ```

2. 安装依赖：

    ```bash
    flutter pub get
    ```

3. 运行应用：

    ```bash
    flutter run
    ```

4. 构建 Release APK：

    ```bash
    flutter build apk --release
    ```

## 项目结构

```
lib/
├── db/                # SQLite 数据库（sqflite）
├── l10n/              # 国际化（ARB 文件 + 生成的 Dart 代码）
├── models/            # 数据模型（转盘、奖品、抽奖记录）
├── providers/         # Provider 状态管理（设置、转盘列表）
├── screens/           # 页面
│   ├── home_page.dart          # 首页（底部导航）
│   ├── wheel_list_page.dart    # 转盘列表（创建/编辑/删除/批量操作）
│   ├── wheel_edit_page.dart    # 转盘编辑（样式/奖品/概率/背景等）
│   ├── wheel_spin_page.dart    # 抽奖页面（单抽/连抽/结果揭晓）
│   ├── spin_records_page.dart  # 抽奖记录（分组/统计/批量删除）
│   └── settings_page.dart      # 设置（主题/语言/关于）
├── widgets/           # 可复用组件
│   ├── spinning_wheel.dart     # 旋转转盘核心组件（动画/3D/手势）
│   ├── wheel_painter.dart      # 转盘绘制（12 种风格/4 种形式）
│   └── color_picker_dialog.dart # 颜色选择器
└── main.dart          # 入口文件
```

- 状态管理：[Provider](https://pub.dev/packages/provider)
- 本地存储：SQLite（[sqflite](https://pub.dev/packages/sqflite)）
- 国际化：Flutter 内置 `flutter_localizations` + ARB 文件
- 图片选择：[image_picker](https://pub.dev/packages/image_picker)

## 国际化

PrizeWheel 开箱即用支持 6 种语言：

| 语言       | 代码        |
|:---------|:----------|
| 简体中文     | `zh`      |
| 繁體中文     | `zh_Hant` |
| English  | `en`      |
| Français | `fr`      |
| Deutsch  | `de`      |
| 日本語      | `ja`      |

添加新语言：在 `lib/l10n/` 下创建 `app_<语言代码>.arb` 文件，然后运行 `flutter gen-l10n`。

## 参与贡献

我们欢迎各种形式的贡献——Bug 修复、新功能、翻译、文档改进。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: 添加某个功能'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 发起 Pull Request

提交前请确保代码风格一致，并通过 `flutter analyze` 检查。

## 常见问题

**Q：支持哪些平台？**
A：目前主要支持 Android 和 iOS。项目基于 Flutter 构建，理论上也可以运行在 Web、macOS、Windows 和 Linux 上。

**Q：数据存储在哪里？**
A：所有数据（转盘配置、抽奖记录）存储在设备本地的 SQLite 数据库中，不会上传到任何服务器。

**Q：最多可以添加多少个奖品？**
A：没有硬性限制，但建议不超过 20 个以获得最佳视觉效果。至少需要 2 个奖品才能开始抽奖。

**Q：连抽最多支持多少次？**
A：最多支持 999 次连抽。大量连抽时建议开启"跳过抽奖过程"以快速获取结果。

**Q：概率不等于 100% 怎么办？**
A：保存时系统会自动按比例归一化，确保概率总和为 100%。

**Q：背景图片支持什么格式？**
A：支持设备相册中的常见图片格式（JPG、PNG 等），选择后会自动压缩并保存到应用目录。

## 许可证

本项目基于 [MIT 许可证](https://opensource.org/licenses/MIT) 发布。

## 致谢

PrizeWheel 基于以下优秀的开源项目构建：

- [Flutter](https://flutter.dev/) — UI 框架
- [Provider](https://pub.dev/packages/provider) — 状态管理
- [sqflite](https://pub.dev/packages/sqflite) — SQLite 数据库
- [image_picker](https://pub.dev/packages/image_picker) — 图片选择
- [shared_preferences](https://pub.dev/packages/shared_preferences) — 轻量级键值存储

---

<div style="text-align: center;">

用 ❤️ 打造的抽奖转盘

</div>
