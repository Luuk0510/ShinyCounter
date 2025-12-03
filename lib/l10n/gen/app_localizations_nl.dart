// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Pokémon shiny counter';

  @override
  String get sectionUncaught => 'Niet gevangen';

  @override
  String get sectionCaught => 'Gevangen';

  @override
  String get tooltipAddPokemon => 'Nieuwe Pokémon';

  @override
  String get tooltipManagePokemon => 'Beheer Pokémon';

  @override
  String get tooltipSettings => 'Instellingen';

  @override
  String get manageTitle => 'Beheer Pokémon';

  @override
  String get manageEditTooltip => 'Bewerken';

  @override
  String get manageDeleteTooltip => 'Verwijderen';

  @override
  String get manageNoCustom => 'Geen custom Pokémon om te bewerken.';

  @override
  String get confirmDeleteTitle => 'Verwijderen';

  @override
  String confirmDeleteMessage(Object name) {
    return 'Weet je zeker dat je $name wilt verwijderen?';
  }

  @override
  String get confirmDeleteCancel => 'Annuleren';

  @override
  String get confirmDeleteDelete => 'Verwijder';

  @override
  String get emptyTitle => 'Nog geen Pokémon toegevoegd';

  @override
  String get emptyAction => 'Voeg Pokémon toe';

  @override
  String get addDialogTitle => 'Nieuwe Pokémon';

  @override
  String get editDialogTitle => 'Pokémon bewerken';

  @override
  String get nameLabel => 'Naam';

  @override
  String get nameHint => 'Bijv. Mewtwo';

  @override
  String get choosePhoto => 'Kies foto';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get settingsTitle => 'Thema';

  @override
  String get settingsSystem => 'Systeem';

  @override
  String get settingsLight => 'Licht';

  @override
  String get settingsDark => 'Donker';

  @override
  String get settingsOled => 'OLED';

  @override
  String get settingsLanguage => 'Taal';

  @override
  String get languageEnglish => 'Engels';

  @override
  String get languageDutch => 'Nederlands';

  @override
  String get editCounterTooltip => 'Counter bewerken';

  @override
  String get openOverlayTooltip => 'Mini-counter openen';

  @override
  String get buttonCatch => 'Vang';

  @override
  String get buttonCaught => 'Gevangen';

  @override
  String get huntStart => 'Start';

  @override
  String get huntCatch => 'Gevangen';

  @override
  String huntGame(Object game) {
    return 'Pokemon $game';
  }

  @override
  String get noCounts => 'Nog geen tellingen';

  @override
  String get dateLabel => 'Datum';

  @override
  String get countLabel => 'Aantal';

  @override
  String get editSheetTitle => 'Aanpassen';

  @override
  String get counterLabel => 'Counter';

  @override
  String get enterNumberHint => 'Voer een getal in';

  @override
  String get invalidCounter => 'Voer een geldige counter in';

  @override
  String get gameLabel => 'Game';

  @override
  String get gameHint => 'Scroll voor game';

  @override
  String get gameNone => 'Geen';
}
