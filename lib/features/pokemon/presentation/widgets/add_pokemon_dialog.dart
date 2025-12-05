import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/data/pokemon_names.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class AddPokemonController extends ChangeNotifier {
  AddPokemonController({required SpriteService spriteService})
    : _spriteService = spriteService {
    _init();
  }

  final SpriteService _spriteService;

  final List<_SpriteOption> _sprites = [];
  _SpriteOption? _selectedSprite;
  String _search = '';
  bool _loading = true;
  PokemonNames? _names;
  int? _selectedGen; // null = all

  List<_SpriteOption> get sprites => List.unmodifiable(_sprites);
  _SpriteOption? get selected => _selectedSprite;
  bool get loading => _loading;
  String get search => _search;
  int? get selectedGen => _selectedGen;

  Future<void> _init() async {
    await Future.wait([_loadNames(), _loadSprites()]);
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadNames() async {
    _names = await PokemonNames.load();
  }

  Future<void> _loadSprites() async {
    try {
      final parsedSprites = await _spriteService.loadSprites(refresh: true);
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
        if (current == null ||
            option.genderPriority! < current.genderPriority!) {
          chosen[option.dex] = option;
        }
      }
      _sprites
        ..clear()
        ..addAll(
          chosen.values.toList()..sort((a, b) => a.dex.compareTo(b.dex)),
        );
    } catch (_) {
      _sprites.clear();
    }
  }

  List<_SpriteOption> get filteredSprites {
    final source = _selectedGen == null
        ? _sprites
        : _sprites.where(_matchesSelectedGen).toList();
    if (_search.isEmpty) return source;
    final term = _search.toLowerCase();
    return source.where((s) {
      final name = _names?.nameFor(s.dex).toLowerCase() ?? '';
      final combined = '${s.dex} $name';
      return combined.contains(term);
    }).toList();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setGen(int? gen) {
    _selectedGen = gen;
    notifyListeners();
  }

  void clearSearch() => setSearch('');

  void select(_SpriteOption sprite) {
    _selectedSprite = sprite;
    notifyListeners();
  }

  String displayName(_SpriteOption sprite) =>
      _names?.nameFor(sprite.dex) ?? 'Pokémon #${sprite.dex}';

  bool _matchesSelectedGen(_SpriteOption sprite) {
    final gen = _selectedGen;
    if (gen == null) return true;
    final dexNum = int.tryParse(sprite.dex) ?? 0;
    final range = _genRanges[gen];
    if (range == null) return true;
    return dexNum >= range.$1 && dexNum <= range.$2;
  }

  static const Map<int, (int, int)> _genRanges = {
    1: (1, 151),
    2: (152, 251),
    3: (252, 386),
    4: (387, 493),
    5: (494, 649),
    6: (650, 721),
    7: (722, 809),
    8: (810, 905),
    9: (906, 1025),
  };

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
}

class AddPokemonDialog extends StatelessWidget {
  const AddPokemonDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddPokemonController>(
      create: (_) =>
          AddPokemonController(spriteService: context.read<SpriteService>()),
      child: const _AddPokemonView(),
    );
  }
}

class _AddPokemonView extends StatelessWidget {
  const _AddPokemonView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<AddPokemonController>();
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.none,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      title: Text(
        l10n.addDialogTitle,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SpritePicker(colors: colors),
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
            foregroundColor: colors.primary,
            side: BorderSide(color: colors.primary, width: 1.4),
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
          onPressed: controller.selected == null
              ? null
              : () {
                  final sprite = controller.selected!;
                  final name = controller.displayName(sprite);
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
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            disabledBackgroundColor:
                colors.onSurfaceVariant.withValues(alpha: 0.2),
            disabledForegroundColor:
                colors.onSurfaceVariant.withValues(alpha: 0.6),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(
            l10n.choose,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SpritePicker extends StatelessWidget {
  const _SpritePicker({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddPokemonController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: controller.setSearch,
                decoration: InputDecoration(
                  hintText: context.l10n.searchByNameOrDex,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
                  ),
                  isDense: true,
                  suffixIcon: controller.search.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: controller.clearSearch,
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 120,
              child: DropdownButtonFormField<int?>(
                value: controller.selectedGen,
                isDense: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: controller.setGen,
                items: const [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 1,
                    child: Text('Gen 1'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 2,
                    child: Text('Gen 2'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 3,
                    child: Text('Gen 3'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 4,
                    child: Text('Gen 4'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 5,
                    child: Text('Gen 5'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 6,
                    child: Text('Gen 6'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 7,
                    child: Text('Gen 7'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 8,
                    child: Text('Gen 8'),
                  ),
                  DropdownMenuItem<int?>(
                    value: 9,
                    child: Text('Gen 9'),
                  ),
                ],
              ),
            ),
          ],
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
            height: 400,
            child: controller.loading
                ? const Center(child: CircularProgressIndicator())
                : controller.filteredSprites.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'No sprites found',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.filteredSprites.length,
                    itemBuilder: (context, index) {
                      final sprite = controller.filteredSprites[index];
                      final selected = sprite == controller.selected;
                      final name = controller.displayName(sprite);
                      return InkWell(
                        onTap: () => controller.select(sprite),
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
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          height: 104,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                borderRadius: BorderRadius.circular(
                                  AppRadii.sm,
                                ),
                                child: Image.asset(
                                  sprite.path,
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Icon(Icons.check_circle, color: colors.primary),
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
}

class _SpriteOption {
  _SpriteOption({
    required this.dex,
    required this.path,
    required this.genderPriority,
  });

  final String dex;
  final String path;
  final int? genderPriority; // lower is better

  String get label => 'Pokédex #$dex';
}

String _generateId(String dex) =>
    'custom_${dex}_${DateTime.now().microsecondsSinceEpoch}';

Future<Pokemon?> showAddPokemonDialog(BuildContext context) {
  return showDialog<Pokemon?>(
    context: context,
    builder: (_) => const AddPokemonDialog(),
  );
}
