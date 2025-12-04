import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/data/pokemon_names.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class AddPokemonDialog extends StatefulWidget {
  const AddPokemonDialog({super.key});

  @override
  State<AddPokemonDialog> createState() => _AddPokemonDialogState();
}

class _AddPokemonDialogState extends State<AddPokemonDialog> {
  late final SpriteService _spritesRepo;
  List<_SpriteOption> _sprites = [];
  _SpriteOption? _selectedSprite;
  String _search = '';
  bool _loadingSprites = true;
  PokemonNames? _names;

  @override
  @override
  void initState() {
    super.initState();
    _spritesRepo = context.read<SpriteService>();
    _loadSprites();
    _loadNames();
  }

  Future<void> _loadNames() async {
    final names = await PokemonNames.load();
    if (!mounted) return;
    setState(() => _names = names);
  }

  Future<void> _loadSprites() async {
    try {
      final parsedSprites = await _spritesRepo.loadSprites();
      debugPrint('Sprite assets found: ${parsedSprites.length}');
      if (parsedSprites.isEmpty) {
        setState(() => _loadingSprites = false);
        return;
      }
      final Map<String, _SpriteOption> chosen = {};
      for (final parsed in parsedSprites) {
        if (!parsed.shiny) continue; // only shiny choices
        final lowerForm = parsed.form.toLowerCase();
        if (lowerForm.contains('mega') || lowerForm.contains('gmax')) continue;

        final priority = _genderPriority(parsed.gender);
        if (priority == null) continue;

        final option = _SpriteOption(
          dex: parsed.dex,
          path: parsed.path,
          genderPriority: priority,
        );

        final current = chosen[option.dex];
        if (current == null || option.genderPriority < current.genderPriority) {
          chosen[option.dex] = option;
        }
      }
      final list = chosen.values.toList()
        ..sort((a, b) => a.dex.compareTo(b.dex));
      setState(() {
        _sprites = list;
        _loadingSprites = false;
      });
    } catch (_) {
      setState(() => _loadingSprites = false);
    }
  }

  int? _genderPriority(String token) {
    switch (token) {
      case 'm':
      case 'md':
      case 'mo':
        return 0;
      case 'mf':
      case 'uk':
        return 1;
      case 'f':
      case 'fd':
      case 'fo':
        return 2;
      default:
        return null;
    }
  }

  List<_SpriteOption> get _filteredSprites {
    if (_search.isEmpty) return _sprites;
    final term = _search.toLowerCase();
    return _sprites.where((s) {
      final name = _names?.nameFor(s.dex).toLowerCase() ?? '';
      final combined = '${s.dex} $name';
      return combined.contains(term);
    }).toList();
  }

  Widget _buildSpritePicker(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: 'Search by name or dex',
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
            ),
            isDense: true,
            suffixIcon: _search.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _search = ''),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.6),
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: SizedBox(
            height: 320,
            child: _loadingSprites
                ? const Center(child: CircularProgressIndicator())
                : _filteredSprites.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No sprites found',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSprites.length,
                        itemBuilder: (context, index) {
                          final sprite = _filteredSprites[index];
                          final selected = sprite == _selectedSprite;
                          final name = _names?.nameFor(sprite.dex) ??
                              'Pokémon #${sprite.dex}';
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedSprite = sprite;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.primary.withValues(alpha: 0.08)
                                    : Colors.transparent,
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                              ),
                              height: 104,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '#${sprite.dex}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: selected
                                                ? colors.primary
                                                : colors.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                            color: selected
                                                ? colors.primary
                                                : colors.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.sm),
                                    child: Image.asset(
                                      sprite.path,
                                      width: 96,
                                      height: 96,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  if (selected) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(Icons.check_circle,
                                        color: colors.primary),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        l10n.addDialogTitle,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSpritePicker(context),
            const SizedBox(height: AppSpacing.md),
            if (_selectedSprite != null)
              Text(
                'Selected: ${_names?.nameFor(_selectedSprite!.dex) ?? '#${_selectedSprite!.dex}'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop<Pokemon?>(null),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.4,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(
            l10n.cancel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          onPressed: () {
            final sprite = _selectedSprite;
            if (sprite == null) return;
            final name = _names?.nameFor(sprite.dex) ?? 'Pokémon #${sprite.dex}';
            Navigator.of(context).pop<Pokemon?>(
              Pokemon(
                id: _generateId(sprite.dex),
                name: name,
                imagePath: sprite.path,
                isLocalFile: false,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(
            l10n.save,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

String _generateId(String dex) =>
    'custom_${dex}_${DateTime.now().microsecondsSinceEpoch}';

Future<Pokemon?> showAddPokemonDialog(BuildContext context) {
  return showDialog<Pokemon?>(
    context: context,
    builder: (_) => const AddPokemonDialog(),
  );
}

class _SpriteOption {
  _SpriteOption({
    required this.dex,
    required this.path,
    required this.genderPriority,
  });

  final String dex;
  final String path;
  final int genderPriority; // lower is better

  String get label => 'Pokédex #$dex';
}
