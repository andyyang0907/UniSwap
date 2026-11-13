import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/data/campus_data.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late String _avatar;
  late String _campusName;

  @override
  void initState() {
    super.initState();
    final me = DataRepository.instance.me;
    _nameCtrl = TextEditingController(text: me.name);
    _bioCtrl = TextEditingController(text: me.bio);
    _avatar = me.avatar ?? '';
    _campusName = me.campus;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() => _avatar = file.path);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('昵称不能为空')),
      );
      return;
    }
    await context.read<DataRepository>().updateProfile(
          name: name,
          bio: _bioCtrl.text.trim(),
          avatar: _avatar.isEmpty ? null : _avatar,
          campus: _campusName,
        );
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('个人资料已更新')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('个人资料'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreenBg,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _avatar.isEmpty
                          ? const Icon(Icons.person_rounded, color: AppColors.secondary, size: 46)
                          : (_avatar.startsWith('http')
                              ? Image.network(_avatar, fit: BoxFit.cover)
                              : Image.file(File(_avatar), fit: BoxFit.cover)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('点击更换头像', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 28),
            _label('昵称'),
            _input(_nameCtrl, '输入你的昵称', maxLength: 16),
            const SizedBox(height: 18),
            _label('个人简介'),
            _input(_bioCtrl, '介绍一下自己，例如「爱捡漏的寝室长」', maxLines: 3, maxLength: 40),
            const SizedBox(height: 18),
            _label('所在校区'),
            const SizedBox(height: 8),
            Row(
              children: CampusData.all.map((campus) {
                final selected = _campusName == campus.name;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: campus.id == CampusData.all.last.id ? 0 : 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _campusName = campus.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '云南大学 · ${campus.name}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              campus.district,
                              style: TextStyle(
                                fontSize: 10,
                                color: selected ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('保存资料', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
    );
  }

  Widget _input(TextEditingController controller, String hint, {int maxLines = 1, int? maxLength}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }
}
