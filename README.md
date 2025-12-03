# Shiny Counter

Pokémon shiny counter app in Flutter.

## Features
- Pokémon list (base + custom), alphabetized with caught marking.
- Detail page with counter, +/-, caught toggle, manual input, and start/catch/game fields.
- Game selection per hunt (dropdown in detail); shows chosen game in the info card.
- Android overlay (mini-counter) above other apps; pin to lock position.
- Add/edit/delete custom Pokémon including custom images.
- Themes: System, Light, Dark, OLED — choice and language (EN/NL) are persisted.
- Uses SharedPreferences for counters, caught state, custom list, theme, and language.
- Dialogs/bottom sheets styled consistently with card theme.

## Usage
1. `flutter pub get`
2. Run: `flutter run`
3. Tests: `flutter test` (coverage: `flutter test --coverage`)

## Notes
- Overlay requests “draw over other apps” permission on Android.
- Pinning the overlay makes it non-draggable; unpin to drag again.
- When no game is selected in detail, you see a dropdown; after selection it shows text and you can change it via the edit sheet.