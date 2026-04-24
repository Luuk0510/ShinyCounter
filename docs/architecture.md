# Shiny Counter Code Guide

This document explains how the app is structured, how data flows, and which
patterns you use so the code is easier to understand and extend.

## High‑Level Structure

```
lib/
  core/        # cross‑feature infrastructure
  features/    # per‑feature code (pokemon)
  l10n/        # ARB + generated localization files
```

## Core (shared infrastructure)

**Dependency setup**
- `core/di/app_locator.dart` initializes long‑lived services (prefs, repositories).
- `core/di/app_providers.dart` wires `Provider` / `ChangeNotifier` instances.

**Routing**
- `core/routing/app_router.dart` defines routes and error fallbacks.
- `core/routing/context_extensions.dart` adds typed navigation helpers.

**Theme + tokens**
- `core/theme/` is split by concern (colors, spacing, sizes, radii, typography).
- `core/theme/tokens.dart` re‑exports those files so widgets import one entry.
- `core/theme/theme.dart` builds `ThemeData` from the seed color.
- `core/theme/theme_notifier.dart` persists theme + accent selection.

**Storage + backup**
- `core/storage/key_value_store.dart` abstracts SharedPreferences.
- `core/storage/app_prefs_keys.dart` centralizes keys.
- `core/storage/app_backup_service.dart` exports/imports prefs as JSON.

**Localization**
- `lib/l10n/*.arb` are the source of truth.
- `lib/l10n/gen/*.dart` are generated and should not be edited by hand.

## Pokemon Feature

```
features/pokemon/
  domain/       # pure business logic + interfaces
  data/         # persistence + platform adapters
  shared/       # feature‑level helpers/state
  presentation/ # pages + widgets + UI helpers
  overlay/      # Android overlay UI
```

### Domain
- **Entities**: `domain/entities/pokemon.dart` (core data shape).
- **Repository interfaces**:
  - `domain/repositories/pokemon_repository.dart`
  - `domain/repositories/stats_repository.dart`
- **Use cases**:
  - `toggle_caught.dart`, `save_custom_pokemon.dart`, etc.
- **Services**:
  - `domain/services/stats_aggregation_service.dart` for stats summary logic.
  - `domain/services/counter_sync.dart` (overlay sync contract).

### Data
- **Datasources**: low‑level I/O (prefs, overlay channel).
  - `data/datasources/pokemon_storage.dart`
  - `data/datasources/counter_sync_service.dart`
- **Repositories**:
  - `data/repositories/prefs_pokemon_repository.dart`
  - `data/repositories/stats_repository_impl.dart`
- **Static assets**: `data/pokemon_names.dart`

### Shared (feature‑level helpers)
- **State**: controllers used by UI
  - `shared/state/counter_controller.dart`
  - `shared/state/detail_sprite_controller.dart`
- **Services**:
  - `shared/services/hunt_state_service.dart` (start/caught/daily logic)
  - `shared/services/sprite_service.dart` (sprite caching/parsing)
  - `shared/services/daily_counts_service.dart`
- **Utils**:
  - `shared/utils/dex_utils.dart` (dex parsing/gen ranges)
  - `shared/utils/counter_keys.dart` (prefs key naming)
  - `shared/utils/sprite_ordering.dart`, `sprite_parser.dart`, `formatters.dart`

### Presentation
- **Pages**:
  - `pokemon_list_page.dart`
  - `pokemon_detail_page.dart`
  - `pokemon_stats_page.dart`
  - `pokemon_game_stats_page.dart`
- **Dialogs / sheets**:
  - `presentation/widgets/dialogs/*`
  - `presentation/bottom_sheets/*`
- **Reusable widgets**:
  - `presentation/widgets/common/*`
  - `presentation/widgets/list/*`
  - `presentation/widgets/detail/*`
  - `presentation/widgets/stats/*`
- **Helpers**:
  - `presentation/utils/dialogs.dart` (`showScaledDialog`)
  - `presentation/utils/pokemon_sheets.dart` (`showPokemonBottomSheet`)

### Overlay
- `overlay/counter_overlay.dart` renders the Android floating counter.
- Uses `CounterSyncService` + `CounterKeys` to stay in sync with app state.

## Data Flow (examples)

**Counter flow**
1. `PokemonDetailPage` uses `CounterController`.
2. `CounterController` reads/writes via `CounterSyncService` and `HuntStateService`.
3. Counter state persists in prefs using keys from `CounterKeys`.
4. Overlay uses `CounterSyncService` to show the same state.

**Stats flow**
1. `PokemonStatsPage` requests stats from `StatsAggregationService`.
2. `StatsAggregationService` pulls data from `StatsRepository`.
3. Repository loads data from storage and returns a `StatsSummary`.
4. UI renders `StatsCard` + `StatsRow` + charts with that summary.

**Sprites**
1. `SpriteService` parses sprite manifests and builds sprite lists.
2. `sprite_ordering.dart` keeps ordering consistent across views.
3. UI uses `PokemonImage` / `AppImage` for consistent fallback rendering.

**Backup**
- Settings uses `AppBackupService` to export/import JSON of prefs.

## UI Patterns You Use

- **Tokens first**: sizes, spacing, radii, colors come from `core/theme/*`.
- **Reusable rows**:
  - `StatsRow` for table‑like rows
  - `SelectableRow` for list selections
- **Expandable sections**:
  - `StatsExpandableSection` for “Show all / Show less”
  - `CollapsibleSection` for list page groups
- **Dialog/sheet consistency**:
  - `showScaledDialog` for dialogs
  - `showPokemonBottomSheet` + `SafeAreaSheet` for sheets

## State Management

- **Provider** + `ChangeNotifier` for app‑level state:
  - `ThemeNotifier`, `LocaleNotifier`, controllers
- Controllers hold UI state and coordinate services/repositories.

## Where to Change What

- **Theme/spacing/typography**: `core/theme/*`
- **Storage keys**: `core/storage/app_prefs_keys.dart`
- **Stats aggregation**: `domain/services/stats_aggregation_service.dart`
- **Overlay behavior**: `data/datasources/counter_sync_service.dart`
- **Sprite ordering/parsing**: `shared/utils/sprite_ordering.dart`

## Design Guideline (keeps code readable)

- Keep **business rules** in services/usecases, not in widget build methods.
- Keep **prefs key naming** in one place (`CounterKeys`, `AppPrefsKeys`).
- Use **tokens** rather than magic numbers.
- Prefer **small reusable widgets** for repeated UI blocks.

If you want, I can keep this doc updated as you add features (stats charts,
reorder sheets, export/import, etc.) and link to specific files. 
