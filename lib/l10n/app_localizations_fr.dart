// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Roue de la Chance';

  @override
  String get wheelTab => 'Roue';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get createWheel => 'Créer une roue';

  @override
  String get editWheel => 'Modifier la roue';

  @override
  String get deleteWheel => 'Supprimer la roue';

  @override
  String get batchDelete => 'Suppression groupée';

  @override
  String get preview => 'Aperçu';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get wheelTitle => 'Titre de la roue';

  @override
  String get wheelTitleHint => 'Entrez le titre de la roue';

  @override
  String get wheelStyle => 'Style de la roue';

  @override
  String get wheelSize => 'Taille de la roue';

  @override
  String get wheelForm => 'Forme de la roue';

  @override
  String get spinDuration => 'Durée de rotation (sec)';

  @override
  String get spinSpeed => 'Vitesse de rotation';

  @override
  String get pointerPosition => 'Position du pointeur';

  @override
  String get showResult => 'Afficher le résultat';

  @override
  String get enableSound => 'Activer le son';

  @override
  String get segments => 'Segments';

  @override
  String get addSegment => 'Ajouter un segment';

  @override
  String get segmentLabel => 'Nom du prix';

  @override
  String get segmentLabelHint => 'Entrez le nom du prix';

  @override
  String get segmentProbability => 'Probabilité (%)';

  @override
  String get segmentColor => 'Couleur';

  @override
  String get segmentRatio => 'Ratio de surface';

  @override
  String get segmentIcon => 'Icône';

  @override
  String get deleteSegment => 'Supprimer';

  @override
  String get noWheels =>
      'Aucune roue. Appuyez sur le bouton pour en créer une.';

  @override
  String get deleteConfirm => 'Confirmer la suppression';

  @override
  String get deleteWheelMsg =>
      'Voulez-vous vraiment supprimer cette roue ? Cette action est irréversible.';

  @override
  String batchDeleteMsg(int count) {
    return 'Voulez-vous supprimer les $count roues sélectionnées ?';
  }

  @override
  String selected(int count) {
    return '$count sélectionnés';
  }

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get aboutApp => 'À propos';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get version => 'Version';

  @override
  String get appDescription =>
      'Une belle application de roue de la chance personnalisable avec des prix, probabilités et couleurs personnalisés.';

  @override
  String get developer => 'Développeur';

  @override
  String get spinTheWheel => 'Tourner';

  @override
  String get congratulations => 'Félicitations';

  @override
  String youWon(String prize) {
    return 'Vous avez gagné : $prize';
  }

  @override
  String get spinAgain => 'Rejouer';

  @override
  String get close => 'Fermer';

  @override
  String get validationRequired => 'Ce champ est requis';

  @override
  String get validationMinSegments => 'Au moins 2 segments requis';

  @override
  String get validationProbability => 'Les probabilités doivent totaliser 100%';

  @override
  String get styleClassic => 'Classique';

  @override
  String get styleNeon => 'Néon';

  @override
  String get styleCandy => 'Bonbon';

  @override
  String get styleElegant => 'Élégant';

  @override
  String get styleGradient => 'Dégradé';

  @override
  String get styleRetro => 'Rétro';

  @override
  String get styleOcean => 'Océan';

  @override
  String get styleSunset => 'Coucher de soleil';

  @override
  String get sizeSmall => 'Petit';

  @override
  String get sizeMedium => 'Moyen';

  @override
  String get sizeLarge => 'Grand';

  @override
  String get formStandard => 'Standard';

  @override
  String get formPetal => 'Pétale';

  @override
  String get formStar => 'Étoile';

  @override
  String get formPolygon => 'Polygone';

  @override
  String get pointerTop => 'Haut';

  @override
  String get pointerRight => 'Droite';

  @override
  String get speedSlow => 'Lent';

  @override
  String get speedNormal => 'Normal';

  @override
  String get speedFast => 'Rapide';

  @override
  String get createdAt => 'Créé le';

  @override
  String get updatedAt => 'Modifié le';

  @override
  String totalSegments(int count) {
    return '$count prix';
  }

  @override
  String get savedSuccess => 'Enregistré avec succès';

  @override
  String get deletedSuccess => 'Supprimé avec succès';

  @override
  String get colorPicker => 'Choisir la couleur';

  @override
  String get probabilityAutoBalance => 'Équilibrer les probabilités';

  @override
  String get ratioAutoBalance => 'Équilibrer les ratios';

  @override
  String get spinRecords => 'Historique des tirages';

  @override
  String get noRecords => 'Aucun historique de tirage';

  @override
  String get clearAllRecords => 'Effacer tout l\'historique';

  @override
  String get clearRecordsMsg =>
      'Voulez-vous effacer tout l\'historique de cette roue ?';

  @override
  String get deleteRecordMsg => 'Voulez-vous supprimer cet enregistrement ?';

  @override
  String get recordPrize => 'Prix';

  @override
  String get recordTime => 'Heure';

  @override
  String recordIndex(int index) {
    return 'Tirage n°$index';
  }

  @override
  String get mode3D => 'Mode 3D';

  @override
  String get backgroundImage => 'Image de fond';

  @override
  String get pickImage => 'Choisir une image';

  @override
  String get clearImage => 'Supprimer l\'image';

  @override
  String get mode2D => '2D';

  @override
  String get mode3DLabel => '3D';

  @override
  String get styleMetallic => 'Métallique';

  @override
  String get stylePastel => 'Pastel';

  @override
  String get styleDark => 'Sombre';

  @override
  String get styleRainbow => 'Arc-en-ciel';
}
