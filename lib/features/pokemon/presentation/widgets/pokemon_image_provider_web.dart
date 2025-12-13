import 'package:flutter/material.dart';

ImageProvider pokemonImageProvider(String path, {required bool isLocalFile}) {
  return AssetImage(path);
}
