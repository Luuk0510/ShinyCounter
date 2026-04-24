import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';
import 'package:shiny_counter/features/pokemon/presentation/widgets/common/rounded_app_bar.dart';

class StatsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StatsAppBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return RoundedAppBar(title: title, actions: actions);
  }
}
