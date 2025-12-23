# Shiny Counter

Pokémon shiny counter app in Flutter.

## Features

- Pokémon list (base + custom), dex-sorted; collapsible caught/uncaught sections; empty states and search/gen filters aligned across add/manage.
- Manage Pokémon sheet: search by name/dex, gen filter, clear (X) shortcut, empty-state messaging, and per-Pokémon edit/delete actions.
- Add Pokémon dialog: pick from dex list with search + gen filter, shiny-only sprite picker (skips mega/gmax), dex labels hide raw `custom_*` ids, clear (X) shortcut, and empty state.
- Detail page: counter (+/-, manual), caught toggle, start/catch dates, game selection, shiny/normal sprite toggle (mega before gmax), and form-aware sprite paging.
- Stats pages: overall stats (caught count, total counts), caught-by-game table with expand, recent catches list, and counts chart with date range + reset.
- Game stats page: per-game caught list with counts and direct navigation to detail.
- Android overlay mini-counter: show/share/close via CounterSyncService; can be pinned to lock position.
- Themes: System/Light/Dark/OLED and Language: EN/NL — both persisted via SharedPreferences.
- Persistence: counters, caught status, daily counts, custom list, theme, and language stored via SharedPreferences (KeyValueStore facade); overlay/list/detail stay in sync.
- Sprite handling: precache helper, shiny/normal pairing, mega before gmax ordering for detail, and shared dex parsing/labels for consistent display.

## Usage

1. `flutter pub get`
2. Run: `flutter run`
3. Tests: `flutter test`  
4. Coverage:  
   - `flutter test --coverage`  
   - `dart run tools/lcov_viewer.dart coverage/lcov.info > coverage/coverage.html`

## Notes

- Overlay requests “draw over other apps” permission on Android.
- Pinning the overlay makes it non-draggable; unpin to drag again.
- Dex display: UI shows `#xxxx`; custom entries still store as `custom_<dex>_<suffix>` to avoid collisions.
- When no game is selected in detail, you see a dropdown; after selection it shows text and you can change it via the edit sheet.
