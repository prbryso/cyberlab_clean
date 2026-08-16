class LibraryDashboard {
  final String heroTitle;
  final String heroSubtitle;

  final String featuredSystemId;

  final String featuredSimulationId;

  final List<String> beginnerPath;

  final List<String> intermediatePath;

  final List<String> advancedPath;

  const LibraryDashboard({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.featuredSystemId,
    required this.featuredSimulationId,
    required this.beginnerPath,
    required this.intermediatePath,
    required this.advancedPath,
  });
}
