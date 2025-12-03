// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokémon shiny counter';

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
  String get addDialogTitle => 'New Pokémon';

  @override
  String get editDialogTitle => 'Edit Pokémon';

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
  String get settingsSystem => 'System';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsOled => 'OLED';

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
  String get huntCatch => 'Catch';

  @override
  String huntGame(Object game) {
    return 'Pokemon $game';
  }

  @override
  String get noCounts => 'No counts yet';

  @override
  String get dateLabel => 'Date';

  @override
  String get countLabel => 'Count';

  @override
  String get editSheetTitle => 'Edit';

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
}
