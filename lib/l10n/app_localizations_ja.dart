// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '抽選ルーレット';

  @override
  String get wheelTab => 'ルーレット';

  @override
  String get settingsTab => '設定';

  @override
  String get createWheel => 'ルーレット作成';

  @override
  String get editWheel => 'ルーレット編集';

  @override
  String get deleteWheel => 'ルーレット削除';

  @override
  String get batchDelete => '一括削除';

  @override
  String get preview => 'プレビュー';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '確認';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get wheelTitle => 'ルーレットタイトル';

  @override
  String get wheelTitleHint => 'タイトルを入力';

  @override
  String get wheelStyle => 'スタイル';

  @override
  String get wheelSize => 'サイズ';

  @override
  String get wheelForm => '形式';

  @override
  String get spinDuration => '回転時間(秒)';

  @override
  String get spinSpeed => '回転速度';

  @override
  String get pointerPosition => 'ポインター位置';

  @override
  String get showResult => '結果を表示';

  @override
  String get enableSound => '効果音を有効にする';

  @override
  String get segments => 'セグメント';

  @override
  String get addSegment => 'セグメント追加';

  @override
  String get segmentLabel => '賞品名';

  @override
  String get segmentLabelHint => '賞品名を入力';

  @override
  String get segmentProbability => '確率(%)';

  @override
  String get segmentColor => '色';

  @override
  String get segmentRatio => '面積比率';

  @override
  String get segmentIcon => 'アイコン';

  @override
  String get deleteSegment => '削除';

  @override
  String get noWheels => 'ルーレットがありません。ボタンをタップして作成してください。';

  @override
  String get deleteConfirm => '削除確認';

  @override
  String get deleteWheelMsg => 'このルーレットを削除しますか？この操作は取り消せません。';

  @override
  String batchDeleteMsg(int count) {
    return '選択した$count個のルーレットを削除しますか？';
  }

  @override
  String selected(int count) {
    return '$count個選択中';
  }

  @override
  String get selectAll => 'すべて選択';

  @override
  String get deselectAll => '選択解除';

  @override
  String get theme => 'テーマ';

  @override
  String get language => '言語';

  @override
  String get aboutApp => 'アプリについて';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get version => 'バージョン';

  @override
  String get appDescription => 'カスタマイズ可能な抽選ルーレットアプリ。賞品、確率、色などを自由に設定できます。';

  @override
  String get developer => '開発者';

  @override
  String get spinTheWheel => '回す';

  @override
  String get congratulations => 'おめでとうございます';

  @override
  String youWon(String prize) {
    return '当選：$prize';
  }

  @override
  String get spinAgain => 'もう一度';

  @override
  String get close => '閉じる';

  @override
  String get validationRequired => 'この項目は必須です';

  @override
  String get validationMinSegments => '最低2つのセグメントが必要です';

  @override
  String get validationProbability => '確率の合計は100%である必要があります';

  @override
  String get styleClassic => 'クラシック';

  @override
  String get styleNeon => 'ネオン';

  @override
  String get styleCandy => 'キャンディ';

  @override
  String get styleElegant => 'エレガント';

  @override
  String get styleGradient => 'グラデーション';

  @override
  String get styleRetro => 'レトロ';

  @override
  String get styleOcean => 'オーシャン';

  @override
  String get styleSunset => 'サンセット';

  @override
  String get sizeSmall => '小';

  @override
  String get sizeMedium => '中';

  @override
  String get sizeLarge => '大';

  @override
  String get formStandard => '標準';

  @override
  String get formPetal => '花びら';

  @override
  String get formStar => '星形';

  @override
  String get formPolygon => 'ポリゴン';

  @override
  String get pointerTop => '上';

  @override
  String get pointerRight => '右';

  @override
  String get speedSlow => '遅い';

  @override
  String get speedNormal => '普通';

  @override
  String get speedFast => '速い';

  @override
  String get createdAt => '作成日';

  @override
  String get updatedAt => '更新日';

  @override
  String totalSegments(int count) {
    return '$count個の賞品';
  }

  @override
  String get savedSuccess => '保存しました';

  @override
  String get deletedSuccess => '削除しました';

  @override
  String get colorPicker => '色を選択';

  @override
  String get probabilityAutoBalance => '確率を均等にする';

  @override
  String get ratioAutoBalance => '比率を均等にする';

  @override
  String get spinRecords => '抽選履歴';

  @override
  String get noRecords => '抽選履歴がありません';

  @override
  String get clearAllRecords => '全履歴を削除';

  @override
  String get clearRecordsMsg => 'このルーレットの全抽選履歴を削除しますか？';

  @override
  String get deleteRecordMsg => 'この抽選記録を削除しますか？';

  @override
  String get recordPrize => '賞品';

  @override
  String get recordTime => '時間';

  @override
  String recordIndex(int index) {
    return '第$index回';
  }

  @override
  String get mode3D => '3Dモード';

  @override
  String get backgroundImage => '背景画像';

  @override
  String get pickImage => '画像を選択';

  @override
  String get clearImage => '画像を削除';

  @override
  String get mode2D => '2D';

  @override
  String get mode3DLabel => '3D';

  @override
  String get styleMetallic => 'メタリック';

  @override
  String get stylePastel => 'パステル';

  @override
  String get styleDark => 'ダーク';

  @override
  String get styleRainbow => 'レインボー';

  @override
  String get bgBlur => 'ガウスぼかし';

  @override
  String get bgBlurIntensity => 'ぼかし強度';

  @override
  String get bgOpacity => '背景の不透明度';

  @override
  String get bgOverlayColor => 'オーバーレイ色';
}
