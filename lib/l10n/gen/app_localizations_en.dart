// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Shiny counter';

  @override
  String get sectionUncaught => 'Uncaught';

  @override
  String get sectionCaught => 'Caught';

  @override
  String get tooltipAddPokemon => 'New Pokémon';

  @override
  String get tooltipManagePokemon => 'Manage Pokémon';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsCaughtLabel => 'Caught Pokémon';

  @override
  String get statsTotalCountsLabel => 'Total counts';

  @override
  String get statsGamesLabel => 'Caught in games';

  @override
  String get statsResetsByGameLabel => 'Resets by game';

  @override
  String get statsGamesShowMore => 'Show all';

  @override
  String get statsGamesShowLess => 'Show less';

  @override
  String get statsRecentLabel => 'Recent catches';

  @override
  String get statsRangeReset => 'Reset';

  @override
  String get manageTitle => 'Manage Pokémon';

  @override
  String get manageEditTooltip => 'Edit';

  @override
  String get manageDeleteTooltip => 'Delete';

  @override
  String get manageNoCustom => 'No custom Pokémon to manage.';

  @override
  String get confirmDeleteTitle => 'Delete';

  @override
  String confirmDeleteMessage(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get confirmDeleteCancel => 'Cancel';

  @override
  String get confirmDeleteDelete => 'Delete';

  @override
  String get emptyTitle => 'No Pokémon added yet';

  @override
  String get emptyAction => 'Add Pokémon';

  @override
  String get addDialogTitle => 'Add new Pokémon';

  @override
  String get editDialogTitle => 'Edit Pokémon';

  @override
  String get choose => 'Choose';

  @override
  String get nameLabel => 'Name';

  @override
  String get nameHint => 'e.g. Mewtwo';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get settingsTitle => 'Theme';

  @override
  String get settingsAccentColor => 'Accent color';

  @override
  String get settingsDataTitle => 'Data';

  @override
  String get settingsExportJson => 'Export backup';

  @override
  String get settingsImportJson => 'Import backup';

  @override
  String get settingsImportConfirmTitle => 'Replace your data?';

  @override
  String get settingsImportConfirmMessage =>
      'Importing will overwrite your current data.';

  @override
  String get settingsImportConfirmAction => 'Import';

  @override
  String get settingsExportSuccess => 'Backup exported';

  @override
  String get settingsImportSuccess => 'Backup imported';

  @override
  String get settingsExportFailed => 'Export failed';

  @override
  String get settingsImportFailed => 'Import failed';

  @override
  String get colorDefault => 'Default';

  @override
  String get colorRed => 'Red';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorDarkBlue => 'Dark blue';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorPink => 'Pink';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsOled => 'OLED';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageDutch => 'Dutch';

  @override
  String get editCounterTooltip => 'Edit counter';

  @override
  String get openOverlayTooltip => 'Open mini counter';

  @override
  String get buttonCatch => 'Catch';

  @override
  String get buttonCaught => 'Caught';

  @override
  String get huntStart => 'Start';

  @override
  String get huntCaught => 'Caught';

  @override
  String huntGame(Object game) {
    return 'Pokemon $game';
  }

  @override
  String get selectGameHint => 'Select game';

  @override
  String get noCounts => 'No counts yet';

  @override
  String get dateLabel => 'Date';

  @override
  String get countLabel => 'Count';

  @override
  String get addCountRow => 'Add day';

  @override
  String get editSheetTitle => 'Edit Pokémon details';

  @override
  String get huntHistoryTitle => 'Count history';

  @override
  String get searchByNameOrDex => 'Search by name or dex';

  @override
  String get counterLabel => 'Counter';

  @override
  String get enterNumberHint => 'Enter a number';

  @override
  String get invalidCounter => 'Enter a valid counter';

  @override
  String get gameLabel => 'Game';

  @override
  String get gameHint => 'Scroll to pick a game';

  @override
  String get gameNone => 'None';

  @override
  String get noPokemonFound => 'No Pokémon found';

  @override
  String get tryAnotherFilter => 'Try another name, dex, or generation filter.';

  @override
  String get filterAllGens => 'All gens';
}
