import 'package:flutter/material.dart';
import 'package:shiny_counter/core/theme/tokens.dart';

class PokemonFieldStyles {
  const PokemonFieldStyles._();

  static const TextStyle label = TextStyle(
    fontSize: AppSizes.sheetFieldLabel,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle hint = TextStyle(fontSize: AppSizes.sheetFieldHint);

  static const TextStyle input = TextStyle(
    fontSize: AppSizes.sheetFieldText,
    fontWeight: FontWeight.w800,
  );
}

class PokemonFieldDecorations {
  const PokemonFieldDecorations._();

  static const OutlineInputBorder _outlinedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadii.sm)),
  );

  static InputDecoration standard({
    String? labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDense = false,
    EdgeInsetsGeometry? contentPadding,
    InputBorder? border,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: labelText == null ? null : PokemonFieldStyles.label,
      hintStyle: hintText == null ? null : PokemonFieldStyles.hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      contentPadding: contentPadding,
      border: border ?? _outlinedBorder,
    );
  }
}
