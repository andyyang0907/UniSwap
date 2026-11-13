import 'package:flutter/material.dart';

/// 校园地点类型
enum CampusSpotType {
  gate,
  dorm,
  teaching,
  library,
  canteen,
  sports,
  scenic,
  service,
}

extension CampusSpotTypeExt on CampusSpotType {
  String get label => switch (this) {
        CampusSpotType.gate => '校门',
        CampusSpotType.dorm => '宿舍',
        CampusSpotType.teaching => '教学楼',
        CampusSpotType.library => '图书馆',
        CampusSpotType.canteen => '食堂',
        CampusSpotType.sports => '运动场馆',
        CampusSpotType.scenic => '景观',
        CampusSpotType.service => '校园服务',
      };

  IconData get icon => switch (this) {
        CampusSpotType.gate => Icons.door_sliding_outlined,
        CampusSpotType.dorm => Icons.bed_outlined,
        CampusSpotType.teaching => Icons.school_outlined,
        CampusSpotType.library => Icons.menu_book_outlined,
        CampusSpotType.canteen => Icons.restaurant_outlined,
        CampusSpotType.sports => Icons.sports_basketball_outlined,
        CampusSpotType.scenic => Icons.park_outlined,
        CampusSpotType.service => Icons.local_hospital_outlined,
      };
}

/// 校园内的一个地点（节点），使用真实经纬度。
class CampusSpot {
  final String id;
  final String name;
  final CampusSpotType type;
  final double lat;
  final double lng;

  const CampusSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
  });
}

/// 两个地点之间的步行路径（边），meters 为步行距离。
class CampusPathEdge {
  final String fromId;
  final String toId;
  final int meters;

  const CampusPathEdge(this.fromId, this.toId, this.meters);
}

/// 一个校区：包含真实地图底图（OpenStreetMap）与地点/路径数据。
class Campus {
  final String id;
  final String name;
  final String district;
  final String mapAsset;
  final double north;
  final double south;
  final double west;
  final double east;
  final String defaultStartSpotId;
  final List<CampusSpot> spots;
  final List<CampusPathEdge> paths;

  const Campus({
    required this.id,
    required this.name,
    required this.district,
    required this.mapAsset,
    required this.north,
    required this.south,
    required this.west,
    required this.east,
    required this.defaultStartSpotId,
    required this.spots,
    required this.paths,
  });

  CampusSpot? spotById(String id) {
    for (final s in spots) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// 经纬度转底图归一化坐标（0~1）
  double normX(double lng) => (lng - west) / (east - west);
  double normY(double lat) => (north - lat) / (north - south);

  List<CampusSpot> spotsOfType(CampusSpotType type) =>
      spots.where((s) => s.type == type).toList();
}
