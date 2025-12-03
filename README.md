# ShinyCounter
Pokémon shiny counter app in Flutter.

## Features
- Lijst van Pokémon (custom + basis), alfabetisch met caught-markering.
- Detailpagina met teller, +/-, caught-toggle en handmatige invoer.
- Android overlay (mini-counter) boven andere apps; pin om positie te vergrendelen.
- Custom Pokémon toevoegen/bewerken/verwijderen incl. eigen afbeelding.
- Thema’s: Systeem, Licht, Donker, OLED — keuze wordt onthouden.
- Opslag in SharedPreferences (tellers, caught-status, custom lijst, thema).

## Gebruik
1. `flutter pub get`
2. Start: `flutter run`
3. Tests: `flutter test`

## Notities
- Overlay vraagt “draw over other apps” permissie op Android.
- Pinnen in de overlay maakt hem niet-versleepbaar; ontpin om weer te slepen.
