import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
    Locale('en'),
    Locale('nl'),
  ];

  /// App title shown in the main app bar.
  ///
  /// In en, this message translates to:
  /// **'Shiny counter'**
  String get appTitle;

  /// Header label for uncaught Pokémon list.
  ///
  /// In en, this message translates to:
  /// **'Uncaught'**
  String get sectionUncaught;

  /// Header label for caught Pokémon list.
  ///
  /// In en, this message translates to:
  /// **'Caught'**
  String get sectionCaught;

  ///
  ///
  /// In en, this message translates to:
  /// **'New Pokémon'**
  String get tooltipAddPokemon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Manage Pokémon'**
  String get tooltipManagePokemon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  ///
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Caught Pokémon'**
  String get statsCaughtLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Total counts'**
  String get statsTotalCountsLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Caught in games'**
  String get statsGamesLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get statsGamesShowMore;

  ///
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get statsGamesShowLess;

  ///
  ///
  /// In en, this message translates to:
  /// **'Recent catches'**
  String get statsRecentLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Manage Pokémon'**
  String get manageTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get manageEditTooltip;

  ///
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manageDeleteTooltip;

  ///
  ///
  /// In en, this message translates to:
  /// **'No custom Pokémon to manage.'**
  String get manageNoCustom;

  ///
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteMessage(Object name);

  ///
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmDeleteCancel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteDelete;

  ///
  ///
  /// In en, this message translates to:
  /// **'No Pokémon added yet'**
  String get emptyTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add Pokémon'**
  String get emptyAction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add new Pokémon'**
  String get addDialogTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Edit Pokémon'**
  String get editDialogTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  ///
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'e.g. Mewtwo'**
  String get nameHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  ///
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  ///
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  ///
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  ///
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get settingsOled;

  ///
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  ///
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  ///
  ///
  /// In en, this message translates to:
  /// **'Edit counter'**
  String get editCounterTooltip;

  ///
  ///
  /// In en, this message translates to:
  /// **'Open mini counter'**
  String get openOverlayTooltip;

  ///
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get buttonCatch;

  ///
  ///
  /// In en, this message translates to:
  /// **'Caught'**
  String get buttonCaught;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get huntStart;

  ///
  ///
  /// In en, this message translates to:
  /// **'Caught'**
  String get huntCaught;

  /// No description provided for @huntGame.
  ///
  /// In en, this message translates to:
  /// **'Pokemon {game}'**
  String huntGame(Object game);

  ///
  ///
  /// In en, this message translates to:
  /// **'Select game'**
  String get selectGameHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'No counts yet'**
  String get noCounts;

  ///
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get countLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get addCountRow;

  ///
  ///
  /// In en, this message translates to:
  /// **'Edit Pokémon details'**
  String get editSheetTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Count history'**
  String get huntHistoryTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Search by name or dex'**
  String get searchByNameOrDex;

  ///
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumberHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'Enter a valid counter'**
  String get invalidCounter;

  ///
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get gameLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Scroll to pick a game'**
  String get gameHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get gameNone;

  ///
  ///
  /// In en, this message translates to:
  /// **'No Pokémon found'**
  String get noPokemonFound;

  ///
  ///
  /// In en, this message translates to:
  /// **'Try another name, dex, or generation filter.'**
  String get tryAnotherFilter;

  ///
  ///
  /// In en, this message translates to:
  /// **'All gens'**
  String get filterAllGens;
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
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
