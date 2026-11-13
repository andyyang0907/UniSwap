import 'package:uniswap_app/models/campus.dart';

/// 最短路径结果
class RouteResult {
  final List<CampusSpot> spots;
  final int totalMeters;

  const RouteResult({required this.spots, required this.totalMeters});

  bool get isEmpty => spots.length < 2;

  /// 以常规步行速度 80 米/分钟估算
  int get walkingMinutes => (totalMeters / 80).ceil();
}

/// 校园最短路径规划（Dijkstra）
class PathFinder {
  static RouteResult shortestPath(Campus campus, String fromId, String toId) {
    if (fromId == toId) {
      final spot = campus.spotById(fromId);
      return RouteResult(spots: spot == null ? [] : [spot], totalMeters: 0);
    }

    // 邻接表
    final adjacency = <String, List<MapEntry<String, int>>>{};
    for (final edge in campus.paths) {
      adjacency.putIfAbsent(edge.fromId, () => []).add(MapEntry(edge.toId, edge.meters));
      adjacency.putIfAbsent(edge.toId, () => []).add(MapEntry(edge.fromId, edge.meters));
    }

    final dist = <String, int>{};
    final prev = <String, String>{};
    for (final spot in campus.spots) {
      dist[spot.id] = 1 << 30;
    }
    dist[fromId] = 0;

    // 简易优先队列
    final visited = <String>{};
    while (true) {
      String? current;
      var best = 1 << 30;
      for (final entry in dist.entries) {
        if (!visited.contains(entry.key) && entry.value < best) {
          best = entry.value;
          current = entry.key;
        }
      }
      if (current == null) break;
      if (current == toId) break;
      visited.add(current);

      for (final neighbor in adjacency[current] ?? const <MapEntry<String, int>>[]) {
        final candidate = dist[current]! + neighbor.value;
        if (candidate < (dist[neighbor.key] ?? (1 << 30))) {
          dist[neighbor.key] = candidate;
          prev[neighbor.key] = current;
        }
      }
    }

    if (!dist.containsKey(toId) || dist[toId] == (1 << 30)) {
      return const RouteResult(spots: [], totalMeters: 0);
    }

    // 回溯路径
    final ids = <String>[];
    String? cursor = toId;
    while (cursor != null) {
      ids.insert(0, cursor);
      if (cursor == fromId) break;
      cursor = prev[cursor];
    }

    final spots = <CampusSpot>[];
    for (final id in ids) {
      final spot = campus.spotById(id);
      if (spot != null) spots.add(spot);
    }
    return RouteResult(spots: spots, totalMeters: dist[toId]!);
  }
}
