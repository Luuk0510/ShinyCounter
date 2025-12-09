class Pokemon {
  final String id;
  final String name;
  final String imagePath;
  final bool isLocalFile;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isLocalFile = false,
  });
}
