import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image_provider.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/shimmer_box.dart';
import 'package:shiny_counter/features/pokemon/shared/services/sprite_service.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_ordering.dart';
import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

class DetailSpriteViewer extends StatefulWidget {
  const DetailSpriteViewer({super.key, required this.pokemon});

  final Pokemon pokemon;

  @override
  State<DetailSpriteViewer> createState() => _DetailSpriteViewerState();
}

class _DetailSpriteViewerState extends State<DetailSpriteViewer> {
  late final PageController _spritePager;
  int _currentSpriteIndex = 0;
  bool _showNormal = false;
  bool _spritesLoading = true;
  List<String> _shinySprites = [];
  final Map<String, String?> _normalMap = {};

  @override
  void initState() {
    super.initState();
    _spritePager = PageController();
    _loadSprites();
  }

  @override
  void dispose() {
    _spritePager.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DetailSpriteViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pokemon.id != widget.pokemon.id ||
        oldWidget.pokemon.imagePath != widget.pokemon.imagePath) {
      _currentSpriteIndex = 0;
      _showNormal = false;
      _normalMap.clear();
      _shinySprites = [];
      _loadSprites();
    }
  }

  Future<void> _loadSprites() async {
    final parsed = SpriteParser.parse(widget.pokemon.imagePath.split('/').last);
    if (parsed == null) {
      if (mounted) {
        setState(() => _spritesLoading = false);
      }
      return;
    }

    setState(() => _spritesLoading = true);
    final service = context.read<SpriteService>();
    final assets = await service.spritesForDex(parsed.dex);
    if (!mounted) return;

    final shiny = assets.where((p) => p.shiny).toList()
      ..sort(compareSpritesForDetail);
    final normal = assets.where((p) => !p.shiny).toList()
      ..sort(compareSpritesForDetail);
    final normalMap = <String, String?>{};
    for (final sprite in shiny) {
      final match = normal.firstWhere(
        (candidate) =>
            candidate.form == sprite.form && candidate.gender == sprite.gender,
        orElse: () => sprite,
      );
      normalMap[sprite.path] = match.shiny ? null : match.path;
    }

    setState(() {
      _normalMap
        ..clear()
        ..addAll(normalMap);
      _shinySprites = shiny.map((e) => e.path).toList();
      _currentSpriteIndex = 0;
      _showNormal = false;
      _spritesLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sprites = _sprites();
    final canSwipe = sprites.length > 1;

    _precacheSprites(context, sprites);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _toggleNormalSprite(sprites),
          child: SizedBox(
            height: AppSizes.detailImageSize,
            child: _spritesLoading
                ? const ShimmerBox(size: AppSizes.detailImageSize)
                : PageView.builder(
                    controller: _spritePager,
                    allowImplicitScrolling: true,
                    itemCount: sprites.length,
                    onPageChanged: (idx) => setState(() {
                      _currentSpriteIndex = idx;
                      _showNormal = false;
                    }),
                    itemBuilder: (context, index) {
                      final shinyPath = sprites[index];
                      final normalPath = _normalMap[shinyPath];
                      final showNormal = _showNormal && normalPath != null;
                      final path = showNormal ? normalPath : shinyPath;
                      return Center(
                        child: AnimatedSwitcher(
                          duration: AppAnim.switcher,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: SizedBox(
                            key: ValueKey(path),
                            width: AppSizes.detailImageSize,
                            height: AppSizes.detailImageSize,
                            child: PokemonImage(
                              path: path,
                              isLocalFile: widget.pokemon.isLocalFile,
                              borderRadius: 0,
                              fallbackIcon: Icons.catching_pokemon,
                              fallbackIconSize: AppSizes.detailImageFallback,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        if (canSwipe) ...[
          const SizedBox(height: AppSpacing.sm),
          _SpritePageIndicator(
            count: sprites.length,
            activeIndex: _currentSpriteIndex,
            colors: colors,
          ),
        ],
      ],
    );
  }

  List<String> _sprites() {
    if (_shinySprites.isNotEmpty) return _shinySprites;

    final sprites = <String>[widget.pokemon.imagePath];
    final normal = _deriveNormalPath(widget.pokemon.imagePath);
    if (normal != null && normal != widget.pokemon.imagePath) {
      sprites.add(normal);
    }
    return sprites;
  }

  void _toggleNormalSprite(List<String> sprites) {
    final shiny = sprites[_currentSpriteIndex];
    final normal = _normalMap[shiny];
    if (normal != null) {
      setState(() => _showNormal = !_showNormal);
    }
  }

  void _precacheSprites(BuildContext context, List<String> sprites) {
    final assetPaths = <String>[];
    for (final path in sprites) {
      _collectPrecachePath(context, path, assetPaths);
      final normal = _normalMap[path];
      if (normal != null) {
        _collectPrecachePath(context, normal, assetPaths);
      }
    }
    if (assetPaths.isNotEmpty) {
      final service = context.read<SpriteService>();
      unawaited(service.precacheSpritePaths(context, assetPaths));
    }
  }

  void _collectPrecachePath(
    BuildContext context,
    String path,
    List<String> assetPaths,
  ) {
    if (widget.pokemon.isLocalFile && !path.startsWith('assets/')) {
      precacheImage(pokemonImageProvider(path, isLocalFile: true), context);
      return;
    }
    assetPaths.add(path);
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

class _SpritePageIndicator extends StatelessWidget {
  const _SpritePageIndicator({
    required this.count,
    required this.activeIndex,
    required this.colors,
  });

  final int count;
  final int activeIndex;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: AppAnim.switcher,
          curve: AppAnim.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: active
              ? AppSizes.pageIndicatorDotActive
              : AppSizes.pageIndicatorDot,
          height: active
              ? AppSizes.pageIndicatorDotActive
              : AppSizes.pageIndicatorDot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppButtonPalette.primaryFill(
              colors,
            ).withValues(alpha: active ? 1 : 0.5),
          ),
        );
      }),
    );
  }
}
