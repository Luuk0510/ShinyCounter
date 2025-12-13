import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider pokemonImageProvider(String path, {required bool isLocalFile}) {
  if (isLocalFile && !path.startsWith('assets/')) {
    return FileImage(File(path));
  }
  return AssetImage(path);
}
