import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'抽奖转盘'**
  String get appTitle;

  /// No description provided for @wheelTab.
  ///
  /// In zh, this message translates to:
  /// **'转盘'**
  String get wheelTab;

  /// No description provided for @settingsTab.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTab;

  /// No description provided for @createWheel.
  ///
  /// In zh, this message translates to:
  /// **'新建转盘'**
  String get createWheel;

  /// No description provided for @editWheel.
  ///
  /// In zh, this message translates to:
  /// **'编辑转盘'**
  String get editWheel;

  /// No description provided for @deleteWheel.
  ///
  /// In zh, this message translates to:
  /// **'删除转盘'**
  String get deleteWheel;

  /// No description provided for @batchDelete.
  ///
  /// In zh, this message translates to:
  /// **'批量删除'**
  String get batchDelete;

  /// No description provided for @preview.
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get preview;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @wheelTitle.
  ///
  /// In zh, this message translates to:
  /// **'转盘标题'**
  String get wheelTitle;

  /// No description provided for @wheelTitleHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入转盘标题'**
  String get wheelTitleHint;

  /// No description provided for @wheelStyle.
  ///
  /// In zh, this message translates to:
  /// **'转盘风格'**
  String get wheelStyle;

  /// No description provided for @wheelSize.
  ///
  /// In zh, this message translates to:
  /// **'转盘尺寸'**
  String get wheelSize;

  /// No description provided for @wheelForm.
  ///
  /// In zh, this message translates to:
  /// **'转盘形式'**
  String get wheelForm;

  /// No description provided for @spinDuration.
  ///
  /// In zh, this message translates to:
  /// **'旋转时长(秒)'**
  String get spinDuration;

  /// No description provided for @spinSpeed.
  ///
  /// In zh, this message translates to:
  /// **'旋转速度'**
  String get spinSpeed;

  /// No description provided for @pointerPosition.
  ///
  /// In zh, this message translates to:
  /// **'指针位置'**
  String get pointerPosition;

  /// No description provided for @showResult.
  ///
  /// In zh, this message translates to:
  /// **'显示结果弹窗'**
  String get showResult;

  /// No description provided for @enableSound.
  ///
  /// In zh, this message translates to:
  /// **'启用音效'**
  String get enableSound;

  /// No description provided for @segments.
  ///
  /// In zh, this message translates to:
  /// **'转盘块'**
  String get segments;

  /// No description provided for @addSegment.
  ///
  /// In zh, this message translates to:
  /// **'添加转盘块'**
  String get addSegment;

  /// No description provided for @segmentLabel.
  ///
  /// In zh, this message translates to:
  /// **'奖品名称'**
  String get segmentLabel;

  /// No description provided for @segmentLabelHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入奖品名称'**
  String get segmentLabelHint;

  /// No description provided for @segmentProbability.
  ///
  /// In zh, this message translates to:
  /// **'中奖概率(%)'**
  String get segmentProbability;

  /// No description provided for @segmentColor.
  ///
  /// In zh, this message translates to:
  /// **'颜色'**
  String get segmentColor;

  /// No description provided for @segmentRatio.
  ///
  /// In zh, this message translates to:
  /// **'面积比例'**
  String get segmentRatio;

  /// No description provided for @segmentIcon.
  ///
  /// In zh, this message translates to:
  /// **'图标'**
  String get segmentIcon;

  /// No description provided for @deleteSegment.
  ///
  /// In zh, this message translates to:
  /// **'删除此项'**
  String get deleteSegment;

  /// No description provided for @noWheels.
  ///
  /// In zh, this message translates to:
  /// **'暂无转盘，点击右下角按钮创建'**
  String get noWheels;

  /// No description provided for @deleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get deleteConfirm;

  /// No description provided for @deleteWheelMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这个转盘吗？此操作不可撤销。'**
  String get deleteWheelMsg;

  /// No description provided for @batchDeleteMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 个转盘吗？'**
  String batchDeleteMsg(int count);

  /// No description provided for @selected.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 项'**
  String selected(int count);

  /// No description provided for @selectAll.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In zh, this message translates to:
  /// **'取消全选'**
  String get deselectAll;

  /// No description provided for @theme.
  ///
  /// In zh, this message translates to:
  /// **'应用主题'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'应用语言'**
  String get language;

  /// No description provided for @aboutApp.
  ///
  /// In zh, this message translates to:
  /// **'关于应用'**
  String get aboutApp;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get themeDark;

  /// No description provided for @version.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// No description provided for @appDescription.
  ///
  /// In zh, this message translates to:
  /// **'一款精美的自定义抽奖转盘应用，支持自定义奖品、概率、颜色等参数。'**
  String get appDescription;

  /// No description provided for @developer.
  ///
  /// In zh, this message translates to:
  /// **'开发者'**
  String get developer;

  /// No description provided for @spinTheWheel.
  ///
  /// In zh, this message translates to:
  /// **'开始抽奖'**
  String get spinTheWheel;

  /// No description provided for @congratulations.
  ///
  /// In zh, this message translates to:
  /// **'恭喜'**
  String get congratulations;

  /// No description provided for @youWon.
  ///
  /// In zh, this message translates to:
  /// **'你抽中了：{prize}'**
  String youWon(String prize);

  /// No description provided for @spinAgain.
  ///
  /// In zh, this message translates to:
  /// **'再转一次'**
  String get spinAgain;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @validationRequired.
  ///
  /// In zh, this message translates to:
  /// **'此项不能为空'**
  String get validationRequired;

  /// No description provided for @validationMinSegments.
  ///
  /// In zh, this message translates to:
  /// **'至少需要2个转盘块'**
  String get validationMinSegments;

  /// No description provided for @validationProbability.
  ///
  /// In zh, this message translates to:
  /// **'概率总和必须为100%'**
  String get validationProbability;

  /// No description provided for @styleClassic.
  ///
  /// In zh, this message translates to:
  /// **'经典'**
  String get styleClassic;

  /// No description provided for @styleNeon.
  ///
  /// In zh, this message translates to:
  /// **'霓虹'**
  String get styleNeon;

  /// No description provided for @styleCandy.
  ///
  /// In zh, this message translates to:
  /// **'糖果'**
  String get styleCandy;

  /// No description provided for @styleElegant.
  ///
  /// In zh, this message translates to:
  /// **'优雅'**
  String get styleElegant;

  /// No description provided for @styleGradient.
  ///
  /// In zh, this message translates to:
  /// **'渐变'**
  String get styleGradient;

  /// No description provided for @styleRetro.
  ///
  /// In zh, this message translates to:
  /// **'复古'**
  String get styleRetro;

  /// No description provided for @styleOcean.
  ///
  /// In zh, this message translates to:
  /// **'海洋'**
  String get styleOcean;

  /// No description provided for @styleSunset.
  ///
  /// In zh, this message translates to:
  /// **'日落'**
  String get styleSunset;

  /// No description provided for @sizeSmall.
  ///
  /// In zh, this message translates to:
  /// **'小'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In zh, this message translates to:
  /// **'中'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In zh, this message translates to:
  /// **'大'**
  String get sizeLarge;

  /// No description provided for @formStandard.
  ///
  /// In zh, this message translates to:
  /// **'标准'**
  String get formStandard;

  /// No description provided for @formPetal.
  ///
  /// In zh, this message translates to:
  /// **'花瓣'**
  String get formPetal;

  /// No description provided for @formStar.
  ///
  /// In zh, this message translates to:
  /// **'星形'**
  String get formStar;

  /// No description provided for @formPolygon.
  ///
  /// In zh, this message translates to:
  /// **'多边形'**
  String get formPolygon;

  /// No description provided for @pointerTop.
  ///
  /// In zh, this message translates to:
  /// **'顶部'**
  String get pointerTop;

  /// No description provided for @pointerRight.
  ///
  /// In zh, this message translates to:
  /// **'右侧'**
  String get pointerRight;

  /// No description provided for @speedSlow.
  ///
  /// In zh, this message translates to:
  /// **'慢速'**
  String get speedSlow;

  /// No description provided for @speedNormal.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get speedNormal;

  /// No description provided for @speedFast.
  ///
  /// In zh, this message translates to:
  /// **'快速'**
  String get speedFast;

  /// No description provided for @createdAt.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In zh, this message translates to:
  /// **'更新时间'**
  String get updatedAt;

  /// No description provided for @totalSegments.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个奖品'**
  String totalSegments(int count);

  /// No description provided for @savedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get savedSuccess;

  /// No description provided for @deletedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'删除成功'**
  String get deletedSuccess;

  /// No description provided for @colorPicker.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get colorPicker;

  /// No description provided for @probabilityAutoBalance.
  ///
  /// In zh, this message translates to:
  /// **'自动均分概率'**
  String get probabilityAutoBalance;

  /// No description provided for @ratioAutoBalance.
  ///
  /// In zh, this message translates to:
  /// **'自动均分比例'**
  String get ratioAutoBalance;

  /// No description provided for @spinRecords.
  ///
  /// In zh, this message translates to:
  /// **'抽奖记录'**
  String get spinRecords;

  /// No description provided for @noRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无抽奖记录'**
  String get noRecords;

  /// No description provided for @clearAllRecords.
  ///
  /// In zh, this message translates to:
  /// **'清空全部记录'**
  String get clearAllRecords;

  /// No description provided for @clearRecordsMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定要清空该转盘的所有抽奖记录吗？'**
  String get clearRecordsMsg;

  /// No description provided for @deleteRecordMsg.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除这条抽奖记录吗？'**
  String get deleteRecordMsg;

  /// No description provided for @recordPrize.
  ///
  /// In zh, this message translates to:
  /// **'奖品'**
  String get recordPrize;

  /// No description provided for @recordTime.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get recordTime;

  /// No description provided for @recordIndex.
  ///
  /// In zh, this message translates to:
  /// **'第 {index} 次'**
  String recordIndex(int index);

  /// No description provided for @mode3D.
  ///
  /// In zh, this message translates to:
  /// **'3D模式'**
  String get mode3D;

  /// No description provided for @backgroundImage.
  ///
  /// In zh, this message translates to:
  /// **'背景图片'**
  String get backgroundImage;

  /// No description provided for @pickImage.
  ///
  /// In zh, this message translates to:
  /// **'选择图片'**
  String get pickImage;

  /// No description provided for @clearImage.
  ///
  /// In zh, this message translates to:
  /// **'清除图片'**
  String get clearImage;

  /// No description provided for @mode2D.
  ///
  /// In zh, this message translates to:
  /// **'2D'**
  String get mode2D;

  /// No description provided for @mode3DLabel.
  ///
  /// In zh, this message translates to:
  /// **'3D'**
  String get mode3DLabel;

  /// No description provided for @styleMetallic.
  ///
  /// In zh, this message translates to:
  /// **'金属'**
  String get styleMetallic;

  /// No description provided for @stylePastel.
  ///
  /// In zh, this message translates to:
  /// **'柔和'**
  String get stylePastel;

  /// No description provided for @styleDark.
  ///
  /// In zh, this message translates to:
  /// **'暗黑'**
  String get styleDark;

  /// No description provided for @styleRainbow.
  ///
  /// In zh, this message translates to:
  /// **'彩虹'**
  String get styleRainbow;

  /// No description provided for @bgBlur.
  ///
  /// In zh, this message translates to:
  /// **'高斯模糊'**
  String get bgBlur;

  /// No description provided for @bgBlurIntensity.
  ///
  /// In zh, this message translates to:
  /// **'模糊强度'**
  String get bgBlurIntensity;

  /// No description provided for @bgOpacity.
  ///
  /// In zh, this message translates to:
  /// **'背景透明度'**
  String get bgOpacity;

  /// No description provided for @bgOverlayColor.
  ///
  /// In zh, this message translates to:
  /// **'叠加色调'**
  String get bgOverlayColor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
