// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Glücksrad';

  @override
  String get wheelTab => 'Rad';

  @override
  String get settingsTab => 'Einstellungen';

  @override
  String get createWheel => 'Rad erstellen';

  @override
  String get editWheel => 'Rad bearbeiten';

  @override
  String get deleteWheel => 'Rad löschen';

  @override
  String get batchDelete => 'Mehrfach löschen';

  @override
  String get preview => 'Vorschau';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get wheelTitle => 'Radtitel';

  @override
  String get wheelTitleHint => 'Radtitel eingeben';

  @override
  String get wheelStyle => 'Radstil';

  @override
  String get wheelSize => 'Radgröße';

  @override
  String get wheelForm => 'Radform';

  @override
  String get spinDuration => 'Drehdauer (Sek.)';

  @override
  String get spinSpeed => 'Drehgeschwindigkeit';

  @override
  String get pointerPosition => 'Zeigerposition';

  @override
  String get showResult => 'Ergebnis anzeigen';

  @override
  String get enableSound => 'Ton aktivieren';

  @override
  String get segments => 'Segmente';

  @override
  String get addSegment => 'Segment hinzufügen';

  @override
  String get segmentLabel => 'Preisname';

  @override
  String get segmentLabelHint => 'Preisname eingeben';

  @override
  String get segmentProbability => 'Wahrscheinlichkeit (%)';

  @override
  String get segmentColor => 'Farbe';

  @override
  String get segmentRatio => 'Flächenverhältnis';

  @override
  String get segmentIcon => 'Symbol';

  @override
  String get deleteSegment => 'Löschen';

  @override
  String get noWheels =>
      'Keine Räder vorhanden. Tippen Sie auf die Schaltfläche, um eines zu erstellen.';

  @override
  String get deleteConfirm => 'Löschen bestätigen';

  @override
  String get deleteWheelMsg =>
      'Möchten Sie dieses Rad wirklich löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String batchDeleteMsg(int count) {
    return 'Möchten Sie die $count ausgewählten Räder löschen?';
  }

  @override
  String selected(int count) {
    return '$count ausgewählt';
  }

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get deselectAll => 'Auswahl aufheben';

  @override
  String get theme => 'Design';

  @override
  String get language => 'Sprache';

  @override
  String get aboutApp => 'Über';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'Eine schöne anpassbare Glücksrad-App mit benutzerdefinierten Preisen, Wahrscheinlichkeiten und Farben.';

  @override
  String get developer => 'Entwickler';

  @override
  String get spinTheWheel => 'Drehen';

  @override
  String get congratulations => 'Herzlichen Glückwunsch';

  @override
  String youWon(String prize) {
    return 'Sie haben gewonnen: $prize';
  }

  @override
  String get spinAgain => 'Nochmal drehen';

  @override
  String get close => 'Schließen';

  @override
  String get validationRequired => 'Dieses Feld ist erforderlich';

  @override
  String get validationMinSegments => 'Mindestens 2 Segmente erforderlich';

  @override
  String get validationProbability =>
      'Wahrscheinlichkeiten müssen 100% ergeben';

  @override
  String get styleClassic => 'Klassisch';

  @override
  String get styleNeon => 'Neon';

  @override
  String get styleCandy => 'Bonbon';

  @override
  String get styleElegant => 'Elegant';

  @override
  String get styleGradient => 'Verlauf';

  @override
  String get styleRetro => 'Retro';

  @override
  String get styleOcean => 'Ozean';

  @override
  String get styleSunset => 'Sonnenuntergang';

  @override
  String get sizeSmall => 'Klein';

  @override
  String get sizeMedium => 'Mittel';

  @override
  String get sizeLarge => 'Groß';

  @override
  String get formStandard => 'Standard';

  @override
  String get formPetal => 'Blütenblatt';

  @override
  String get formStar => 'Stern';

  @override
  String get formPolygon => 'Polygon';

  @override
  String get pointerTop => 'Oben';

  @override
  String get pointerRight => 'Rechts';

  @override
  String get speedSlow => 'Langsam';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Schnell';

  @override
  String get createdAt => 'Erstellt am';

  @override
  String get updatedAt => 'Aktualisiert am';

  @override
  String totalSegments(int count) {
    return '$count Preise';
  }

  @override
  String get savedSuccess => 'Erfolgreich gespeichert';

  @override
  String get deletedSuccess => 'Erfolgreich gelöscht';

  @override
  String get colorPicker => 'Farbe wählen';

  @override
  String get probabilityAutoBalance => 'Wahrscheinlichkeiten ausgleichen';

  @override
  String get ratioAutoBalance => 'Verhältnisse ausgleichen';

  @override
  String get spinRecords => 'Drehverlauf';

  @override
  String get noRecords => 'Kein Drehverlauf vorhanden';

  @override
  String get clearAllRecords => 'Gesamten Verlauf löschen';

  @override
  String get clearRecordsMsg =>
      'Möchten Sie den gesamten Drehverlauf dieses Rades löschen?';

  @override
  String get deleteRecordMsg => 'Möchten Sie diesen Eintrag löschen?';

  @override
  String get recordPrize => 'Preis';

  @override
  String get recordTime => 'Zeit';

  @override
  String recordIndex(int index) {
    return 'Drehung Nr. $index';
  }

  @override
  String get mode3D => '3D-Modus';

  @override
  String get backgroundImage => 'Hintergrundbild';

  @override
  String get pickImage => 'Bild auswählen';

  @override
  String get clearImage => 'Bild entfernen';

  @override
  String get mode2D => '2D';

  @override
  String get mode3DLabel => '3D';

  @override
  String get styleMetallic => 'Metallisch';

  @override
  String get stylePastel => 'Pastell';

  @override
  String get styleDark => 'Dunkel';

  @override
  String get styleRainbow => 'Regenbogen';

  @override
  String get bgBlur => 'Gaußscher Weichzeichner';

  @override
  String get bgBlurIntensity => 'Unschärfe-Intensität';

  @override
  String get bgOpacity => 'Hintergrund-Deckkraft';

  @override
  String get bgOverlayColor => 'Overlay-Farbton';

  @override
  String get pointerBottom => 'Unten';

  @override
  String get pointerLeft => 'Links';

  @override
  String get pointerStyle => 'Zeigerstil';

  @override
  String get pointerStyleClassic => 'Klassisch';

  @override
  String get pointerStyleArrow => 'Pfeil';

  @override
  String get pointerStyleDiamond => 'Diamant';

  @override
  String get pointerStyleDot => 'Punkt';

  @override
  String get pointerStyleFlag => 'Flagge';

  @override
  String get multiSpin => 'Mehrfach drehen';

  @override
  String get multiSpinTitle => 'Anzahl wählen';

  @override
  String multiSpinOption(int count) {
    return '$count Mal drehen';
  }

  @override
  String multiSpinResult(int count) {
    return '${count}x Drehergebnisse';
  }

  @override
  String get revealAll => 'Alle aufdecken';

  @override
  String get customSpinCount => 'Benutzerdefiniert';

  @override
  String customSpinCountError(int min, int max) {
    return 'Bitte eine Zahl zwischen $min und $max eingeben';
  }

  @override
  String get skipSpinAnimation => 'Animation überspringen';

  @override
  String get singleSpin => 'Einzeldrehung';

  @override
  String get batchSpin => 'Mehrfachdrehung';

  @override
  String batchSpinCount(int count) {
    return '${count}x Drehung';
  }

  @override
  String get batchDeleteRecords => 'Mehrfach löschen';

  @override
  String batchDeleteRecordsMsg(int count) {
    return '$count ausgewählte Einträge löschen?';
  }

  @override
  String get prizeSummary => 'Preisstatistik';

  @override
  String prizeCount(int count) {
    return '${count}x';
  }

  @override
  String prizePercent(String percent) {
    return '$percent%';
  }

  @override
  String get showAll => 'Alle anzeigen';
}
