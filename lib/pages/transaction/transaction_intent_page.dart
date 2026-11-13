import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/models/product.dart';
import 'package:uniswap_app/models/transaction.dart';

class TransactionIntentPageArgs {
  final String productId;
  const TransactionIntentPageArgs({required this.productId});
}

class TransactionIntentPage extends StatefulWidget {
  final String productId;
  const TransactionIntentPage({super.key, required this.productId});

  @override
  State<TransactionIntentPage> createState() => _TransactionIntentPageState();
}

class _TransactionIntentPageState extends State<TransactionIntentPage> {
  final _messageCtrl = TextEditingController();
  final _swapOfferCtrl = TextEditingController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _swapOfferCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<DataRepository>();
    final product = repo.productById(widget.productId);
    if (product == null) {
      return const SizedBox.shrink();
    }

    final title = product.tradeType == TradeType.sell
        ? '表达购买意向'
        : product.tradeType == TradeType.give
            ? '申请领取'
            : '提出交换';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Product mini card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pageBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(product.imageUrls.first, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.priceDisplay, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: product.tradeType == TradeType.sell ? AppColors.primary : AppColors.warmOrange)),
                            const SizedBox(height: 2),
                            Text(product.title, maxLines: 1, style: const TextStyle(fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('卖家 ${product.sellerName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('给卖家留个言', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextField(
                  controller: _messageCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: product.tradeType == TradeType.sell ? '比如：你好，这个物品还在吗？我很有兴趣' : product.tradeType == TradeType.give ? '比如：你好，非常感谢！我很需要' : '比如：你好，我有一个羽毛球拍想换',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.pageBg,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (product.tradeType == TradeType.swap) ...[
                  const SizedBox(height: 20),
                  const Text('你想用来交换的物品', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _swapOfferCtrl,
                    decoration: InputDecoration(
                      hintText: '比如：我有一支 Yonex 羽毛球拍',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.pageBg,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    final intent = TransactionIntent(
                      productId: product.id,
                      productTitle: product.title,
                      productImage: product.imageUrls.first,
                      fromUserId: repo.me.id,
                      fromUserName: repo.me.name,
                      toUserId: product.sellerId,
                      toUserName: product.sellerName,
                      message: _messageCtrl.text.trim(),
                      swapOffer: _swapOfferCtrl.text.trim().isEmpty ? null : _swapOfferCtrl.text.trim(),
                    );
                    repo.createIntent(intent);
                    Navigator.of(context).pop(); // dismiss sheet
                    _openAppointment(context, intent);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('提交意向', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAppointment(BuildContext context, TransactionIntent intent) {
    final args = TransactionIntentPageArgs(productId: intent.id);
    Navigator.of(context).pushNamed('/appointment', arguments: args);
  }
}
