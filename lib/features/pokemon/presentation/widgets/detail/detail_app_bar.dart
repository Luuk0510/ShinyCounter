import 'package:flutter/material.dart';
import 'package:shiny_counter/core/l10n/l10n.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.pokemonName,
    required this.onEdit,
    required this.onTogglePill,
  });

  final String pokemonName;
  final VoidCallback onEdit;
  final VoidCallback onTogglePill;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: AppSizes.toolbarHeight,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(size: AppSizes.appBarActionIcon),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
      ),
      flexibleSpace: Builder(
        builder: (context) {
          final scopedCard = Theme.of(context).cardColor;
          return Container(
            decoration: BoxDecoration(
              color: scopedCard,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.lg),
              ),
            ),
          );
        },
      ),
      title: Text(
        pokemonName,
        style: Theme.of(context).textTheme.titleLarge?.merge(
          AppTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      actions: [
        IconButton(
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.edit),
          tooltip: context.l10n.editCounterTooltip,
          onPressed: onEdit,
        ),
        IconButton(
          iconSize: AppSizes.appBarActionIcon,
          icon: const Icon(Icons.open_in_new_rounded),
          tooltip: context.l10n.openOverlayTooltip,
          onPressed: onTogglePill,
        ),
      ],
    );
  }
}
