import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/empty_state.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final sessions = repo.sessions;

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('消息'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
        ],
      ),
      body: sessions.isEmpty
          ? const EmptyState(icon: Icons.chat_bubble_outline, title: '暂无消息', subtitle: '发布或感兴趣的物品会出现在这里')
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sessions.length,
              itemBuilder: (context, i) {
                final session = sessions[i];
                return _SessionTile(
                  session: session,
                  onTap: () => Navigator.of(context).pushNamed('/chat', arguments: session.id),
                );
              },
            ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final dynamic session;
  final VoidCallback onTap;
  const _SessionTile({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.lightGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.peerName,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        _timeAgo(session.lastMessageAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                        ),
                      ),
                      if (session.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            session.unreadCount > 9 ? '9+' : session.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分前';
    if (diff.inHours < 24) return '${diff.inHours}时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${diff.inDays ~/ 7}周前';
  }
}
