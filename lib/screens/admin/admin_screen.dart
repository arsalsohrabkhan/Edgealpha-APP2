import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../models/client_model.dart';
import '../../theme/app_theme.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AETheme.bg,
    body: Column(children: [
      const AdminTopBar(),
      Expanded(child: StreamBuilder<List<Client>>(
        stream: context.read<FirestoreService>().streamAllClients(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AETheme.indigo2));
          }
          final clients = snap.data ?? [];
          if (clients.isEmpty) return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('📭', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No clients yet', style: AETheme.syne(size: 16, color: AETheme.muted)),
              const SizedBox(height: 4),
              Text('Add clients to Firestore to see them here',
                  style: AETheme.syne(size: 12, color: AETheme.faint, weight: FontWeight.w400)),
            ]),
          );
          return _AdminBody(clients: clients);
        },
      )),
    ]),
  );
}

class _AdminBody extends StatelessWidget {
  final List<Client> clients;
  const _AdminBody({required this.clients});

  @override
  Widget build(BuildContext context) {
    final fmt      = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final totalAum = clients.fold(0.0, (s, c) => s + c.aum);
    final totalPnl = clients.fold(0.0, (s, c) => s + c.totalPnl);
    final avgWin   = clients.isEmpty ? 0
        : (clients.fold(0, (s, c) => s + c.winRate) / clients.length).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary banner
        Container(
          decoration: BoxDecoration(
            gradient: AETheme.indigoGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
              color: AETheme.indigo2.withValues(alpha: 0.3),
              blurRadius: 20, offset: const Offset(0, 8),
            )],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total AUM', style: AETheme.syne(
                    size: 11, color: const Color(0x90FFFFFF), weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(fmt.format(totalAum), style: AETheme.fraunces(
                    size: 28, color: Colors.white, letterSpacing: -1)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (totalPnl >= 0
                        ? const Color(0x2510B981) : const Color(0x25EF4444)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${totalPnl >= 0 ? '+' : ''}${fmt.format(totalPnl)} P&L',
                    style: AETheme.syne(size: 11, weight: FontWeight.w700,
                        color: totalPnl >= 0 ? AETheme.green2 : AETheme.red2),
                  ),
                ),
              ],
            )),
            Column(children: [
              _MBubble('${clients.length}', 'Clients', AETheme.amber2),
              const SizedBox(height: 8),
              _MBubble('$avgWin%', 'Avg Win', AETheme.green2),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        Text('ALL CLIENTS', style: AETheme.syne(
            size: 10, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 12),

        ...clients.map((c) => _ClientCard(client: c, fmt: fmt)),
      ]),
    );
  }
}

class _MBubble extends StatelessWidget {
  final String val, label; final Color color;
  const _MBubble(this.val, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: 80,
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0x20FFFFFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(children: [
      Text(val, style: AETheme.fraunces(size: 18, color: color, letterSpacing: -0.5)),
      Text(label, style: AETheme.syne(size: 9, color: const Color(0x80FFFFFF))),
    ]),
  );
}

class _ClientCard extends StatelessWidget {
  final Client client; final NumberFormat fmt;
  const _ClientCard({required this.client, required this.fmt});
  @override
  Widget build(BuildContext context) {
    final c = client;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AETheme.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x0F070921)),
        boxShadow: const [BoxShadow(
            color: Color(0x07070921), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Column(children: [
        // Header row
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            CircleAvatar(
              radius: 22, backgroundColor: Color(c.colorValue),
              child: Text(c.initials, style: AETheme.syne(
                  size: 13, color: Colors.white, weight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.fullName, style: AETheme.syne(
                    size: 14, weight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                Text('${c.risk} · Joined ${c.joined}',
                    style: AETheme.syne(size: 10, color: AETheme.muted)),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0x14047857),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(c.status, style: AETheme.syne(
                  size: 10, color: AETheme.green, weight: FontWeight.w800)),
            ),
          ]),
        ),
        // Stats row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0x05070921),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          ),
          child: Row(children: [
            _CStatCol('AUM',      fmt.format(c.aum),      AETheme.indigo2),
            _CDivider(),
            _CStatCol('P&L',      '${c.totalPnl >= 0 ? '+' : ''}${fmt.format(c.totalPnl.abs())}',
                c.totalPnl >= 0 ? AETheme.green : AETheme.red),
            _CDivider(),
            _CStatCol('Return',   '${c.ret >= 0 ? '+' : ''}${c.ret}%',
                c.ret >= 0 ? AETheme.green : AETheme.red),
            _CDivider(),
            _CStatCol('Win Rate', '${c.winRate}%', AETheme.amber),
            _CDivider(),
            _CStatCol('Trades',   '${c.trades.length}', AETheme.ink),
          ]),
        ),
      ]),
    );
  }
}

class _CDivider extends StatelessWidget {
  @override Widget build(BuildContext context) =>
    Container(width: 1, height: 28, color: const Color(0x10070921));
}

class _CStatCol extends StatelessWidget {
  final String label, value; final Color color;
  const _CStatCol(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label.toUpperCase(), style: AETheme.syne(
        size: 7, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1)),
    const SizedBox(height: 4),
    Text(value, style: AETheme.syne(size: 11, color: color, weight: FontWeight.w800),
        overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
  ]));
}

// ── Shared Admin Top Bar ──────────────────────────────────
class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});
  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    return Container(
      decoration: const BoxDecoration(
        gradient: AETheme.darkGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  gradient: AETheme.indigoGradient,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              RichText(text: TextSpan(
                style: AETheme.fraunces(size: 16, color: Colors.white),
                children: const [
                  TextSpan(text: 'Alpha'),
                  TextSpan(text: 'Edge', style: TextStyle(color: AETheme.indigo3)),
                  TextSpan(text: ' Admin',
                      style: TextStyle(color: Color(0x80FFFFFF), fontSize: 13,
                          fontWeight: FontWeight.w400)),
                ],
              )),
              const Spacer(),
              GestureDetector(
                onTap: () { context.read<AuthService>().logout(); context.go('/login'); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0x20FFFFFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('Sign Out', style: AETheme.syne(
                      size: 12, color: Colors.white, weight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          // Nav tabs
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(children: [
              ('Portfolio',  '/admin'),
              ('Messages',   '/admin/messages'),
              ('Reports',    '/admin/reports'),
            ].map((item) {
              final active = loc == item.$2;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => context.go(item.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF4F46E5) : const Color(0x20FFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(item.$1, style: AETheme.syne(
                        size: 13, color: Colors.white, weight: FontWeight.w700)),
                  ),
                ),
              );
            }).toList()),
          ),
          const SizedBox(height: 14),
        ]),
      ),
    );
  }
}
