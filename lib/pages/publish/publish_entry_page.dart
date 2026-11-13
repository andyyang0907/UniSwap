import 'package:flutter/material.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/models/product.dart';
import 'package:uniswap_app/widgets/stepper_bar.dart';
import 'package:uniswap_app/widgets/app_buttons.dart';
import 'package:uniswap_app/widgets/app_image.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PublishEntryPage extends StatefulWidget {
  const PublishEntryPage({super.key});

  @override
  State<PublishEntryPage> createState() => _PublishEntryPageState();
}

class _PublishEntryPageState extends State<PublishEntryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('发布物品'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            const _TradeTypeSelector(),
            const SizedBox(height: 24),
            _quickTips(),
          ],
        ),
      ),
    );
  }

  Widget _quickTips() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGreenBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 发布小贴士',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          SizedBox(height: 10),
          Text(
            '• 真实描述物品状态，避免事后纠纷\n'
            '• 照片拍清楚物品细节和成色\n'
            '• 价格合理参考市场价\n'
            '• 校园当面交付，更安全',
            style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.7),
          ),
        ],
      ),
    );
  }
}

// ============ Trade Type Selector (full flow) ============
class _TradeTypeSelector extends StatefulWidget {
  const _TradeTypeSelector();

  @override
  State<_TradeTypeSelector> createState() => _TradeTypeSelectorState();
}

class _TradeTypeSelectorState extends State<_TradeTypeSelector> {
  TradeType? _selected;

  final _options = [
    _TradeOption(TradeType.sell, '二手出售', Icons.shopping_bag_outlined, AppColors.primary, '给闲置物品找个好买家'),
    _TradeOption(TradeType.give, '免费赠送', Icons.card_giftcard_outlined, AppColors.secondary, '把还能用的东西送给有需要的人'),
    _TradeOption(TradeType.swap, '物品交换', Icons.swap_horiz_rounded, AppColors.warmOrange, '以物换物，各取所需'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '选择发布类型',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        const Text(
          '我们会根据类型展示不同字段',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        for (final opt in _options) ...[
          _buildOption(opt),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
        PrimaryButton(
          text: '下一步',
          disabled: _selected == null,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PublishFlowPage(tradeType: _selected!),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOption(_TradeOption opt) {
    final selected = _selected == opt.type;
    return GestureDetector(
      onTap: () => setState(() => _selected = opt.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? opt.color : AppColors.divider,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: opt.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(opt.icon, color: opt.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opt.label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(opt.desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selected
                  ? Icon(Icons.check_circle_rounded, color: opt.color, size: 26, key: const ValueKey('checked'))
                  : Icon(Icons.radio_button_unchecked, color: AppColors.divider, size: 26, key: const ValueKey('unchecked')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TradeOption {
  final TradeType type;
  final String label;
  final IconData icon;
  final Color color;
  final String desc;
  _TradeOption(this.type, this.label, this.icon, this.color, this.desc);
}

// ============ Publish Flow Page ============
class PublishFlowPage extends StatefulWidget {
  final TradeType tradeType;
  const PublishFlowPage({super.key, required this.tradeType});

  @override
  State<PublishFlowPage> createState() => _PublishFlowPageState();
}

class _PublishFlowPageState extends State<PublishFlowPage> {
  int _step = 0;
  final List<XFile> _images = [];
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _swapWishCtrl = TextEditingController();
  String _category = '数码';
  ProductCondition _condition = ProductCondition.good;
  final String _deliveryNote = '校园公共地点当面交付';

  final List<String> _stepLabels = ['图片', '信息', '补充', '预览'];
  final List<String> _categories = ['数码', '教材', '生活用品', '运动', '其他'];

  @override
  void initState() {
    super.initState();
    // 输入内容变化时刷新「下一步」可用状态
    _titleCtrl.addListener(_onFormChanged);
    _descCtrl.addListener(_onFormChanged);
    _priceCtrl.addListener(_onFormChanged);
    _swapWishCtrl.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFormChanged);
    _descCtrl.removeListener(_onFormChanged);
    _priceCtrl.removeListener(_onFormChanged);
    _swapWishCtrl.removeListener(_onFormChanged);
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _swapWishCtrl.dispose();
    super.dispose();
  }

  bool get _canNext {
    switch (_step) {
      case 0:
        return _images.isNotEmpty;
      case 1:
        return _titleCtrl.text.trim().isNotEmpty &&
            _descCtrl.text.trim().isNotEmpty &&
            _category.isNotEmpty;
      case 2:
        if (widget.tradeType == TradeType.sell) {
          final p = double.tryParse(_priceCtrl.text.trim());
          return p != null && p > 0;
        }
        if (widget.tradeType == TradeType.swap) {
          return _swapWishCtrl.text.trim().isNotEmpty;
        }
        return true;
      default:
        return true;
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    setState(() => _images.addAll(picked));
  }

  Product _buildProduct() {
    // For demo, use a placeholder image URL if no images picked
    final imageSources = _images.isNotEmpty
        ? _images.map((f) => f.path).toList()
        : ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&h=750&fit=crop'];

    return Product(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      tradeType: widget.tradeType,
      category: _category,
      condition: _condition,
      imageUrls: imageSources,
      price: widget.tradeType == TradeType.sell
          ? double.tryParse(_priceCtrl.text.trim())
          : null,
      swapWish: widget.tradeType == TradeType.swap
          ? _swapWishCtrl.text.trim()
          : null,
      sellerId: 'me_demo',
      sellerName: context.read<DataRepository>().me.name,
      sellerCampus: context.read<DataRepository>().me.campus,
      deliveryNote: _deliveryNote,
    );
  }

  void _publish() {
    final product = _buildProduct();
    context.read<DataRepository>().addProduct(product);
    // 用 maybePop 安全 pop —— 防止 PublishEntryPage 是 IndexedStack tab 导致无法 pop
    // 同时重置 state 以便下次进入
    setState(() {
      _step = 0;
      _images.clear();
      _titleCtrl.clear();
      _descCtrl.clear();
      _priceCtrl.clear();
      _swapWishCtrl.clear();
      _category = '数码';
      _condition = ProductCondition.good;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 发布成功！可在「我的发布」中查看'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('发布 · ${widget.tradeType == TradeType.sell ? '出售' : widget.tradeType == TradeType.give ? '赠送' : '交换'}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: StepperBarWithLabels(labels: _stepLabels, current: _step),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _buildStepContent(),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildStepImages();
      case 1:
        return _buildStepBasicInfo();
      case 2:
        return _buildStepExtra();
      case 3:
        return _buildStepPreview();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepImages() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('添加物品图片', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('最多 9 张，第一张会作为封面', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.92,
            children: [
              ..._images.asMap().entries.map((entry) {
                final idx = entry.key;
                final file = entry.value;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(file.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    if (idx == 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('封面', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(idx)),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (_images.length < 9)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.secondary, size: 30),
                        SizedBox(height: 6),
                        Text('添加', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepBasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('基本信息', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _fieldLabel('物品标题'),
          _textField(_titleCtrl, '简洁描述物品，例如「Sony WH-1000XM4 耳机」', maxLength: 30),
          const SizedBox(height: 16),
          _fieldLabel('分类'),
          _wrapOptions<String>(_categories, _category, (v) => setState(() => _category = v)),
          const SizedBox(height: 16),
          _fieldLabel('物品状态'),
          _wrapOptions<ProductCondition>(
            ProductCondition.values,
            _condition,
            (v) => setState(() => _condition = v),
            label: (c) => c == ProductCondition.newLike ? '九成新' : c == ProductCondition.good ? '良好' : c == ProductCondition.fair ? '一般' : '较旧',
          ),
          const SizedBox(height: 16),
          _fieldLabel('描述'),
          Container(
            constraints: const BoxConstraints(minHeight: 120),
            child: TextField(
              controller: _descCtrl,
              maxLines: null,
              minLines: 4,
              maxLength: 300,
              decoration: _inputDecoration('描述物品成色、购买时间、使用情况等'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepExtra() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.tradeType == TradeType.sell ? '价格信息' : widget.tradeType == TradeType.give ? '赠送说明' : '交换说明',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          if (widget.tradeType == TradeType.sell) ...[
            _fieldLabel('售价 (¥)'),
            _numberField(_priceCtrl, '输入价格，例如 199'),
          ],
          if (widget.tradeType == TradeType.give) ...[
            _fieldLabel('简短说明'),
            _textField(_descCtrl, '比如「毕业清理，免费送」'),
          ],
          if (widget.tradeType == TradeType.swap) ...[
            _fieldLabel('期望交换的物品'),
            _textField(_swapWishCtrl, '想换什么？例如「想换一把入门级网球拍」'),
          ],
          const SizedBox(height: 20),
          _fieldLabel('交付方式'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('校园当面交付', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text('推荐地点：图书馆、食堂门口、宿舍楼下', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPreviewImage(String url, {double? height}) {
    return Image(image: appImageProvider(url), height: height, width: double.infinity, fit: BoxFit.cover);
  }

  Widget _buildStepPreview() {
    final product = _buildProduct();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('预览', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: _buildPreviewImage(product.imageUrls.first, height: 220),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.priceDisplay, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: product.tradeType == TradeType.sell ? AppColors.primary : product.tradeType == TradeType.give ? AppColors.secondary : AppColors.warmOrange)),
                      const SizedBox(height: 6),
                      Text(product.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('${product.category} · ${product.conditionLabel}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Text(product.description, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.6)),
                      const SizedBox(height: 12),
                      if (product.swapWish != null) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.warmOrange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz_rounded, color: AppColors.warmOrange, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text('想换：${product.swapWish!}', style: const TextStyle(fontSize: 12, color: AppColors.warmOrange))),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_step > 0)
              Expanded(
                child: SecondaryButton(
                  text: '上一步',
                  onPressed: () => setState(() => _step--),
                ),
              ),
            if (_step > 0) const SizedBox(width: 12),
            Expanded(
              flex: _step > 0 ? 2 : 1,
              child: PrimaryButton(
                text: _step == 3 ? '立即发布' : '下一步',
                disabled: !_canNext,
                onPressed: () {
                  if (_step == 3) {
                    _publish();
                  } else {
                    setState(() => _step++);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ helpers ============
  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );

  Widget _textField(TextEditingController ctrl, String hint, {int? maxLength}) {
    return TextField(
      controller: ctrl,
      maxLength: maxLength,
      decoration: _inputDecoration(hint),
    );
  }

  Widget _numberField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(hint, prefixText: '¥'),
    );
  }

  InputDecoration _inputDecoration(String hint, {String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      prefixText: prefixText,
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _wrapOptions<T>(List<T> items, T selected, void Function(T) onTap, {String Function(T)? label}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = item == selected;
        return GestureDetector(
          onTap: () => onTap(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
            ),
            child: Text(
              label != null ? label(item) : item.toString().split('.').last,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
