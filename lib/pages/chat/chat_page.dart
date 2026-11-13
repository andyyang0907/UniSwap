import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uniswap_app/services/data_repository.dart';
import 'package:uniswap_app/theme/app_colors.dart';
import 'package:uniswap_app/widgets/empty_state.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  const ChatPage({super.key, required this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // 进入聊天页后标记为已读
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataRepository>().markSessionAsRead(widget.sessionId);
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<DataRepository>();
    final session = repo.sessionById(widget.sessionId);

    if (session == null) {
      return const Scaffold(body: EmptyState(icon: Icons.chat_bubble_outline, title: '会话不存在', subtitle: ''));
    }

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: AppColors.lightGreenBg, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 18),
            ),
            const SizedBox(width: 8),
            Text(session.peerName),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: session.messages.length,
              itemBuilder: (_, i) {
                final msg = session.messages[i];
                return _MessageBubble(message: msg);
              },
            ),
          ),
          _buildInputBar(context, repo),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, DataRepository repo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 38, maxHeight: 120),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _inputCtrl,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: 14, height: 1.35),
                  decoration: const InputDecoration(
                    hintText: '输入消息…',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(38, 38),
                ),
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<DataRepository>().sendMessage(widget.sessionId, text);
    _inputCtrl.clear();
    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: AppColors.lightGreenBg, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isMine ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: AppColors.lightGreenBg, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: AppColors.secondary, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
