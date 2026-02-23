// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prize Wheel';

  @override
  String get wheelTab => 'Wheel';

  @override
  String get settingsTab => 'Settings';

  @override
  String get createWheel => 'Create Wheel';

  @override
  String get editWheel => 'Edit Wheel';

  @override
  String get deleteWheel => 'Delete Wheel';

  @override
  String get batchDelete => 'Batch Delete';

  @override
  String get preview => 'Preview';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get wheelTitle => 'Wheel Title';

  @override
  String get wheelTitleHint => 'Enter wheel title';

  @override
  String get wheelStyle => 'Wheel Style';

  @override
  String get wheelSize => 'Wheel Size';

  @override
  String get wheelForm => 'Wheel Form';

  @override
  String get spinDuration => 'Spin Duration (sec)';

  @override
  String get spinSpeed => 'Spin Speed';

  @override
  String get pointerPosition => 'Pointer Position';

  @override
  String get showResult => 'Show Result Dialog';

  @override
  String get enableSound => 'Enable Sound';

  @override
  String get segments => 'Segments';

  @override
  String get addSegment => 'Add Segment';

  @override
  String get segmentLabel => 'Prize Name';

  @override
  String get segmentLabelHint => 'Enter prize name';

  @override
  String get segmentProbability => 'Probability (%)';

  @override
  String get segmentColor => 'Color';

  @override
  String get segmentRatio => 'Area Ratio';

  @override
  String get segmentIcon => 'Icon';

  @override
  String get deleteSegment => 'Delete This';

  @override
  String get noWheels => 'No wheels yet. Tap the button below to create one.';

  @override
  String get deleteConfirm => 'Confirm Delete';

  @override
  String get deleteWheelMsg =>
      'Are you sure you want to delete this wheel? This cannot be undone.';

  @override
  String batchDeleteMsg(int count) {
    return 'Are you sure you want to delete $count selected wheels?';
  }

  @override
  String selected(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get aboutApp => 'About';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'A beautiful customizable prize wheel app with custom prizes, probabilities, colors and more.';

  @override
  String get developer => 'Developer';

  @override
  String get spinTheWheel => 'Spin';

  @override
  String get congratulations => 'Congratulations';

  @override
  String youWon(String prize) {
    return 'You won: $prize';
  }

  @override
  String get spinAgain => 'Spin Again';

  @override
  String get close => 'Close';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationMinSegments => 'At least 2 segments required';

  @override
  String get validationProbability => 'Probabilities must sum to 100%';

  @override
  String get styleClassic => 'Classic';

  @override
  String get styleNeon => 'Neon';

  @override
  String get styleCandy => 'Candy';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleGradient => 'Gradient';

  @override
  String get styleRetro => 'Retro';

  @override
  String get styleOcean => 'Ocean';

  @override
  String get styleSunset => 'Sunset';

  @override
  String get sizeSmall => 'Small';

  @override
  String get sizeMedium => 'Medium';

  @override
  String get sizeLarge => 'Large';

  @override
  String get formStandard => 'Standard';

  @override
  String get formPetal => 'Petal';

  @override
  String get formStar => 'Star';

  @override
  String get formPolygon => 'Polygon';

  @override
  String get pointerTop => 'Top';

  @override
  String get pointerRight => 'Right';

  @override
  String get speedSlow => 'Slow';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Fast';

  @override
  String get createdAt => 'Created';

  @override
  String get updatedAt => 'Updated';

  @override
  String totalSegments(int count) {
    return '$count prizes';
  }

  @override
  String get savedSuccess => 'Saved successfully';

  @override
  String get deletedSuccess => 'Deleted successfully';

  @override
  String get colorPicker => 'Pick Color';

  @override
  String get probabilityAutoBalance => 'Auto-balance Probability';

  @override
  String get ratioAutoBalance => 'Auto-balance Ratio';

  @override
  String get spinRecords => 'Spin Records';

  @override
  String get noRecords => 'No spin records yet';

  @override
  String get clearAllRecords => 'Clear All Records';

  @override
  String get clearRecordsMsg =>
      'Are you sure you want to clear all spin records for this wheel?';

  @override
  String get deleteRecordMsg =>
      'Are you sure you want to delete this spin record?';

  @override
  String get recordPrize => 'Prize';

  @override
  String get recordTime => 'Time';

  @override
  String recordIndex(int index) {
    return 'Spin #$index';
  }

  @override
  String get mode3D => '3D Mode';

  @override
  String get backgroundImage => 'Background Image';

  @override
  String get pickImage => 'Pick Image';

  @override
  String get clearImage => 'Clear Image';

  @override
  String get mode2D => '2D';

  @override
  String get mode3DLabel => '3D';

  @override
  String get styleMetallic => 'Metallic';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get styleDark => 'Dark';

  @override
  String get styleRainbow => 'Rainbow';
}
