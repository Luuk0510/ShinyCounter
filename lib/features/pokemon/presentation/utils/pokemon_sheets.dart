import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

Future<T?> showPokemonBottomSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool showDragHandle = false,
  AnimationController? transitionController,
  double? barrierOpacity,
  Color? backgroundColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: showDragHandle,
    transitionAnimationController: transitionController,
    backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
    barrierColor: Colors.black.withValues(
      alpha: barrierOpacity ?? AppOpacity.modalBarrier,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
    ),
    builder: builder,
  );
}
