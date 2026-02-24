// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '抽奖转盘';

  @override
  String get wheelTab => '转盘';

  @override
  String get settingsTab => '设置';

  @override
  String get createWheel => '新建转盘';

  @override
  String get editWheel => '编辑转盘';

  @override
  String get deleteWheel => '删除转盘';

  @override
  String get batchDelete => '批量删除';

  @override
  String get preview => '预览';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get wheelTitle => '转盘标题';

  @override
  String get wheelTitleHint => '请输入转盘标题';

  @override
  String get wheelStyle => '转盘风格';

  @override
  String get wheelSize => '转盘尺寸';

  @override
  String get wheelForm => '转盘形式';

  @override
  String get spinDuration => '旋转时长(秒)';

  @override
  String get spinSpeed => '旋转速度';

  @override
  String get pointerPosition => '指针位置';

  @override
  String get showResult => '显示结果弹窗';

  @override
  String get enableSound => '启用音效';

  @override
  String get segments => '转盘块';

  @override
  String get addSegment => '添加转盘块';

  @override
  String get segmentLabel => '奖品名称';

  @override
  String get segmentLabelHint => '请输入奖品名称';

  @override
  String get segmentProbability => '中奖概率(%)';

  @override
  String get segmentColor => '颜色';

  @override
  String get segmentRatio => '面积比例';

  @override
  String get segmentIcon => '图标';

  @override
  String get deleteSegment => '删除此项';

  @override
  String get noWheels => '暂无转盘，点击右下角按钮创建';

  @override
  String get deleteConfirm => '确认删除';

  @override
  String get deleteWheelMsg => '确定要删除这个转盘吗？此操作不可撤销。';

  @override
  String batchDeleteMsg(int count) {
    return '确定要删除选中的 $count 个转盘吗？';
  }

  @override
  String selected(int count) {
    return '已选择 $count 项';
  }

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String get theme => '应用主题';

  @override
  String get language => '应用语言';

  @override
  String get aboutApp => '关于应用';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get version => '版本';

  @override
  String get appDescription => '一款精美的自定义抽奖转盘应用，支持自定义奖品、概率、颜色等参数。';

  @override
  String get developer => '开发者';

  @override
  String get spinTheWheel => '开始抽奖';

  @override
  String get congratulations => '恭喜';

  @override
  String youWon(String prize) {
    return '你抽中了：$prize';
  }

  @override
  String get spinAgain => '再转一次';

  @override
  String get close => '关闭';

  @override
  String get validationRequired => '此项不能为空';

  @override
  String get validationMinSegments => '至少需要2个转盘块';

  @override
  String get validationProbability => '概率总和必须为100%';

  @override
  String get styleClassic => '经典';

  @override
  String get styleNeon => '霓虹';

  @override
  String get styleCandy => '糖果';

  @override
  String get styleElegant => '优雅';

  @override
  String get styleGradient => '渐变';

  @override
  String get styleRetro => '复古';

  @override
  String get styleOcean => '海洋';

  @override
  String get styleSunset => '日落';

  @override
  String get sizeSmall => '小';

  @override
  String get sizeMedium => '中';

  @override
  String get sizeLarge => '大';

  @override
  String get formStandard => '标准';

  @override
  String get formPetal => '花瓣';

  @override
  String get formStar => '星形';

  @override
  String get formPolygon => '多边形';

  @override
  String get pointerTop => '顶部';

  @override
  String get pointerRight => '右侧';

  @override
  String get speedSlow => '慢速';

  @override
  String get speedNormal => '正常';

  @override
  String get speedFast => '快速';

  @override
  String get createdAt => '创建时间';

  @override
  String get updatedAt => '更新时间';

  @override
  String totalSegments(int count) {
    return '$count 个奖品';
  }

  @override
  String get savedSuccess => '保存成功';

  @override
  String get deletedSuccess => '删除成功';

  @override
  String get colorPicker => '选择颜色';

  @override
  String get probabilityAutoBalance => '自动均分概率';

  @override
  String get ratioAutoBalance => '自动均分比例';

  @override
  String get spinRecords => '抽奖记录';

  @override
  String get noRecords => '暂无抽奖记录';

  @override
  String get clearAllRecords => '清空全部记录';

  @override
  String get clearRecordsMsg => '确定要清空该转盘的所有抽奖记录吗？';

  @override
  String get deleteRecordMsg => '确定要删除这条抽奖记录吗？';

  @override
  String get recordPrize => '奖品';

  @override
  String get recordTime => '时间';

  @override
  String recordIndex(int index) {
    return '第 $index 次';
  }

  @override
  String get mode3D => '3D模式';

  @override
  String get backgroundImage => '背景图片';

  @override
  String get pickImage => '选择图片';

  @override
  String get clearImage => '清除图片';

  @override
  String get mode2D => '2D';

  @override
  String get mode3DLabel => '3D';

  @override
  String get styleMetallic => '金属';

  @override
  String get stylePastel => '柔和';

  @override
  String get styleDark => '暗黑';

  @override
  String get styleRainbow => '彩虹';

  @override
  String get bgBlur => '高斯模糊';

  @override
  String get bgBlurIntensity => '模糊强度';

  @override
  String get bgOpacity => '背景透明度';

  @override
  String get bgOverlayColor => '叠加色调';

  @override
  String get pointerBottom => '底部';

  @override
  String get pointerLeft => '左侧';

  @override
  String get pointerStyle => '指针风格';

  @override
  String get pointerStyleClassic => '经典';

  @override
  String get pointerStyleArrow => '箭头';

  @override
  String get pointerStyleDiamond => '钻石';

  @override
  String get pointerStyleDot => '圆点';

  @override
  String get pointerStyleFlag => '旗帜';

  @override
  String get multiSpin => '连抽';

  @override
  String get multiSpinTitle => '选择连抽次数';

  @override
  String multiSpinOption(int count) {
    return '连续抽奖 $count 次';
  }

  @override
  String multiSpinResult(int count) {
    return '$count 连抽结果';
  }

  @override
  String get revealAll => '全部揭晓';

  @override
  String get customSpinCount => '自定义次数';

  @override
  String customSpinCountError(int min, int max) {
    return '请输入 $min ~ $max 之间的数字';
  }

  @override
  String get skipSpinAnimation => '跳过抽奖过程';

  @override
  String get singleSpin => '单次抽奖';

  @override
  String get batchSpin => '批量抽奖';

  @override
  String batchSpinCount(int count) {
    return '$count 连抽';
  }

  @override
  String get batchDeleteRecords => '批量删除';

  @override
  String batchDeleteRecordsMsg(int count) {
    return '确定要删除选中的 $count 条记录吗？';
  }

  @override
  String get prizeSummary => '奖品统计';

  @override
  String prizeCount(int count) {
    return '$count 次';
  }

  @override
  String prizePercent(String percent) {
    return '$percent%';
  }

  @override
  String get showAll => '显示全部';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => '抽獎轉盤';

  @override
  String get wheelTab => '轉盤';

  @override
  String get settingsTab => '設定';

  @override
  String get createWheel => '新建轉盤';

  @override
  String get editWheel => '編輯轉盤';

  @override
  String get deleteWheel => '刪除轉盤';

  @override
  String get batchDelete => '批量刪除';

  @override
  String get preview => '預覽';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '確認';

  @override
  String get delete => '刪除';

  @override
  String get edit => '編輯';

  @override
  String get wheelTitle => '轉盤標題';

  @override
  String get wheelTitleHint => '請輸入轉盤標題';

  @override
  String get wheelStyle => '轉盤風格';

  @override
  String get wheelSize => '轉盤尺寸';

  @override
  String get wheelForm => '轉盤形式';

  @override
  String get spinDuration => '旋轉時長(秒)';

  @override
  String get spinSpeed => '旋轉速度';

  @override
  String get pointerPosition => '指針位置';

  @override
  String get showResult => '顯示結果彈窗';

  @override
  String get enableSound => '啟用音效';

  @override
  String get segments => '轉盤塊';

  @override
  String get addSegment => '添加轉盤塊';

  @override
  String get segmentLabel => '獎品名稱';

  @override
  String get segmentLabelHint => '請輸入獎品名稱';

  @override
  String get segmentProbability => '中獎概率(%)';

  @override
  String get segmentColor => '顏色';

  @override
  String get segmentRatio => '面積比例';

  @override
  String get segmentIcon => '圖標';

  @override
  String get deleteSegment => '刪除此項';

  @override
  String get noWheels => '暫無轉盤，點擊右下角按鈕創建';

  @override
  String get deleteConfirm => '確認刪除';

  @override
  String get deleteWheelMsg => '確定要刪除這個轉盤嗎？此操作不可撤銷。';

  @override
  String batchDeleteMsg(int count) {
    return '確定要刪除選中的 $count 個轉盤嗎？';
  }

  @override
  String selected(int count) {
    return '已選擇 $count 項';
  }

  @override
  String get selectAll => '全選';

  @override
  String get deselectAll => '取消全選';

  @override
  String get theme => '應用主題';

  @override
  String get language => '應用語言';

  @override
  String get aboutApp => '關於應用';

  @override
  String get themeSystem => '跟隨系統';

  @override
  String get themeLight => '淺色模式';

  @override
  String get themeDark => '深色模式';

  @override
  String get version => '版本';

  @override
  String get appDescription => '一款精美的自定義抽獎轉盤應用，支持自定義獎品、概率、顏色等參數。';

  @override
  String get developer => '開發者';

  @override
  String get spinTheWheel => '開始抽獎';

  @override
  String get congratulations => '恭喜';

  @override
  String youWon(String prize) {
    return '你抽中了：$prize';
  }

  @override
  String get spinAgain => '再轉一次';

  @override
  String get close => '關閉';

  @override
  String get validationRequired => '此項不能為空';

  @override
  String get validationMinSegments => '至少需要2個轉盤塊';

  @override
  String get validationProbability => '概率總和必須為100%';

  @override
  String get styleClassic => '經典';

  @override
  String get styleNeon => '霓虹';

  @override
  String get styleCandy => '糖果';

  @override
  String get styleElegant => '優雅';

  @override
  String get styleGradient => '漸變';

  @override
  String get styleRetro => '復古';

  @override
  String get styleOcean => '海洋';

  @override
  String get styleSunset => '日落';

  @override
  String get sizeSmall => '小';

  @override
  String get sizeMedium => '中';

  @override
  String get sizeLarge => '大';

  @override
  String get formStandard => '標準';

  @override
  String get formPetal => '花瓣';

  @override
  String get formStar => '星形';

  @override
  String get formPolygon => '多邊形';

  @override
  String get pointerTop => '頂部';

  @override
  String get pointerRight => '右側';

  @override
  String get speedSlow => '慢速';

  @override
  String get speedNormal => '正常';

  @override
  String get speedFast => '快速';

  @override
  String get createdAt => '創建時間';

  @override
  String get updatedAt => '更新時間';

  @override
  String totalSegments(int count) {
    return '$count 個獎品';
  }

  @override
  String get savedSuccess => '儲存成功';

  @override
  String get deletedSuccess => '刪除成功';

  @override
  String get colorPicker => '選擇顏色';

  @override
  String get probabilityAutoBalance => '自動均分概率';

  @override
  String get ratioAutoBalance => '自動均分比例';

  @override
  String get spinRecords => '抽獎記錄';

  @override
  String get noRecords => '暫無抽獎記錄';

  @override
  String get clearAllRecords => '清空全部記錄';

  @override
  String get clearRecordsMsg => '確定要清空該轉盤的所有抽獎記錄嗎？';

  @override
  String get deleteRecordMsg => '確定要刪除這條抽獎記錄嗎？';

  @override
  String get recordPrize => '獎品';

  @override
  String get recordTime => '時間';

  @override
  String recordIndex(int index) {
    return '第 $index 次';
  }

  @override
  String get mode3D => '3D模式';

  @override
  String get backgroundImage => '背景圖片';

  @override
  String get pickImage => '選擇圖片';

  @override
  String get clearImage => '清除圖片';

  @override
  String get mode2D => '2D';

  @override
  String get mode3DLabel => '3D';

  @override
  String get styleMetallic => '金屬';

  @override
  String get stylePastel => '柔和';

  @override
  String get styleDark => '暗黑';

  @override
  String get styleRainbow => '彩虹';

  @override
  String get bgBlur => '高斯模糊';

  @override
  String get bgBlurIntensity => '模糊強度';

  @override
  String get bgOpacity => '背景透明度';

  @override
  String get bgOverlayColor => '疊加色調';

  @override
  String get pointerBottom => '底部';

  @override
  String get pointerLeft => '左側';

  @override
  String get pointerStyle => '指針風格';

  @override
  String get pointerStyleClassic => '經典';

  @override
  String get pointerStyleArrow => '箭頭';

  @override
  String get pointerStyleDiamond => '鑽石';

  @override
  String get pointerStyleDot => '圓點';

  @override
  String get pointerStyleFlag => '旗幟';

  @override
  String get multiSpin => '連抽';

  @override
  String get multiSpinTitle => '選擇連抽次數';

  @override
  String multiSpinOption(int count) {
    return '連續抽獎 $count 次';
  }

  @override
  String multiSpinResult(int count) {
    return '$count 連抽結果';
  }

  @override
  String get revealAll => '全部揭曉';

  @override
  String get customSpinCount => '自定義次數';

  @override
  String customSpinCountError(int min, int max) {
    return '請輸入 $min ~ $max 之間的數字';
  }

  @override
  String get skipSpinAnimation => '跳過抽獎過程';

  @override
  String get singleSpin => '單次抽獎';

  @override
  String get batchSpin => '批量抽獎';

  @override
  String batchSpinCount(int count) {
    return '$count 連抽';
  }

  @override
  String get batchDeleteRecords => '批量刪除';

  @override
  String batchDeleteRecordsMsg(int count) {
    return '確定要刪除選中的 $count 條記錄嗎？';
  }

  @override
  String get prizeSummary => '獎品統計';

  @override
  String prizeCount(int count) {
    return '$count 次';
  }

  @override
  String prizePercent(String percent) {
    return '$percent%';
  }

  @override
  String get showAll => '顯示全部';
}
