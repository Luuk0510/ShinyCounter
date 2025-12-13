import 'package:shiny_counter/features/pokemon/shared/utils/sprite_parser.dart';

bool isMegaOrGmaxForm(String form) {
  final lower = form.toLowerCase();
  return lower.contains('mega') || lower.contains('gmax');
}

int spriteFormRankForDetail(String form) {
  final lower = form.toLowerCase();
  // Base/regular forms first, then mega, then gmax.
  if (lower.contains('mega')) return 1;
  if (lower.contains('gmax')) return 2;
  return 0;
}

int compareSpritesForDetail(ParsedSprite a, ParsedSprite b) {
  final rankA = spriteFormRankForDetail(a.form);
  final rankB = spriteFormRankForDetail(b.form);
  if (rankA != rankB) return rankA.compareTo(rankB);

  final form = a.form.compareTo(b.form);
  if (form != 0) return form;

  final gender = a.gender.compareTo(b.gender);
  if (gender != 0) return gender;

  return a.path.compareTo(b.path);
}
