import 'package:uniswap_app/models/campus.dart';

/// 云南大学校园数据。
/// 底图为 OpenStreetMap 真实地图瓦片拼接，地点使用真实经纬度。
/// 建筑位置为校园内近似标注，交付前双方仍以实际碰面为准。
class CampusData {
  static const String mapAttribution = '地图数据 © OpenStreetMap contributors';

  static const Campus chenggong = Campus(
    id: 'ynu_chenggong',
    name: '呈贡校区',
    district: '昆明市呈贡区大学城东外环南路',
    mapAsset: 'assets/images/campus_chenggong_map.png',
    north: 24.836596,
    south: 24.816654,
    west: 102.832031,
    east: 102.864990,
    defaultStartSpotId: 'cg_ziyuan',
    spots: [
      CampusSpot(id: 'cg_north_gate', name: '北门', type: CampusSpotType.gate, lat: 24.8353, lng: 102.8470),
      CampusSpot(id: 'cg_east_gate', name: '东门', type: CampusSpotType.gate, lat: 24.83134, lng: 102.85888),
      CampusSpot(id: 'cg_south_gate', name: '南门', type: CampusSpotType.gate, lat: 24.8225, lng: 102.8475),
      CampusSpot(id: 'cg_west_gate', name: '西门', type: CampusSpotType.gate, lat: 24.8285, lng: 102.8390),
      CampusSpot(id: 'cg_mingyuan', name: '明远楼', type: CampusSpotType.teaching, lat: 24.8248, lng: 102.8462),
      CampusSpot(id: 'cg_library', name: '图书馆', type: CampusSpotType.library, lat: 24.8300, lng: 102.8470),
      CampusSpot(id: 'cg_zhonglou', name: '钟楼', type: CampusSpotType.scenic, lat: 24.8298, lng: 102.8505),
      CampusSpot(id: 'cg_zelake', name: '泽湖', type: CampusSpotType.scenic, lat: 24.8308, lng: 102.8530),
      CampusSpot(id: 'cg_stadium', name: '秀升体育场', type: CampusSpotType.sports, lat: 24.8270, lng: 102.8415),
      CampusSpot(id: 'cg_ziyuan', name: '梓苑宿舍区', type: CampusSpotType.dorm, lat: 24.8342, lng: 102.8412),
      CampusSpot(id: 'cg_nanyuan', name: '楠苑宿舍区', type: CampusSpotType.dorm, lat: 24.8346, lng: 102.8462),
      CampusSpot(id: 'cg_qiuyuan', name: '楸苑宿舍区', type: CampusSpotType.dorm, lat: 24.8318, lng: 102.8576),
      CampusSpot(id: 'cg_huayuan', name: '桦苑宿舍区', type: CampusSpotType.dorm, lat: 24.8336, lng: 102.8552),
      CampusSpot(id: 'cg_zhiwei', name: '知味堂', type: CampusSpotType.canteen, lat: 24.8322, lng: 102.8438),
      CampusSpot(id: 'cg_yuwei', name: '馀味堂', type: CampusSpotType.canteen, lat: 24.8328, lng: 102.8528),
      CampusSpot(id: 'cg_pinwei', name: '品味堂', type: CampusSpotType.canteen, lat: 24.8260, lng: 102.8400),
      CampusSpot(id: 'cg_hospital', name: '校医院', type: CampusSpotType.service, lat: 24.8252, lng: 102.8428),
    ],
    paths: [
      CampusPathEdge('cg_north_gate', 'cg_nanyuan', 220),
      CampusPathEdge('cg_north_gate', 'cg_huayuan', 200),
      CampusPathEdge('cg_ziyuan', 'cg_nanyuan', 180),
      CampusPathEdge('cg_ziyuan', 'cg_zhiwei', 120),
      CampusPathEdge('cg_zhiwei', 'cg_west_gate', 260),
      CampusPathEdge('cg_zhiwei', 'cg_library', 300),
      CampusPathEdge('cg_library', 'cg_zhonglou', 220),
      CampusPathEdge('cg_library', 'cg_mingyuan', 320),
      CampusPathEdge('cg_library', 'cg_huayuan', 300),
      CampusPathEdge('cg_zhonglou', 'cg_zelake', 180),
      CampusPathEdge('cg_zelake', 'cg_qiuyuan', 260),
      CampusPathEdge('cg_qiuyuan', 'cg_east_gate', 220),
      CampusPathEdge('cg_east_gate', 'cg_yuwei', 180),
      CampusPathEdge('cg_yuwei', 'cg_huayuan', 200),
      CampusPathEdge('cg_yuwei', 'cg_zhonglou', 320),
      CampusPathEdge('cg_mingyuan', 'cg_south_gate', 260),
      CampusPathEdge('cg_mingyuan', 'cg_stadium', 300),
      CampusPathEdge('cg_stadium', 'cg_pinwei', 280),
      CampusPathEdge('cg_pinwei', 'cg_west_gate', 260),
      CampusPathEdge('cg_pinwei', 'cg_south_gate', 400),
      CampusPathEdge('cg_south_gate', 'cg_hospital', 260),
      CampusPathEdge('cg_hospital', 'cg_stadium', 320),
      CampusPathEdge('cg_mingyuan', 'cg_pinwei', 400),
    ],
  );

  static const Campus donglu = Campus(
    id: 'ynu_donglu',
    name: '东陆校区',
    district: '昆明市五华区翠湖北路2号',
    mapAsset: 'assets/images/campus_donglu_map.png',
    north: 25.060721,
    south: 25.053257,
    west: 102.694702,
    east: 102.705688,
    defaultStartSpotId: 'dl_dorm_e2',
    spots: [
      CampusSpot(id: 'dl_main_gate', name: '正门', type: CampusSpotType.gate, lat: 25.0549, lng: 102.7002),
      CampusSpot(id: 'dl_north_gate', name: '北门', type: CampusSpotType.gate, lat: 25.0596, lng: 102.7004),
      CampusSpot(id: 'dl_huize', name: '会泽院', type: CampusSpotType.teaching, lat: 25.0562, lng: 102.7000),
      CampusSpot(id: 'dl_zhigong', name: '至公堂', type: CampusSpotType.teaching, lat: 25.0570, lng: 102.6995),
      CampusSpot(id: 'dl_zeqing', name: '泽清堂', type: CampusSpotType.teaching, lat: 25.0570, lng: 102.7006),
      CampusSpot(id: 'dl_yingqiu', name: '映秋院', type: CampusSpotType.teaching, lat: 25.0567, lng: 102.7012),
      CampusSpot(id: 'dl_library', name: '图书馆', type: CampusSpotType.library, lat: 25.0582, lng: 102.6992),
      CampusSpot(id: 'dl_ginkgo', name: '银杏道', type: CampusSpotType.scenic, lat: 25.0556, lng: 102.7001),
      CampusSpot(id: 'dl_dorm_e2', name: '东二院', type: CampusSpotType.dorm, lat: 25.0554, lng: 102.7026),
      CampusSpot(id: 'dl_dorm_north', name: '北院', type: CampusSpotType.dorm, lat: 25.0590, lng: 102.7012),
      CampusSpot(id: 'dl_canteen', name: '北院餐厅', type: CampusSpotType.canteen, lat: 25.0587, lng: 102.7008),
      CampusSpot(id: 'dl_dingxin', name: '鼎鑫公寓', type: CampusSpotType.dorm, lat: 25.0551, lng: 102.7018),
      CampusSpot(id: 'dl_gym', name: '体育馆', type: CampusSpotType.sports, lat: 25.0580, lng: 102.7025),
    ],
    paths: [
      CampusPathEdge('dl_main_gate', 'dl_ginkgo', 120),
      CampusPathEdge('dl_ginkgo', 'dl_huize', 150),
      CampusPathEdge('dl_huize', 'dl_zhigong', 100),
      CampusPathEdge('dl_huize', 'dl_zeqing', 110),
      CampusPathEdge('dl_huize', 'dl_yingqiu', 130),
      CampusPathEdge('dl_zhigong', 'dl_library', 160),
      CampusPathEdge('dl_library', 'dl_canteen', 220),
      CampusPathEdge('dl_canteen', 'dl_north_gate', 180),
      CampusPathEdge('dl_canteen', 'dl_dorm_north', 80),
      CampusPathEdge('dl_yingqiu', 'dl_dorm_e2', 180),
      CampusPathEdge('dl_dorm_e2', 'dl_dingxin', 90),
      CampusPathEdge('dl_ginkgo', 'dl_dorm_e2', 200),
      CampusPathEdge('dl_yingqiu', 'dl_gym', 160),
      CampusPathEdge('dl_gym', 'dl_dorm_north', 220),
    ],
  );

  static const List<Campus> all = [chenggong, donglu];

  static Campus byId(String id) {
    for (final c in all) {
      if (c.id == id) return c;
    }
    return chenggong;
  }
}
