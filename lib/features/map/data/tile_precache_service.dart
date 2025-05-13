import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:math';
import 'package:http_cache_core/http_cache_core.dart';
import 'package:gabimaps/features/map/data/tile_cache_service.dart';
import 'package:flutter/material.dart';

class TilePrecacheService {
  static const List<int> zoomLevels = [17, 18, 19];

  static Future<void> precacheCampusTilesWithProgress(
    ValueNotifier<PrecachingStatus> notifier,
  ) async {
    final dio = Dio();
    final store = await TileCacheService.createStore();

    const zoomLevels = [17, 18, 19];
    const minLat = -17.779817462275247;
    const maxLat = -17.772873585563268;
    const minLng = -63.198970197924325;
    const maxLng = -63.19049146213652;

    final tiles = <Map<String, dynamic>>[];

    for (final z in zoomLevels) {
      final tileMin = latLngToTile(maxLat, minLng, z);
      final tileMax = latLngToTile(minLat, maxLng, z);
      for (int x = tileMin.x; x <= tileMax.x; x++) {
        for (int y = tileMin.y; y <= tileMax.y; y++) {
          tiles.add({'z': z, 'x': x, 'y': y});
        }
      }
    }

    int downloadedBytes = 0;
    int completedTiles = 0;

    notifier.value = PrecachingStatus(
      downloadedBytes: 0,
      totalTiles: tiles.length,
      completedTiles: 0,
    );

    for (final tile in tiles) {
      final z = tile['z'];
      final x = tile['x'];
      final y = tile['y'];
      final url = 'https://tile.openstreetmap.org/$z/$x/$y.png';

      try {
        final response = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = Uint8List.fromList(response.data!);
        downloadedBytes += bytes.length;

        final now = DateTime.now();
        final cacheResponse = CacheResponse(
          key: url,
          url: url,
          statusCode: 200,
          content: bytes,
          date: now,
          eTag: '',
          expires: now.add(const Duration(days: 365)),
          headers: [],
          lastModified: '',
          maxStale: now.add(const Duration(days: 365)),
          priority: CachePriority.normal,
          cacheControl: CacheControl(),
          responseDate: now,
          requestDate: now,
        );

        await store.set(cacheResponse);
      } catch (_) {
        // ignoramos errores de red
      }

      completedTiles++;
      notifier.value = PrecachingStatus(
        downloadedBytes: downloadedBytes,
        totalTiles: tiles.length,
        completedTiles: completedTiles,
      );
    }
  }

  /// Convierte coordenadas geográficas a índices de tile
  static TileCoordinates latLngToTile(double lat, double lng, int zoom) {
    final n = 1 << zoom;
    final x = ((lng + 180.0) / 360.0 * n).floor();
    final latRad = lat * pi / 180.0;
    final y = ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * n).floor();
    return TileCoordinates(x: x, y: y, zoom: zoom);
  }

  static Future<bool> isCampusTilesCached() async {
    final dir = await TileCacheService.getCacheDirectory();
    final file = File('${dir.path}/tile_cache.hive');
    return await file.exists();
  }
}

class TileCoordinates {
  final int x;
  final int y;
  final int zoom;

  TileCoordinates({required this.x, required this.y, required this.zoom});
}

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

Future<void> showPrecachingProgressDialog(
  BuildContext context,
  ValueNotifier<PrecachingStatus> notifier,
) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return ValueListenableBuilder<PrecachingStatus>(
        valueListenable: notifier,
        builder: (context, status, _) {
          if (status.completedTiles >= status.totalTiles &&
              status.totalTiles > 0) {
            Future.microtask(() {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            });
          }
          return AlertDialog(
            title: const Text('Descargando mapa'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: status.percent),
                const SizedBox(height: 12),
                Text(
                  'Descargado: ${status.downloadedMB} MB\n'
                  'Tiles: ${status.completedTiles}/${status.totalTiles}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
