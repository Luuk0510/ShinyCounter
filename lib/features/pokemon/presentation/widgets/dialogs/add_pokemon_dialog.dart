import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/data/pokemon_names.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/dialogs/dialog_entry.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/filters/search_gen_filter_row.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_ordering.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';

class AddPokemonController extends ChangeNotifier {
  AddPokemonController({required SpriteService spriteService})
    : _spriteService = spriteService {
    _init();
  }

  final SpriteService _spriteService;

  final List<SpriteOption> _sprites = [];
  SpriteOption? _selectedSprite;
  String _search = '';
  bool _loading = true;
  PokemonNames? _names;
  int? _selectedGen; // null = all

  List<SpriteOption> get sprites => List.unmodifiable(_sprites);
  SpriteOption? get selected => _selectedSprite;
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
      final Map<String, SpriteOption> chosen = {};
      for (final parsed in parsedSprites) {
        if (!parsed.shiny) continue; // only shiny choices
        if (isMegaOrGmaxForm(parsed.form)) continue;

        final priority = _genderPriority(parsed.gender);
        if (priority == null) continue;

        final option = SpriteOption(
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

  List<SpriteOption> get filteredSprites {
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

  void select(SpriteOption sprite) {
    _selectedSprite = sprite;
    notifyListeners();
  }

  String displayName(SpriteOption sprite) =>
      _names?.nameFor(sprite.dex) ?? 'Pokémon #${sprite.dex}';

  bool _matchesSelectedGen(SpriteOption sprite) {
    final gen = _selectedGen;
    if (gen == null) return true;
    final dexNum = int.tryParse(sprite.dex);
    if (dexNum == null) return true;
    return isDexInGen(dexNum, gen);
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
    final media = MediaQuery.of(context);
    final keyboardOpen = media.viewInsets.bottom > 0;
    final insetBottom =
        AppInsets.dialog.bottom + (keyboardOpen ? 0 : media.viewPadding.bottom);

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      insetPadding: AppInsets.dialog.copyWith(bottom: insetBottom),
      contentPadding: EdgeInsets.fromLTRB(
        AppInsets.dialog.horizontal / 2,
        AppSpacing.none,
        AppInsets.dialog.horizontal / 2,
        AppSpacing.none,
      ),
      title: Text(
        l10n.addDialogTitle,
        textAlign: TextAlign.center,
        style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
      ),
      content: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          final viewInsets = media.viewInsets.bottom;
          final availableHeight = (media.size.height - viewInsets).clamp(
            0,
            media.size.height,
          );
          final maxContentHeight =
              (availableHeight * AppSizes.dialogHeightFactor)
                  .clamp(AppSizes.dialogMinHeight, availableHeight)
                  .toDouble();
          return SizedBox(
            width: AppSizes.dialogMaxWidth,
            height: maxContentHeight,
            child: _SpritePicker(
              colors: colors,
              availableHeight: maxContentHeight,
            ),
          );
        },
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
              vertical: AppSpacing.xs,
            ),
          ),
          child: Text(l10n.cancel, style: AppTypography.button),
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
            disabledBackgroundColor: colors.onSurfaceVariant.withValues(
              alpha: 0.2,
            ),
            disabledForegroundColor: colors.onSurfaceVariant.withValues(
              alpha: 0.6,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xs,
            ),
          ),
          child: Text(l10n.choose, style: AppTypography.button),
        ),
      ],
    );
  }
}

class _SpritePicker extends StatefulWidget {
  const _SpritePicker({required this.colors, required this.availableHeight});

  final ColorScheme colors;
  final double availableHeight;

  @override
  State<_SpritePicker> createState() => _SpritePickerState();
}

class _SpritePickerState extends State<_SpritePicker> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddPokemonController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchGenFilterRow(
          searchController: _searchController,
          hintText: context.l10n.searchByNameOrDex,
          query: controller.search,
          cancelTooltip: context.l10n.cancel,
          onQueryChanged: controller.setSearch,
          onClearQuery: () {
            controller.clearSearch();
            _searchController.clear();
          },
          allGensLabel: context.l10n.filterAllGens,
          selectedGen: controller.selectedGen,
          onGenChanged: (gen) {
            controller.setGen(gen);
            _scrollController.animateTo(
              0,
              duration: AppAnim.normal,
              curve: AppAnim.easeOut,
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.listMinHeight,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.colors.outlineVariant.withValues(alpha: 0.6),
                ),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: controller.loading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.filteredSprites.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              color: widget.colors.onSurfaceVariant,
                              size: AppSizes.spriteThumb,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              context.l10n.noPokemonFound,
                              style: AppTypography.button.copyWith(
                                color: widget.colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              context.l10n.tryAnotherFilter,
                              textAlign: TextAlign.center,
                              style: AppTypography.button.copyWith(
                                color: widget.colors.onSurfaceVariant
                                    .withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      interactive: true,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        primary: false,
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
                                    ? widget.colors.primary.withValues(
                                        alpha: 0.08,
                                      )
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadii.md,
                                ),
                              ),
                              height: AppSizes.listItemMinHeight,
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
                                          style: AppTypography.button.copyWith(
                                            color: selected
                                                ? widget.colors.primary
                                                : widget
                                                      .colors
                                                      .onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          name,
                                          style: AppTypography.sectionTitle
                                              .copyWith(
                                                color: selected
                                                    ? widget.colors.primary
                                                    : widget.colors.onSurface,
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
                                    child: PokemonImage(
                                      path: sprite.path,
                                      isLocalFile: false,
                                      width: AppSizes.spriteThumb,
                                      height: AppSizes.spriteThumb,
                                      borderRadius: AppRadii.sm,
                                      fallbackIconSize:
                                          AppSizes.spriteThumb * 0.55,
                                    ),
                                  ),
                                  if (selected) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(
                                      Icons.check_circle,
                                      color: widget.colors.primary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class SpriteOption {
  const SpriteOption({
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
  return showGeneralDialog<Pokemon?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: AppAnim.dialogDuration,
    pageBuilder: (context, animation, secondaryAnimation) =>
        const AddPokemonDialog(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppAnim.dialogCurve,
      );
      final scale = Tween<double>(begin: 0.65, end: 1).animate(curved);
      return DialogEntry(
        child: FadeTransition(
          opacity: animation,
          child: Transform.scale(scale: scale.value, child: child),
        ),
      );
    },
  );
}
