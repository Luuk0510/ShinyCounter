import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class RoundedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RoundedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.foregroundColor,
    this.iconTheme,
  });

  final Widget title;
  final List<Widget>? actions;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;

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
      foregroundColor: foregroundColor,
      surfaceTintColor: Colors.transparent,
      iconTheme:
          iconTheme ?? const IconThemeData(size: AppSizes.appBarActionIcon),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppRadii.lg),
        ),
      ),
      flexibleSpace: Builder(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadii.lg),
              ),
            ),
          );
        },
      ),
      title: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: title,
            ),
          );
        },
      ),
      actions: actions,
    );
  }
}
