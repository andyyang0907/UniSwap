import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/data/campus_data.dart';
import 'package:uniswap_app/models/campus.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/pages/transaction/transaction_intent_page.dart';
import 'package:uniswap_app/pages/campus/campus_map_page.dart';

class AppointmentPage extends StatefulWidget {
  final TransactionIntentPageArgs? args;
  const AppointmentPage({super.key, this.args});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage>
    with SingleTickerProviderStateMixin {
  String? _selectedLocation;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  bool _submitted = false;
  late AnimationController _anim;
  late Animation<double> _checkScale;

  final List<String> _timeSlots = [
    '10:00 - 10:30',
    '14:00 - 14:30',
    '15:00 - 15:30',
    '16:00 - 16:30',
    '18:00 - 18:30',
    '19:00 - 19:30',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = DataRepository.instance.defaultDeliverySpot;
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _checkScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _anim, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedLocation == null || _selectedTimeSlot == null) return;
    setState(() => _submitted = true);
    _anim.forward();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selectedLocation != null && _selectedTimeSlot != null && !_submitted;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(_submitted ? '预约成功' : '选择交付时间'),
        centerTitle: true,
      ),
      body: _submitted ? _buildSuccess() : _buildForm(canSubmit),
      bottomNavigationBar: _submitted
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _submitted = false;
                          });
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.divider),
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('返回'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('继续浏览'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: ElevatedButton(
                  onPressed: canSubmit ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit ? AppColors.primary : AppColors.divider,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: AppColors.textSecondary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('确认预约', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
    );
  }

  Widget _buildForm(bool canSubmit) {
    final repo = context.watch<DataRepository>();
    final campus = CampusData.byId(repo.campusId);
    final quickSpots = campus.spots
        .where((s) => s.type == CampusSpotType.gate || s.type == CampusSpotType.dorm || s.type == CampusSpotType.canteen)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          children: [
            _sectionTitle('选择校园交付地点'),
            const Spacer(),
            Text('${campus.name} · ${campus.district}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final spot = await Navigator.of(context).push<String>(
              MaterialPageRoute(
                builder: (_) => CampusMapPage(
                  selectMode: true,
                  initialCampusId: campus.id,
                  initialSpotName: _selectedLocation,
                ),
              ),
            );
            if (spot != null && mounted) {
              setState(() => _selectedLocation = spot);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation ?? '在地图上选点',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      const Text('打开校园地图，查看最短交付路线',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickSpots.map((spot) {
            final selected = _selectedLocation == spot.name;
            return GestureDetector(
              onTap: () => setState(() => _selectedLocation = spot.name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(spot.type.icon, size: 13, color: selected ? Colors.white : AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      spot.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        _sectionTitle('选择日期'),
        const SizedBox(height: 12),
        _buildDatePicker(),
        const SizedBox(height: 24),
        _sectionTitle('选择时间段'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((slot) {
            final selected = _selectedTimeSlot == slot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: days.map((d) {
          final selected = _selectedDate.year == d.year && _selectedDate.month == d.month && _selectedDate.day == d.day;
          final weekday = ['日', '一', '二', '三', '四', '五', '六'][d.weekday % 7];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDate = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '周$weekday',
                      style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.month}/${d.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      );

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _checkScale,
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
            ),
          ),
          const SizedBox(height: 24),
          const Text('预约成功！', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('${_selectedLocation} · ${_timeLabel(_selectedDate)} ${_selectedTimeSlot ?? ''}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  String _timeLabel(DateTime d) {
    return '${d.month}月${d.day}日';
  }
}
