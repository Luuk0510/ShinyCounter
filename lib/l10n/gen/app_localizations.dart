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

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pokémon shiny counter'**
  String get appTitle;

  /// No description provided for @sectionUncaught.
  ///
  /// In en, this message translates to:
  /// **'Uncaught'**
  String get sectionUncaught;

  /// No description provided for @sectionCaught.
  ///
  /// In en, this message translates to:
  /// **'Caught'**
  String get sectionCaught;

  /// No description provided for @tooltipAddPokemon.
  ///
  /// In en, this message translates to:
  /// **'New Pokémon'**
  String get tooltipAddPokemon;

  /// No description provided for @tooltipManagePokemon.
  ///
  /// In en, this message translates to:
  /// **'Manage Pokémon'**
  String get tooltipManagePokemon;

  /// No description provided for @tooltipSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tooltipSettings;

  /// No description provided for @manageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Pokémon'**
  String get manageTitle;

  /// No description provided for @manageEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get manageEditTooltip;

  /// No description provided for @manageDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get manageDeleteTooltip;

  /// No description provided for @manageNoCustom.
  ///
  /// In en, this message translates to:
  /// **'No custom Pokémon to manage.'**
  String get manageNoCustom;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String confirmDeleteMessage(Object name);

  /// No description provided for @confirmDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmDeleteCancel;

  /// No description provided for @confirmDeleteDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirmDeleteDelete;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Pokémon added yet'**
  String get emptyTitle;

  /// No description provided for @emptyAction.
  ///
  /// In en, this message translates to:
  /// **'Add Pokémon'**
  String get emptyAction;

  /// No description provided for @addDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Pokémon'**
  String get addDialogTitle;

  /// No description provided for @editDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Pokémon'**
  String get editDialogTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mewtwo'**
  String get nameHint;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTitle;

  /// No description provided for @settingsSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsSystem;

  /// No description provided for @settingsLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsDark;

  /// No description provided for @settingsOled.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get settingsOled;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageDutch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageDutch;

  /// No description provided for @editCounterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit counter'**
  String get editCounterTooltip;

  /// No description provided for @openOverlayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open mini counter'**
  String get openOverlayTooltip;

  /// No description provided for @buttonCatch.
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get buttonCatch;

  /// No description provided for @buttonCaught.
  ///
  /// In en, this message translates to:
  /// **'Caught'**
  String get buttonCaught;

  /// No description provided for @huntStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get huntStart;

  /// No description provided for @huntCatch.
  ///
  /// In en, this message translates to:
  /// **'Catch'**
  String get huntCatch;

  /// No description provided for @huntGame.
  ///
  /// In en, this message translates to:
  /// **'Pokemon {game}'**
  String huntGame(Object game);

  /// No description provided for @selectGameHint.
  ///
  /// In en, this message translates to:
  /// **'Select game'**
  String get selectGameHint;

  /// No description provided for @noCounts.
  ///
  /// In en, this message translates to:
  /// **'No counts yet'**
  String get noCounts;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @countLabel.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get countLabel;

  /// No description provided for @addCountRow.
  ///
  /// In en, this message translates to:
  /// **'Add day'**
  String get addCountRow;

  /// No description provided for @editSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editSheetTitle;

  /// No description provided for @counterLabel.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterLabel;

  /// No description provided for @enterNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get enterNumberHint;

  /// No description provided for @invalidCounter.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid counter'**
  String get invalidCounter;

  /// No description provided for @gameLabel.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get gameLabel;

  /// No description provided for @gameHint.
  ///
  /// In en, this message translates to:
  /// **'Scroll to pick a game'**
  String get gameHint;

  /// No description provided for @gameNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get gameNone;
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
