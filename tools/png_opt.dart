// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';
import 'package:image/image.dart';

void main() {
  final dirs = [Directory('assets/pokemons'), Directory('assets/games')];
  for (final dir in dirs) {
    for (final file in dir.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.png'),
    )) {
      final img = decodePng(file.readAsBytesSync());
      if (img == null) continue;
      final out = encodePng(img, level: 9); // lossless, max compression
      file.writeAsBytesSync(out);
      print('Compressed ${file.path}');
    }
  }
}
