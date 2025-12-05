import 'package:meta/meta.dart';

@immutable
class ParsedSprite {
  const ParsedSprite({
    required this.dex,
    required this.form,
    required this.gender,
    required this.shiny,
    required this.path,
  });

  final String dex;
  final String form;
  final String gender;
  final bool shiny;
  final String path;
}

class SpriteParser {
  static final RegExp _newPattern = RegExp(
    r'^(\d{4})_([a-z0-9-_]+)_(m|f|mf|mo|fo|md|fd|uk)_(n|s)\.png$',
  );
  static final RegExp _legacyPattern = RegExp(
    r'^poke_capture_(\d{4})_(\d{3})_([a-z]{2,3})_([ng])_.*?_([nr])\.png$',
  );

  static ParsedSprite? parse(String path) {
    final file = path.split('/').last.toLowerCase();

    String dex;
    String form;
    String genderToken;
    String shineFlag;

    if (_newPattern.hasMatch(file)) {
      final m = _newPattern.firstMatch(file)!;
      dex = m.group(1)!;
      form = m.group(2)!; // full descriptor between dex and gender
      genderToken = m.group(3)!;
      shineFlag = m.group(4)!;
    } else if (_legacyPattern.hasMatch(file)) {
      final m = _legacyPattern.firstMatch(file)!;
      dex = m.group(1)!;
      final baseForm = m.group(2)!;
      final formType = m.group(4)!; // n or g
      form = formType == 'g' ? '$baseForm-gmax' : baseForm;
      genderToken = m.group(3)!;
      shineFlag = m.group(5)!;
    } else {
      return null;
    }

    final isShiny = shineFlag == 's' || shineFlag == 'r';
    if (!isShiny && shineFlag != 'n') return null;

    return ParsedSprite(
      dex: dex,
      form: form,
      gender: genderToken,
      shiny: isShiny,
      path: path,
    );
  }
}
