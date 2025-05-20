class PrecachingStatus {
  final int downloadedBytes;
  final int totalTiles;
  final int completedTiles;

  PrecachingStatus({
    required this.downloadedBytes,
    required this.totalTiles,
    required this.completedTiles,
  });

  double get percent => totalTiles == 0 ? 0 : completedTiles / totalTiles;
  String get downloadedMB =>
      (downloadedBytes / (1024 * 1024)).toStringAsFixed(2);
}
