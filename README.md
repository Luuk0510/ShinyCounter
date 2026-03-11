# Shiny Counter

A Flutter app for tracking Pokemon shiny hunts.

## Features

- Custom Pokemon list, dex-sorted, with collapsible caught/uncaught sections and empty states.
- Manage Pokemon sheet with search by name/dex, gen filter, clear shortcut, empty-state messaging, and per-Pokemon edit/delete actions.
- Add Pokemon dialog with search + gen filter and a shiny-only sprite picker that skips mega/gmax forms.
- Detail page with counter (+/-, manual), caught toggle, start/catch dates, game selection, shiny/normal sprite toggle, and form-aware sprite paging.
- Stats pages with overall stats, caught-by-game tables, recent catches, and count history by date range.
- Game stats page with per-game caught lists and direct navigation to detail.
- Android overlay mini-counter with show/share/close support through `CounterSyncService`.
- Themes and localization persisted through SharedPreferences.
- Backup import/export scoped to app-managed preference keys only.
- Sprite loading and precaching handled through `PokemonSpriteService`.

## Structure

```text
lib/
  core/        # app-wide DI, routing, theme, storage, metadata
  features/
    pokemon/
      data/         # persistence and concrete implementations
      domain/       # entities, contracts, stats/business rules
      presentation/
        pages/      # screens
        state/      # page/controllers
        widgets/    # reusable UI pieces
        utils/      # UI helpers
        models/     # page/UI-specific models
      shared/       # feature utilities used across layers
      overlay/      # Android overlay UI
  l10n/        # ARB + generated localization files
```

Current examples:
- `PokemonStorage` is the concrete `PokemonRepository`
- `PokemonStatsRepository` is the concrete `StatsRepository`
- `PokemonSpriteService` is the concrete sprite loader/cache service
- page orchestration lives in `presentation/state`, such as `PokemonListPageController` and `PokemonStatsPageController`
- shared dialog/sheet helpers live in `presentation/widgets/dialogs`, such as `ConfirmationDialog`, `DialogActionRow`, and `BottomSheetActionRow`

## Usage

1. `flutter pub get`
2. `flutter gen-l10n`
3. `flutter run`
4. `flutter test`
5. Coverage:
   - `flutter test --coverage`
   - `dart run tools/lcov_viewer.dart coverage/lcov.info > coverage/coverage.html`

## Notes

- Overlay requests "draw over other apps" permission on Android.
- Pinning the overlay makes it non-draggable; unpin to drag again.
- Dex display uses `#xxxx`; custom entries still store as `custom_<dex>_<suffix>` to avoid collisions.
- When no game is selected in detail, the UI shows a dropdown; after selection it can be changed from the edit sheet.
