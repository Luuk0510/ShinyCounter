# Shiny Counter Code Guide

This document explains how the app is structured, how data flows, and which
patterns the codebase currently uses.

## High-Level Structure

```text
lib/
  core/        # app-wide infrastructure
  features/    # feature code
  l10n/        # ARB + generated localization files
```

## Core

**Dependency setup**
- `core/di/app_locator.dart` initializes long-lived services and concrete implementations.
- `core/di/app_providers.dart` exposes them through `Provider` / `ChangeNotifier`.

**Routing**
- `core/routing/app_router.dart` defines routes and error fallbacks.
- `core/routing/context_extensions.dart` adds typed navigation helpers.

**Theme + tokens**
- `core/theme/` is split by concern: colors, spacing, sizes, radii, typography.
- `core/theme/tokens.dart` re-exports those files so widgets can import one entry.
- `core/theme/theme.dart` builds `ThemeData` from the seed color.
- `core/theme/theme_notifier.dart` persists theme + accent selection.

**Storage + backup**
- `core/storage/key_value_store.dart` abstracts SharedPreferences.
- `core/storage/app_prefs_keys.dart` centralizes keys.
- `core/storage/app_backup_service.dart` exports/imports app-managed prefs as JSON.

**Localization**
- `lib/l10n/*.arb` are the source of truth.
- `lib/l10n/gen/*.dart` are generated and should not be edited by hand.

## Pokemon Feature

```text
features/pokemon/
  domain/       # business logic + interfaces
  data/         # persistence + concrete implementations
  shared/       # feature helpers used across layers
  presentation/ # pages + widgets + UI helpers
  overlay/      # Android overlay UI
```

### Domain
- **Entities**:
  - `domain/entities/pokemon.dart`
  - `domain/entities/counter_state.dart`
  - `domain/entities/stats_models.dart`
- **Repository interfaces**:
  - `domain/repositories/pokemon_repository.dart`
  - `domain/repositories/stats_repository.dart`
- **Services**:
  - `domain/services/stats_aggregation_service.dart`
  - `domain/services/counter_sync.dart`
- **Use cases**:
  - `domain/usecases/get_sprites_for_dex.dart`

### Data
- **Datasources**:
  - `data/datasources/pokemon_storage.dart`
  - `data/datasources/counter_sync_service.dart`
- **Concrete repository/storage implementations**:
  - `PokemonStorage` implements `PokemonRepository`
  - `PokemonStatsRepository` implements `StatsRepository`
- **Static asset helpers**:
  - `data/pokemon_names.dart`

### Shared
Only keep items here when they are used across multiple layers.

- **Services**:
  - `shared/services/hunt_state_service.dart`
  - `shared/services/sprite_service.dart` (`SpriteService` + `PokemonSpriteService`)
  - `shared/services/daily_counts_service.dart`
- **Utils**:
  - `shared/utils/dex_utils.dart`
  - `shared/utils/counter_keys.dart`
  - `shared/utils/sprite_ordering.dart`
  - `shared/utils/sprite_parser.dart`

### Presentation
- **Pages**:
  - `pokemon_list_page.dart`
  - `pokemon_detail_page.dart`
  - `pokemon_stats_page.dart`
  - `pokemon_game_stats_page.dart`
- **Controllers / page state**:
  - `presentation/state/pokemon_list_page_controller.dart`
  - `presentation/state/pokemon_stats_page_controller.dart`
  - `presentation/state/counter_controller.dart`
  - `presentation/state/detail_sprite_controller.dart`
- **Dialogs / sheets**:
  - `presentation/widgets/dialogs/*`
  - `presentation/bottom_sheets/*`
- **Reusable widgets**:
  - `presentation/widgets/common/*`
  - `presentation/widgets/list/*`
  - `presentation/widgets/detail/*`
  - `presentation/widgets/stats/*`
- **Helpers**:
  - `presentation/utils/dialogs.dart`
  - `presentation/utils/pokemon_sheets.dart`
  - `presentation/utils/formatters.dart`
- **Page/UI models**:
  - `presentation/models/pokemon_stats_card_models.dart`

### Overlay
- `overlay/counter_overlay.dart` renders the Android floating counter.
- It uses `CounterSyncService` + `CounterKeys` to stay in sync with app state.

## Data Flow

**Counter flow**
1. `PokemonDetailPage` uses `CounterController`.
2. `CounterController` reads/writes through `CounterSyncService` and `HuntStateService`.
3. Counter state persists in prefs using keys from `CounterKeys`.
4. The overlay uses `CounterSyncService` to show the same state.

**List flow**
1. `PokemonListPage` delegates orchestration to `PokemonListPageController`.
2. `PokemonListPageController` loads and mutates data through `PokemonRepository`.
3. `PokemonStorage` persists the custom list and caught state.
4. The page focuses on dialogs, navigation, and section rendering.

**Stats flow**
1. `PokemonStatsPage` delegates orchestration to `PokemonStatsPageController`.
2. `PokemonStatsPageController` requests data from `StatsAggregationService`.
3. `StatsAggregationService` loads raw source data from `StatsRepository`.
4. `PokemonStatsRepository` reads storage-backed state and returns stats source data.
5. The page renders cards, tables, and charts from the controller summary.

**Sprites**
1. `SpriteService` / `PokemonSpriteService` parse sprite manifests and build sprite lists.
2. `sprite_ordering.dart` keeps ordering consistent across views.
3. UI uses shared image widgets for consistent fallback rendering.

**Backup**
- Settings uses `AppBackupService` to export/import JSON for app-owned preference keys only.

## UI Patterns

- **Tokens first**: sizes, spacing, radii, colors come from `core/theme/*`.
- **Reusable rows**:
  - `StatsRow` for table-like rows
  - `SelectableRow` for list selections
- **Expandable sections**:
  - `StatsExpandableSection` for "Show all / Show less"
  - `CollapsibleSection` for list page groups
- **Dialog/sheet consistency**:
  - `showScaledDialog` for dialogs
  - `showPokemonBottomSheet` + `SafeAreaSheet` for sheets
  - `ConfirmationDialog`, `DialogActionRow`, and `BottomSheetActionRow` for shared actions

## State Management

- `Provider` + `ChangeNotifier` for app-level state and feature controllers.
- Feature pages delegate orchestration to controllers in `presentation/state`.
- Controllers hold loading state, derived getters, async coordination, and disposal safety.

## Where to Change What

- **Theme/spacing/typography**: `core/theme/*`
- **Storage keys**: `core/storage/app_prefs_keys.dart`
- **Stats aggregation**: `domain/services/stats_aggregation_service.dart`
- **Overlay behavior**: `data/datasources/counter_sync_service.dart`
- **Sprite ordering/parsing**: `shared/utils/sprite_ordering.dart`

## Design Guideline

- Keep business rules in services and controllers, not in widget build methods.
- Keep prefs key naming in one place (`CounterKeys`, `AppPrefsKeys`).
- Use tokens rather than magic numbers.
- Prefer small reusable widgets for repeated UI blocks.
- Keep page orchestration in `presentation/state` so pages stay focused on rendering.
