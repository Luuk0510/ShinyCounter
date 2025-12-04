import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_counters_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/bottom_sheets/edit_daily_counts_sheet.dart';
import 'package:shiny_counter/features/pokemon/presentation/state/counter_controller.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/hunt_info_card.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/daily_counts_list.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/detail_header.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/counter_controls.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/dex_utils.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with WidgetsBindingObserver {
  late final CounterController _controller;
  late final SpriteService _spriteService;
  late final PageController _pageController;
  bool _showShiny = true;
  List<_FormSprite> _forms = [];
  int _currentFormIndex = 0;

  @override
  void initState() {
    super.initState();
    _spriteService = context.read<SpriteService>();
    _pageController = PageController();
    _controller = CounterController(
      pokemon: widget.pokemon,
      sync: context.read(),
      toggleCaughtUseCase: context.read(),
    );
    _loadForms();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(() => mounted ? setState(() {}) : null);
    _controller.init();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.init();
    }
  }

  Future<void> _hapticTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> _increment() async {
    if (_controller.isCaught) return;
    await _hapticTap();
    await _controller.increment();
  }

  Future<void> _decrement() async {
    if (_controller.isCaught || _controller.counter == 0) return;
    await _hapticTap();
    await _controller.decrement();
  }

  Future<void> _toggleCaught() async {
    await _hapticTap();
    await _controller.toggleCaught();
  }

  Future<void> _showEditDialog() async {
    final result = await showModalBottomSheet<EditSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return EditCountersSheet(
          counter: _controller.counter,
          startedAt: _controller.startedAt,
          caughtAt: _controller.caughtAt,
          caughtGame: _controller.caughtGame,
        );
      },
    );

    if (result == null) return;
    if (result.counter != null && result.counter != _controller.counter) {
      await _controller.setCounterManual(result.counter!);
    }
    if (result.startedChanged) {
      await _controller.setStartedAtDate(result.startedAt);
    }
    if (result.caughtChanged) {
      await _controller.setCaughtAtDate(result.caughtAt);
    }
    if (result.gameChanged) {
      await _controller.setCaughtGame(result.caughtGame);
    }
  }

  Future<void> _togglePill() async {
    await _controller.toggleOverlay();
  }

  void _toggleSpriteView() {
    // If forms exist, respect the current form; otherwise toggle base sprite.
    if (_forms.isNotEmpty) {
      final current = _currentFormIndex < _forms.length
          ? _forms[_currentFormIndex]
          : null;
      final hasNormal =
          current?.normalPath ??
          _deriveNormalPath(current?.shinyPath ?? widget.pokemon.imagePath);
      if (current == null || hasNormal == null) return;
      setState(() {
        _showShiny = !_showShiny;
      });
    } else {
      final normal = widget.pokemon.isLocalFile
          ? null
          : _deriveNormalPath(widget.pokemon.imagePath);
      if (normal == null) return;
      setState(() {
        _showShiny = !_showShiny;
      });
    }
  }

  Future<void> _showDailyCountsEditor() async {
    final result = await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).cardColor,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return EditDailyCountsSheet(
          dailyCounts: _controller.dailyCounts,
          dayFormatter: _formatDayKey,
        );
      },
    );

    if (result == null) return;
    await _controller.setDailyCounts(result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Builder(
          builder: (context) {
            final scopedCard = Theme.of(context).cardColor;
            return Container(color: scopedCard);
          },
        ),
        title: Text(
          widget.pokemon.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: context.l10n.editCounterTooltip,
            onPressed: _showEditDialog,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded),
            tooltip: context.l10n.openOverlayTooltip,
            onPressed: _togglePill,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaQuery = MediaQuery.of(context);
          final bottomInset = mediaQuery.viewInsets.bottom;
          final isPortrait = mediaQuery.orientation == Orientation.portrait;
          final bottomPadding =
              mediaQuery.padding.bottom + bottomInset + (isPortrait ? 60 : 16);

          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildImageSection(colors),
                    const SizedBox(height: AppSpacing.sm),
                    _buildCatchButton(colors),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CounterControls(
                            count: _controller.counter,
                            enabled: !_controller.isCaught,
                            onDecrement: _decrement,
                            onIncrement: _increment,
                            onEdit: _showEditDialog,
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IntrinsicWidth(
                                  child: HuntInfoCard(
                                    colors: colors,
                                    startedAt: _controller.startedAt,
                                    caughtAt: _controller.caughtAt,
                                    caughtGame: _controller.caughtGame,
                                    formatter: _formatDate,
                                    onSelectGame: _showEditDialog,
                                    onGameChanged: (value) =>
                                        _controller.setCaughtGame(value),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _showDailyCountsEditor,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: DailyCountsList(
                                      colors: colors,
                                      dailyCounts: _controller.dailyCounts,
                                      dayFormatter: _formatDayKey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '--';
    final local = value.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(local.day)}-${two(local.month)}-${local.year}';
  }

  String _formatDayKey(String key) {
    final parsed = DateTime.tryParse(key);
    if (parsed == null) return key;
    String two(int v) => v.toString().padLeft(2, '0');
    final local = parsed.toLocal();
    return '${two(local.day)}-${two(local.month)}-${local.year}';
  }

  Future<void> _loadForms() async {
    final dex =
        dexFromString(widget.pokemon.imagePath) ??
        dexFromString(widget.pokemon.id);
    if (dex == null) return;
    try {
      final parsedSprites = await _spriteService.loadSprites(refresh: true);
      final entries = parsedSprites.where((p) => p.dex == dex);

      final Map<String, _FormSprite> forms = {};
      for (final parsed in entries) {
        final key =
            '${parsed.form}_${parsed.gender}_${parsed.shiny ? 's' : 'n'}';
        final label =
            '${parsed.form} (${parsed.gender}${parsed.shiny ? ' shiny' : ' normal'})';
        final existing = forms[key] ?? _FormSprite(form: label);
        if (parsed.shiny && existing.shinyPath == null) {
          existing.shinyPath = parsed.path;
          if (existing.normalPath == null) {
            existing.normalPath = _deriveNormalPath(parsed.path);
          }
        } else if (!parsed.shiny && existing.normalPath == null) {
          existing.normalPath = parsed.path;
          if (existing.shinyPath == null) {
            existing.shinyPath = _deriveNormalPath(
              parsed.path,
            )?.replaceFirst('_n.', '_s.');
          }
        }
        forms[key] = existing;
      }
      final list =
          forms.values
              .where((f) => f.shinyPath != null || f.normalPath != null)
              .where((f) => f.form.isNotEmpty)
              .toList()
            ..sort((a, b) {
              int rank(String form) {
                final lower = form.toLowerCase();
                if (lower.contains('gmax')) return 3;
                if (lower.contains('mega')) return 2;
                return 0;
              }

              final rDiff = rank(a.form).compareTo(rank(b.form));
              if (rDiff != 0) return rDiff;
              return a.form.compareTo(b.form);
            });
      if (list.isEmpty) {
        list.add(
          _FormSprite(
            form: 'base',
            shinyPath: widget.pokemon.imagePath,
            normalPath: _deriveNormalPath(widget.pokemon.imagePath),
          ),
        );
      }
      if (list.isEmpty) return;
      setState(() {
        _forms = list;
        _currentFormIndex = 0;
        _showShiny = true;
      });
    } catch (_) {}
  }

  Widget _buildImageSection(ColorScheme colors) {
    if (_forms.isEmpty) {
      final normal = widget.pokemon.isLocalFile
          ? null
          : _deriveNormalPath(widget.pokemon.imagePath);
      return DetailHeader(
        pokemon: widget.pokemon,
        shinyPath: widget.pokemon.imagePath,
        normalPath: normal,
        showShiny: _showShiny,
        onToggleSprite: _toggleSpriteView,
        colors: colors,
        isCaught: _controller.isCaught,
        onToggleCaught: _toggleCaught,
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            physics: const PageScrollPhysics(),
            itemCount: _forms.length,
            onPageChanged: (i) {
              setState(() {
                _currentFormIndex = i;
                _showShiny = true;
              });
            },
            itemBuilder: (context, index) {
              final form = _forms[index];
              return DetailHeader(
                pokemon: widget.pokemon,
                shinyPath:
                    form.shinyPath ??
                    form.normalPath ??
                    widget.pokemon.imagePath,
                normalPath:
                    form.normalPath ??
                    _deriveNormalPath(
                      form.shinyPath ?? widget.pokemon.imagePath,
                    ),
                showShiny: index == _currentFormIndex ? _showShiny : true,
                onToggleSprite: _toggleSpriteView,
                colors: colors,
                isCaught: _controller.isCaught,
                onToggleCaught: _toggleCaught,
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_forms.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_forms.length, (i) {
              final active = i == _currentFormIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 14 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? colors.primary : colors.outlineVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildCatchButton(ColorScheme colors) {
    final l10n = context.l10n;
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        key: const Key('catch_button'),
        onPressed: _toggleCaught,
        style: ElevatedButton.styleFrom(
          backgroundColor: _controller.isCaught
              ? Colors.green.shade600
              : colors.secondary,
          foregroundColor: _controller.isCaught
              ? Colors.white
              : colors.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            _controller.isCaught ? l10n.buttonCaught : l10n.buttonCatch,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  String? _deriveNormalPath(String shinyPath) {
    if (widget.pokemon.isLocalFile) return null;
    if (shinyPath.contains('_s.')) {
      return shinyPath.replaceFirst('_s.', '_n.');
    }
    if (shinyPath.contains('_r.')) {
      return shinyPath.replaceFirst('_r.', '_n.');
    }
    return null;
  }
}

class _FormSprite {
  _FormSprite({required this.form, this.shinyPath, this.normalPath});
  final String form;
  String? shinyPath;
  String? normalPath;
}
