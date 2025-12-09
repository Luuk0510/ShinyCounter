import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class PokemonEmptyState extends StatelessWidget {
  const PokemonEmptyState({
    super.key,
    required this.onAddPressed,
    required this.imageAsset,
    required this.colors,
    required this.title,
    required this.actionLabel,
  });

  final VoidCallback onAddPressed;
  final String imageAsset;
  final ColorScheme colors;
  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            imageAsset,
            width: AppSizes.emptyStateImage,
            height: AppSizes.emptyStateImage,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stack) => const Icon(
              Icons.catching_pokemon,
              size: AppSizes.emptyStateFallback,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.emptyStateTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: AppSizes.emptyStateButtonWidth,
            child: ElevatedButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: AppSizes.emptyStateAction,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.secondary,
                foregroundColor: colors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.emptyStateButtonRadius,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.emptyStateButtonPadding,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
