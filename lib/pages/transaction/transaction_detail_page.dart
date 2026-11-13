import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/models/transaction.dart';
import 'package:uniswap_app/widgets/app_buttons.dart';
import 'package:uniswap_app/widgets/app_image.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final tx = repo.myTransactions.firstWhere(
      (t) => t.id == transactionId,
      orElse: () => TransactionIntent(
        productId: '',
        productTitle: '',
        productImage: '',
        fromUserId: '',
        fromUserName: '',
        toUserId: '',
        toUserName: '',
        message: '',
      ),
    );

    if (tx.productId.isEmpty) {
      return const Scaffold(body: Center(child: Text('交易不存在')));
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('交易详情'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildStatusBanner(tx),
          const SizedBox(height: 20),
          _buildTransactionCard(tx),
          const SizedBox(height: 20),
          _buildActionCard(tx, context),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(TransactionIntent tx) {
    final color = tx.status == TransactionStatus.completed
        ? AppColors.secondary
        : tx.status == TransactionStatus.cancelled
            ? AppColors.error
            : AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              tx.status == TransactionStatus.completed
                  ? Icons.check_rounded
                  : tx.status == TransactionStatus.cancelled
                      ? Icons.close_rounded
                      : Icons.schedule_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.statusLabel, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 2),
                Text(
                  _statusSub(tx),
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusSub(TransactionIntent tx) {
    switch (tx.status) {
      case TransactionStatus.pendingResponse:
        return '对方正在查看你的意向';
      case TransactionStatus.pendingAppointment:
        return '等待对方确认预约时间';
      case TransactionStatus.appointed:
        return '预约已确认，请准时到达';
      case TransactionStatus.inProgress:
        return '交易进行中，保持沟通';
      case TransactionStatus.completed:
        return '恭喜交易成功！';
      case TransactionStatus.cancelled:
        return '交易已取消';
    }
  }

  Widget _buildTransactionCard(TransactionIntent tx) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(image: appImageProvider(tx.productImage), height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(tx.productTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('与 ${tx.toUserName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          if (tx.appointment != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreenBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(children: [const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18), const SizedBox(width: 6), Expanded(child: Text(tx.appointment!.location, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18), const SizedBox(width: 6), Expanded(child: Text('${tx.appointment!.date.month}月${tx.appointment!.date.day}日 ${tx.appointment!.timeSlot}', style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)))]),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('我的留言', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Expanded(child: Text(tx.message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(TransactionIntent tx, BuildContext context) {
    return Column(
      children: [
        PrimaryButton(text: '联系对方', icon: const Icon(Icons.chat_bubble_outline, size: 20), onPressed: () {}),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.divider),
                  foregroundColor: AppColors.textPrimary,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('修改预约'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final repo = context.read<DataRepository>();
                  final updated = tx.copyWith(status: TransactionStatus.cancelled);
                  repo.updateTransaction(tx.id, updated);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已取消交易')));
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  foregroundColor: AppColors.error,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('取消交易'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
