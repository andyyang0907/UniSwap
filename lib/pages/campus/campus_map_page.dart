import 'package:flutter/material.dart';
import 'package:uniswap_app/data/campus_data.dart';
import 'package:uniswap_app/models/campus.dart';
import 'package:uniswap_app/services/path_finder.dart';
import 'package:uniswap_app/theme/app_colors.dart';

/// 校园地图：真实底图（OpenStreetMap）+ 地点标注 + 最短步行路径规划。
class CampusMapPage extends StatefulWidget {
  final bool selectMode;
  final String? initialCampusId;
  final String? initialSpotName;

  const CampusMapPage({
    super.key,
    this.selectMode = false,
    this.initialCampusId,
    this.initialSpotName,
  });

  @override
  State<CampusMapPage> createState() => _CampusMapPageState();
}

class _CampusMapPageState extends State<CampusMapPage> {
  late Campus _campus;
  late String _startId;
  String? _endId;

  @override
  void initState() {
    super.initState();
    _campus = CampusData.byId(widget.initialCampusId ?? CampusData.chenggong.id);
    _startId = _campus.defaultStartSpotId;
    if (widget.initialSpotName != null) {
      for (final s in _campus.spots) {
        if (s.name == widget.initialSpotName) _endId = s.id;
      }
    }
  }

  RouteResult? get _route {
    if (_endId == null) return null;
    return PathFinder.shortestPath(_campus, _startId, _endId!);
  }

  void _selectCampus(Campus campus) {
    setState(() {
      _campus = campus;
      _startId = campus.defaultStartSpotId;
      _endId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final startSpot = _campus.spotById(_startId);
    final endSpot = _endId == null ? null : _campus.spotById(_endId!);
    final route = _route;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.selectMode ? '选择校园地点' : '校园路线规划'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCampusSelector(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildMap(route)),
                    Positioned(
                      left: 10,
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _legendPill('起点', startSpot?.name ?? '-', AppColors.primary),
                          const SizedBox(width: 8),
                          _legendPill('终点', endSpot?.name ?? '点击地图选择', AppColors.warmOrange),
                        ],
                      ),
                    ),
                    const Positioned(
                      right: 10,
                      bottom: 8,
                      child: Text(
                        '地图数据 © OpenStreetMap contributors',
                        style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomPanel(route, startSpot, endSpot),
        ],
      ),
    );
  }

  Widget _buildMap(RouteResult? route) {
    final aspect = _campus.id == CampusData.chenggong.id ? 1.5 : 4 / 3;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / aspect;
        return InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: SizedBox(
              width: width,
              height: height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final tapped = _hitTest(details.localPosition, Size(width, height));
                  if (tapped != null) setState(() => _endId = tapped.id);
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(_campus.mapAsset, fit: BoxFit.fill),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _CampusMapPainter(
                          campus: _campus,
                          startId: _startId,
                          endId: _endId,
                          route: route,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _legendPill(String tag, String name, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(tag, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampusSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          for (final campus in CampusData.all) ...[
            Expanded(
              child: GestureDetector(
                onTap: () => _selectCampus(campus),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _campus.id == campus.id ? AppColors.primary : AppColors.pageBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '云南大学 · ${campus.name}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _campus.id == campus.id ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        campus.district,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: _campus.id == campus.id ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (campus.id != CampusData.all.last.id) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomPanel(RouteResult? route, CampusSpot? startSpot, CampusSpot? endSpot) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    endSpot == null ? '点击地图上的地点，规划最短路线' : '${startSpot?.name ?? ''} → ${endSpot.name}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (endSpot != null)
                  GestureDetector(
                    onTap: () => setState(() {
                      final oldStart = _startId;
                      _startId = _endId!;
                      _endId = oldStart;
                    }),
                    child: const Row(
                      children: [
                        Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 2),
                        Text('交换起终点', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (route != null && !route.isEmpty)
              Row(
                children: [
                  _metric(Icons.straighten_rounded, '${route.totalMeters} 米'),
                  const SizedBox(width: 14),
                  _metric(Icons.directions_walk_rounded, '约 ${route.walkingMinutes} 分钟'),
                  const SizedBox(width: 14),
                  _metric(Icons.place_outlined, '${route.spots.length} 个点'),
                ],
              )
            else
              const Text(
                '底图为真实校园地图，双指可缩放；点击地点即可规划步行路线。',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            const SizedBox(height: 10),
            if (widget.selectMode)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: endSpot == null ? null : () => Navigator.of(context).pop(endSpot.name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    endSpot == null ? '请先选择地点' : '使用「${endSpot.name}」作为交付地点',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _metric(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  CampusSpot? _hitTest(Offset position, Size size) {
    const radius = 22.0;
    CampusSpot? nearest;
    var nearestDistance = double.infinity;
    for (final spot in _campus.spots) {
      final center = Offset(_campus.normX(spot.lng) * size.width, _campus.normY(spot.lat) * size.height);
      final distance = (center - position).distance;
      if (distance < radius && distance < nearestDistance) {
        nearest = spot;
        nearestDistance = distance;
      }
    }
    return nearest;
  }
}

class _CampusMapPainter extends CustomPainter {
  final Campus campus;
  final String startId;
  final String? endId;
  final RouteResult? route;

  _CampusMapPainter({
    required this.campus,
    required this.startId,
    required this.endId,
    required this.route,
  });

  Offset _point(CampusSpot spot, Size size) {
    return Offset(campus.normX(spot.lng) * size.width, campus.normY(spot.lat) * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 路径连线
    final edgePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    for (final edge in campus.paths) {
      final from = campus.spotById(edge.fromId);
      final to = campus.spotById(edge.toId);
      if (from == null || to == null) continue;
      canvas.drawLine(_point(from, size), _point(to, size), edgePaint);
    }

    // 最短路径高亮
    if (route != null && route!.spots.length >= 2) {
      final shadowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final routePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (var i = 0; i < route!.spots.length; i++) {
        final offset = _point(route!.spots[i], size);
        if (i == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      canvas.drawPath(path, shadowPaint);
      canvas.drawPath(path, routePaint);
    }

    // 地点节点
    for (final spot in campus.spots) {
      final center = _point(spot, size);
      final isStart = spot.id == startId;
      final isEnd = spot.id == endId;
      final highlighted = isStart || isEnd;

      canvas.drawCircle(
        center,
        highlighted ? 8 : 5.5,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        center,
        highlighted ? 6 : 4,
        Paint()..color = isStart ? AppColors.primary : isEnd ? AppColors.warmOrange : AppColors.secondary,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: spot.name,
          style: TextStyle(
            fontSize: highlighted ? 10 : 9,
            color: highlighted ? AppColors.primary : AppColors.textPrimary,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            shadows: const [
              Shadow(color: Colors.white, blurRadius: 3),
              Shadow(color: Colors.white, blurRadius: 3),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          (center.dx - textPainter.width / 2).clamp(2.0, size.width - textPainter.width - 2),
          center.dy + 9,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CampusMapPainter oldDelegate) {
    return oldDelegate.startId != startId ||
        oldDelegate.endId != endId ||
        oldDelegate.campus.id != campus.id ||
        oldDelegate.route != route;
  }
}
