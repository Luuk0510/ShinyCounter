# Shiny Counter

Pokémon shiny counter app in Flutter.

## Features
- Pokémon list (base + custom), dex-sorted, with caught marking and per-Pokémon management sheet.
- Detail page with counter (+/-, manual), caught toggle, start/catch dates, game selection (with logos), and shiny/normal sprite toggle (forms shown when available).
- Add Pokémon dialog with search + sprite picker (shiny sprites only, skips mega/gmax); custom Pokémon can be added/edited/removed.
- Android overlay (mini-counter) above other apps; pin to lock position and prevent dragging.
- Themes: System, Light, Dark, OLED and Language: EN/NL — both persisted via SharedPreferences.
- SharedPreferences storage for counters, caught status, daily counts, custom list, theme, and language; dialogs/bottom sheets follow card theming.

## Usage
1. `flutter pub get`
2. Run: `flutter run`
3. Tests: `flutter test` (coverage: `flutter test --coverage`)

## Notes
- Overlay requests “draw over other apps” permission on Android.
- Pinning the overlay makes it non-draggable; unpin to drag again.
- When no game is selected in detail, you see a dropdown; after selection it shows text and you can change it via the edit sheet.
