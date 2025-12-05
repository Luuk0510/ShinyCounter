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

  List<_SpriteOption> get sprites => List.unmodifiable(_sprites);
  _SpriteOption? get selected => _selectedSprite;
  bool get loading => _loading;
  String get search => _search;

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
    if (_search.isEmpty) return _sprites;
    final term = _search.toLowerCase();
    return _sprites.where((s) {
      final name = _names?.nameFor(s.dex).toLowerCase() ?? '';
      final combined = '${s.dex} $name';
      return combined.contains(term);
    }).toList();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void clearSearch() => setSearch('');

  void select(_SpriteOption sprite) {
    _selectedSprite = sprite;
    notifyListeners();
  }

  String displayName(_SpriteOption sprite) =>
      _names?.nameFor(sprite.dex) ?? 'Pokémon #${sprite.dex}';

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
            const SizedBox(height: AppSpacing.md),
            if (controller.selected != null)
              Text(
                'Selected: ${controller.displayName(controller.selected!)}',
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
          onPressed: () {
            final sprite = controller.selected;
            if (sprite == null) return;
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

class _SpritePicker extends StatelessWidget {
  const _SpritePicker({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddPokemonController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: controller.setSearch,
          decoration: InputDecoration(
            hintText: 'Search by name or dex',
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
