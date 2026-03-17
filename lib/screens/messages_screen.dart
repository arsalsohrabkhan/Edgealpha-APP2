import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/client_model.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool  _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String docId) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      final fs = context.read<FirestoreService>();
      await fs.sendMessage(clientDocId: docId, from: 'client', text: text);
      _ctrl.clear();
      await Future.delayed(const Duration(milliseconds: 200));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Send failed: $e',
                style: AETheme.syne(size: 12, color: Colors.white)),
            backgroundColor: AETheme.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();
    final client = auth.client;
    if (client == null) return const SizedBox();

    final docId = client.docId;
    final fs    = context.read<FirestoreService>();

    return ClientScaffold(
      active:   'messages',
      title:    'Messages',
      subtitle: 'Private advisor channel',
      body: StreamBuilder<Client?>(
        stream: fs.streamClient(docId),
        builder: (context, snap) {
          final C        = snap.data ?? client;
          final messages = C.messages;

          // Auto-scroll on new messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scroll.hasClients && _scroll.position.maxScrollExtent > 0) {
              _scroll.jumpTo(_scroll.position.maxScrollExtent);
            }
          });

          return Column(
            children: [
              // Header info bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: const BoxDecoration(
                  color: AETheme.white,
                  border: Border(bottom: BorderSide(color: Color(0x0A070921))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(color: AETheme.green2, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('${messages.length} messages in thread', style: AETheme.syne(size: 11, color: AETheme.muted)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0x14047857), borderRadius: BorderRadius.circular(20)),
                      child: Text('AlphaEdge Advisor', style: AETheme.syne(size: 9, color: AETheme.green, weight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),

              // Messages list
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💬', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 12),
                            Text('No messages yet', style: AETheme.syne(size: 14, color: AETheme.muted)),
                            const SizedBox(height: 4),
                            Text('Send a message to your advisor', style: AETheme.syne(size: 12, color: AETheme.faint, weight: FontWeight.w400)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _MessageBubble(msg: messages[i], clientColor: Color(C.colorValue), clientInitials: C.initials),
                      ),
              ),

              // Input area
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                decoration: const BoxDecoration(
                  color: AETheme.white,
                  border: Border(top: BorderSide(color: Color(0x10070921))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AETheme.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0x12070921)),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          style: AETheme.syne(size: 13),
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(docId),
                          decoration: InputDecoration(
                            hintText: 'Type a message to your advisor…',
                            hintStyle: AETheme.syne(size: 13, color: AETheme.faint, weight: FontWeight.w400),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _sending ? null : () => _send(docId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: _sending ? null : AETheme.indigoGradient,
                          color: _sending ? AETheme.faint : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _sending ? [] : [
                            BoxShadow(color: AETheme.indigo2.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: _sending
                            ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message msg;
  final Color   clientColor;
  final String  clientInitials;

  const _MessageBubble({
    required this.msg,
    required this.clientColor,
    required this.clientInitials,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = msg.isAdmin;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Admin avatar (left)
          if (isAdmin) ...[
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                gradient: AETheme.indigoGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text('AE', style: AETheme.syne(size: 9, color: Colors.white, weight: FontWeight.w800))),
            ),
            const SizedBox(width: 10),
          ],

          // Bubble
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.55),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAdmin ? AETheme.white : AETheme.indigo2,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(16),
                      topRight:    const Radius.circular(16),
                      bottomLeft:  isAdmin  ? Radius.zero : const Radius.circular(16),
                      bottomRight: !isAdmin ? Radius.zero : const Radius.circular(16),
                    ),
                    border: isAdmin ? Border.all(color: const Color(0x10070921)) : null,
                    boxShadow: [
                      BoxShadow(
                      color: Colors.black.withValues(alpha: isAdmin ? 0.05 : 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: AETheme.syne(
                      size: 13,
                      color: isAdmin ? AETheme.ink : Colors.white,
                      weight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${isAdmin ? 'AlphaEdge Advisor · ' : ''}${msg.time}',
                  style: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Client avatar (right)
          if (!isAdmin) ...[
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 17,
              backgroundColor: clientColor,
              child: Text(clientInitials, style: AETheme.syne(size: 10, color: Colors.white, weight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }
}
