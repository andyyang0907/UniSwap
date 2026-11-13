import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/pages/campus/campus_map_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('设置'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGroup('账户设置', [
            _settingItem(
              context,
              Icons.person_outline,
              '个人资料',
              trailing: Text(repo.me.name, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              onTap: () => Navigator.of(context).pushNamed('/profile_edit'),
            ),
            _settingItem(
              context,
              Icons.school_outlined,
              '校园认证',
              trailing: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: AppColors.secondary),
                  SizedBox(width: 3),
                  Text('已认证', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                ],
              ),
              onTap: () => _showCampusVerify(context, repo.me.campus),
            ),
          ]),
          const SizedBox(height: 12),
          _buildGroup('通用', [
            _settingItem(
              context,
              Icons.notifications_outlined,
              '消息通知',
              trailing: Switch.adaptive(
                value: repo.notificationsEnabled,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => repo.setNotificationsEnabled(v),
              ),
              onTap: () => repo.setNotificationsEnabled(!repo.notificationsEnabled),
            ),
            _settingItem(
              context,
              Icons.location_on_outlined,
              '默认交付地点',
              trailing: Text(repo.defaultDeliverySpot, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              onTap: () async {
                final spot = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                    builder: (_) => CampusMapPage(
                      selectMode: true,
                      initialCampusId: repo.campusId,
                      initialSpotName: repo.defaultDeliverySpot,
                    ),
                  ),
                );
                if (spot != null && context.mounted) {
                  await repo.setDefaultDeliverySpot(spot, campusId: repo.campusId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('默认交付地点已设为「$spot」')),
                    );
                  }
                }
              },
            ),
            _settingItem(
              context,
              Icons.map_outlined,
              '校园地图与路线',
              trailing: const Text('规划最短路径', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              onTap: () => Navigator.of(context).pushNamed('/campus'),
            ),
            _settingItem(
              context,
              Icons.shield_outlined,
              '隐私与安全',
              onTap: () => _showPrivacySheet(context),
            ),
          ]),
          const SizedBox(height: 12),
          _buildGroup('关于', [
            _settingItem(
              context,
              Icons.help_outline,
              '帮助与反馈',
              onTap: () => _showHelpSheet(context),
            ),
            _settingItem(
              context,
              Icons.info_outline,
              '关于 UniSwap',
              onTap: () => _showAbout(context),
            ),
          ]),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                SvgPicture.asset(
                  'UniSwap_Design_Package/assets/uniswap_logo.svg',
                  width: 56,
                  height: 56,
                ),
                const SizedBox(height: 8),
                const Text('UniSwap v1.0', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGroup(String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _settingItem(
    BuildContext context,
    IconData icon,
    String label, {
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            if (trailing != null) trailing,
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showCampusVerify(BuildContext context, String campus) {
    _showSheet(
      context,
      title: '校园认证',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.lightGreenBg, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('云南大学 · 已认证', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('$campus · 学生身份有效期至 2028-06',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '认证信息仅用于校园范围内的闲置流转，不对外展示学号等敏感信息。',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          ),
        ],
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    _showSheet(
      context,
      title: '隐私与安全',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _privacyRow('当面交付优先', '仅向交易对方展示约定的校园公共地点'),
          const Divider(height: 24, color: AppColors.divider),
          _privacyRow('学号信息保护', '学号不公开显示，仅用于校园身份校验'),
          const Divider(height: 24, color: AppColors.divider),
          _privacyRow('聊天记录', '第一版聊天数据仅保存在本机'),
        ],
      ),
    );
  }

  Widget _privacyRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5)),
      ],
    );
  }

  void _showHelpSheet(BuildContext context) {
    _showSheet(
      context,
      title: '帮助与反馈',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('使用小贴士', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _bullet('发布闲置时，添加清晰照片更容易被同学看到'),
          _bullet('交易意向提交后，可在「我的交易」查看状态'),
          _bullet('预约交付优先选择校园公共地点，并在约定时间当面交接'),
          const SizedBox(height: 16),
          const Text('需要帮助？', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('可在「聊聊」中直接联系对方，或在校园地图中查看交付路线。',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 4, color: AppColors.secondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'UniSwap_Design_Package/assets/uniswap_logo.svg',
              width: 56,
              height: 56,
            ),
            const SizedBox(height: 12),
            const Text('UniSwap', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
            const SizedBox(height: 4),
            const Text('A smarter way to exchange on campus.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            const Text(
              '面向大学校园的闲置资源流转平台，支持二手交易、免费赠送与物品交换，主打校园当面交付。',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text('版本 1.0.0', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showSheet(BuildContext context, {required String title, required Widget child}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
