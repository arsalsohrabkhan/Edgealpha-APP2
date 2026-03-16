import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/client_model.dart';
import '../../theme/app_theme.dart';
import 'admin_screen.dart';

class AdminMessagesScreen extends StatefulWidget {
  const AdminMessagesScreen({super.key});
  @override State<AdminMessagesScreen> createState() => _AdminMessagesScreenState();
}

class _AdminMessagesScreenState extends State<AdminMessagesScreen> {
  int?   _selectedId;
  final  _ctrl   = TextEditingController();
  final  _scroll = ScrollController();
  bool   _sending = false;

  @override
  void dispose() { _ctrl.dispose(); _scroll.dispose(); super.dispose(); }

  Future<void> _reply(String docId) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await context.read<FirestoreService>().sendMessage(clientDocId: docId, from: 'admin', text: text);
    _ctrl.clear();
    setState(() => _sending = false);
    await Future.delayed(const Duration(milliseconds: 150));
    if (_scroll.hasClients) {
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();
    return Scaffold(
      backgroundColor: AETheme.bg,
      body: Column(
        children: [
          const AdminTopBar(),
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: fs.streamAllClients(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AETheme.indigo2));
                }
                final clients = snap.data ?? [];
                final selected = _selectedId != null ? clients.where((c) => c.id == _selectedId).firstOrNull : null;

                final narrow = MediaQuery.of(context).size.width < 700;
                
                // On narrow screens: show list or chat, not both
                if (narrow) {
                  if (selected != null) {
                    return _NarrowChat(
                      selected: selected,
                      ctrl: _ctrl,
                      scroll: _scroll,
                      sending: _sending,
                      onBack: () => setState(() => _selectedId = null),
                      onSend: () => _reply(selected.id.toString()),
                    );
                  }
                  return _NarrowClientList(
                    clients: clients,
                    selectedId: _selectedId,
                    onSelect: (id) => setState(() => _selectedId = id),
                  );
                }

                return Row(
                  children: [
                    // ── Client list sidebar ──
                    Container(
                      width: 280,
                      decoration: const BoxDecoration(
                        color: AETheme.white,
                        border: Border(right: BorderSide(color: Color(0x0C070921))),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x0C070921)))),
                            child: Row(
                              children: [
                                Text('Clients', style: AETheme.syne(size: 13, weight: FontWeight.w800)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0x124F46E5), borderRadius: BorderRadius.circular(10)),
                                  child: Text('${clients.length}', style: AETheme.syne(size: 10, color: AETheme.indigo2, weight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: clients.length,
                              itemBuilder: (_, i) {
                                final c        = clients[i];
                                final isActive = _selectedId == c.id;
                                final unread   = c.messages.where((m) => m.isClient).length;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedId = c.id),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isActive ? const Color(0x0C4F46E5) : Colors.transparent,
                                      border: Border(left: BorderSide(color: isActive ? AETheme.indigo2 : Colors.transparent, width: 3)),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Color(c.colorValue),
                                          child: Text(c.initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(c.fullName, style: AETheme.syne(size: 12, weight: FontWeight.w800, color: isActive ? AETheme.indigo2 : AETheme.ink)),
                                              const SizedBox(height: 2),
                                              Text(
                                                c.messages.isEmpty ? 'No messages' : c.messages.last.text,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (unread > 0)
                                          Container(
                                            width: 18, height: 18,
                                            decoration: const BoxDecoration(color: AETheme.red2, shape: BoxShape.circle),
                                            child: Center(child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800))),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── Chat area ──
                    Expanded(
                      child: selected == null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💬', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 12),
                                  Text('Select a client to view thread', style: AETheme.syne(size: 14, color: AETheme.muted)),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                // Chat header
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  decoration: const BoxDecoration(
                                    color: AETheme.white,
                                    border: Border(bottom: BorderSide(color: Color(0x0C070921))),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(radius: 16, backgroundColor: Color(selected.colorValue), child: Text(selected.initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(selected.fullName, style: AETheme.syne(size: 14, weight: FontWeight.w800)),
                                          Text('${selected.messages.length} messages · ${selected.risk} risk', style: AETheme.syne(size: 10, color: AETheme.muted)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Messages
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scroll,
                                    padding: const EdgeInsets.all(20),
                                    itemCount: selected.messages.length,
                                    itemBuilder: (_, i) => _AdminMsgBubble(
                                      msg: selected.messages[i],
                                      clientColor: Color(selected.colorValue),
                                      clientInitials: selected.initials,
                                    ),
                                  ),
                                ),
                                // Reply box
                                Container(
                                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                                  decoration: const BoxDecoration(
                                    color: AETheme.white,
                                    border: Border(top: BorderSide(color: Color(0x0C070921))),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(color: AETheme.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x10070921))),
                                          child: TextField(
                                            controller: _ctrl,
                                            style: AETheme.syne(size: 13),
                                            maxLines: 3, minLines: 1,
                                            onSubmitted: (_) => _reply(selected.id.toString()),
                                            decoration: InputDecoration(
                                              hintText: 'Reply to ${selected.first}…',
                                              hintStyle: AETheme.syne(size: 13, color: AETheme.faint, weight: FontWeight.w400),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: _sending ? null : () => _reply(selected.id.toString()),
                                        child: Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            gradient: _sending ? null : AETheme.indigoGradient,
                                            color: _sending ? AETheme.faint : null,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: _sending
                                              ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                              : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMsgBubble extends StatelessWidget {
  final Message msg;
  final Color   clientColor;
  final String  clientInitials;
  const _AdminMsgBubble({required this.msg, required this.clientColor, required this.clientInitials});

  @override
  Widget build(BuildContext context) {
    final isAdmin = msg.isAdmin;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(radius: 14, backgroundColor: clientColor, child: Text(clientInitials, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.45),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isAdmin ? AETheme.indigo2 : AETheme.white,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(14),
                      topRight:    const Radius.circular(14),
                      bottomLeft:  isAdmin  ? const Radius.circular(14) : Radius.zero,
                      bottomRight: !isAdmin ? const Radius.circular(14) : Radius.zero,
                    ),
                    border: isAdmin ? null : Border.all(color: const Color(0x10070921)),
                  ),
                  child: Text(msg.text, style: AETheme.syne(size: 12, color: isAdmin ? Colors.white : AETheme.ink, weight: FontWeight.w400)),
                ),
                const SizedBox(height: 3),
                Text(msg.time, style: AETheme.syne(size: 8, color: AETheme.muted)),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(gradient: AETheme.indigoGradient, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('AE', style: AETheme.syne(size: 8, color: Colors.white, weight: FontWeight.w800))),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Narrow (phone) client list ────────────────────────────────
class _NarrowClientList extends StatelessWidget {
  final List<Client> clients;
  final int? selectedId;
  final void Function(int) onSelect;
  const _NarrowClientList({required this.clients, required this.selectedId, required this.onSelect});
  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: clients.length,
    itemBuilder: (_, i) {
      final c = clients[i];
      return GestureDetector(
        onTap: () => onSelect(c.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AETheme.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x10070921)),
          ),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: Color(c.colorValue),
                child: Text(c.initials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.fullName, style: AETheme.syne(size: 13, weight: FontWeight.w800), overflow: TextOverflow.ellipsis),
              Text(c.messages.isEmpty ? 'No messages' : c.messages.last.text,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w400)),
            ])),
            const Icon(Icons.chevron_right, color: AETheme.faint, size: 20),
          ]),
        ),
      );
    },
  );
}

// ── Narrow (phone) chat view ──────────────────────────────────
class _NarrowChat extends StatelessWidget {
  final Client selected;
  final TextEditingController ctrl;
  final ScrollController scroll;
  final bool sending;
  final VoidCallback onBack, onSend;
  const _NarrowChat({required this.selected, required this.ctrl, required this.scroll,
    required this.sending, required this.onBack, required this.onSend});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: AETheme.white, border: Border(bottom: BorderSide(color: Color(0x0C070921)))),
      child: Row(children: [
        GestureDetector(onTap: onBack, child: const Icon(Icons.arrow_back_ios, size: 18, color: AETheme.ink)),
        const SizedBox(width: 10),
        CircleAvatar(radius: 16, backgroundColor: Color(selected.colorValue),
            child: Text(selected.initials, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
        const SizedBox(width: 10),
        Expanded(child: Text(selected.fullName, style: AETheme.syne(size: 14, weight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
      ]),
    ),
    Expanded(child: ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.all(16),
      itemCount: selected.messages.length,
      itemBuilder: (_, i) => _AdminMsgBubble(
        msg: selected.messages[i],
        clientColor: Color(selected.colorValue),
        clientInitials: selected.initials,
      ),
    )),
    Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(color: AETheme.white, border: Border(top: BorderSide(color: Color(0x0C070921)))),
      child: Row(children: [
        Expanded(child: Container(
          decoration: BoxDecoration(color: AETheme.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x10070921))),
          child: TextField(
            controller: ctrl,
            style: AETheme.syne(size: 13),
            maxLines: 3, minLines: 1,
            onSubmitted: (_) => onSend(),
            decoration: InputDecoration(
              hintText: 'Reply to ${selected.first}…',
              hintStyle: AETheme.syne(size: 13, color: AETheme.faint, weight: FontWeight.w400),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: InputBorder.none,
            ),
          ),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: sending ? null : onSend,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: sending ? null : AETheme.indigoGradient,
              color: sending ? AETheme.faint : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: sending
                ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    ),
  ]);
}
