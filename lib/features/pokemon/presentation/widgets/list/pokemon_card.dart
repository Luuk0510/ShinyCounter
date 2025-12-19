import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/domain/entities/pokemon.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/pokemon_image.dart';

class PokemonCard extends StatefulWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.isCaught,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Pokemon pokemon;
  final bool isCaught;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  Timer? _holdTimer;
  bool _showActions = false;
  bool _suppressTap = false;

  bool get _hasActions => widget.onEdit != null || widget.onDelete != null;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHoldTimer() {
    if (!_hasActions || _showActions) return;
    _holdTimer?.cancel();
    _holdTimer = Timer(AppAnim.longPressDelay, _showActionOverlay);
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _showActionOverlay() {
    if (!mounted || !_hasActions) return;
    _holdTimer = null;
    setState(() {
      _showActions = true;
      _suppressTap = true;
    });
    HapticFeedback.mediumImpact();
  }

  void _handleTap() {
    if (_suppressTap) {
      _suppressTap = false;
      return;
    }
    if (_showActions) {
      setState(() => _showActions = false);
      return;
    }
    widget.onTap();
  }

  void _handleTapCancel() {
    _cancelHoldTimer();
  }

  void _handleTapDown(TapDownDetails _) {
    _startHoldTimer();
  }

  void _handleTapUp(TapUpDetails _) {
    _cancelHoldTimer();
  }

  void _handleAction(VoidCallback? action) {
    if (action == null) return;
    setState(() => _showActions = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.cardPaddingH,
        vertical: AppSizes.cardPaddingV,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420;
          final imageSize = isCompact
              ? AppSizes.pokemonImageSmall
              : AppSizes.pokemonImageLarge;
          final fontSize = isCompact
              ? AppSizes.pokemonNameSmall
              : AppSizes.pokemonNameLarge;
          final horizontalGap = isCompact
              ? AppSizes.pokemonGapSmall
              : AppSizes.pokemonGapLarge;
          final contentPadding = isCompact
              ? AppSizes.pokemonContentSmall
              : AppSizes.pokemonContentLarge;
          final chevronSize = isCompact
              ? AppSizes.pokemonChevronSmall
              : AppSizes.pokemonChevronLarge;
          final colors = Theme.of(context).colorScheme;

          return Card(
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleTap,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: Row(
                      children: [
                        _buildImage(imageSize),
                        SizedBox(width: horizontalGap),
                        Expanded(
                          child: Text(
                            widget.pokemon.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: chevronSize),
                      ],
                    ),
                  ),
                  if (_hasActions)
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: !_showActions,
                        child: AnimatedOpacity(
                          opacity: _showActions ? 1 : 0,
                          duration: AppAnim.normal,
                          curve: AppAnim.easeOutCubic,
                          child: AnimatedScale(
                            scale: _showActions
                                ? 1.0
                                : AppAnim.listItemPopStartScale,
                            duration: AppAnim.normal,
                            curve: AppAnim.easeOutCubic,
                            child: _ActionOverlay(
                              blurRadius: AppSizes.cardActionBlur,
                              borderRadius: AppSizes.cardBorderRadius,
                              onEdit: widget.onEdit == null
                                  ? null
                                  : () => _handleAction(widget.onEdit),
                              onDelete: widget.onDelete == null
                                  ? null
                                  : () => _handleAction(widget.onDelete),
                              colors: colors,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(double size) {
    return PokemonImage(
      path: widget.pokemon.imagePath,
      isLocalFile: widget.pokemon.isLocalFile,
      width: size,
      height: size,
      fallbackIconSize: size * 0.45,
    );
  }
}

class _ActionOverlay extends StatelessWidget {
  const _ActionOverlay({
    required this.blurRadius,
    required this.borderRadius,
    required this.colors,
    this.onEdit,
    this.onDelete,
  });

  final double blurRadius;
  final double borderRadius;
  final ColorScheme colors;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: Container(
                color: colors.surface.withValues(
                  alpha: AppOpacity.cardActionScrim,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      _ActionIcon(
                        icon: Icons.edit,
                        onPressed: onEdit!,
                        color: colors.primary,
                        size: AppSizes.cardActionIcon,
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: AppSpacing.sm),
                    if (onDelete != null)
                      _ActionIcon(
                        icon: Icons.delete_outline,
                        onPressed: onDelete!,
                        color: colors.error,
                        size: AppSizes.cardActionIcon,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(color);
    final iconColor = hsl
        .withLightness((hsl.lightness * 0.9).clamp(0.0, 1.0))
        .toColor();
    final iconSize = size * AppSizes.cardActionIconScale;
    return Material(
      color: color.withValues(alpha: AppOpacity.cardActionButton),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        onPressed: onPressed,
        constraints: BoxConstraints.tightFor(
          width: size * 3,
          height: size * 2.5,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
