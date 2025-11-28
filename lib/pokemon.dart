class Pokemon {
  final String name;
  final String imagePath;
  final bool isLocalFile;

  const Pokemon({
    required this.name,
    required this.imagePath,
    this.isLocalFile = false,
  });
}
