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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AETheme.bg,
      body: Column(
        children: [
          const AdminTopBar(title: 'Portfolio Oversight', subtitle: 'All client accounts'),
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: context.read<FirestoreService>().streamAllClients(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AETheme.indigo2));
                }
                final clients = snap.data ?? [];
                if (clients.isEmpty) {
                  return Center(child: Text('No clients in Firestore yet.', style: AETheme.syne(size: 13, color: AETheme.muted)));
                }
                return _AdminBody(clients: clients);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBody extends StatelessWidget {
  final List<Client> clients;
  const _AdminBody({required this.clients});

  @override
  Widget build(BuildContext context) {
    final fmt      = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final totalAum = clients.fold(0.0, (s, c) => s + c.aum);
    final totalPnl = clients.fold(0.0, (s, c) => s + c.totalPnl);
    final avgWin   = clients.isEmpty ? 0 : (clients.fold(0, (s, c) => s + c.winRate) / clients.length).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _OCard(label: 'Total AUM',    value: fmt.format(totalAum),   color: AETheme.indigo2),
              _OCard(label: 'Total P&L',    value: '${totalPnl >= 0 ? '+' : ''}${fmt.format(totalPnl)}', color: totalPnl >= 0 ? AETheme.green : AETheme.red),
              _OCard(label: 'Clients',      value: '${clients.length}',    color: AETheme.amber),
              _OCard(label: 'Avg Win Rate', value: '$avgWin%',             color: AETheme.sky),
            ],
          ),
          const SizedBox(height: 24),
          Text('ALL CLIENTS', style: AETheme.syne(size: 10, weight: FontWeight.w800, color: AETheme.muted, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...clients.map((c) => _ClientRow(client: c, fmt: fmt)),
        ],
      ),
    );
  }
}

class _OCard extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _OCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AETheme.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0x10070921)),
      boxShadow: const [BoxShadow(color: Color(0x06070921), blurRadius: 10, offset: Offset(0, 3))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label.toUpperCase(), style: AETheme.syne(size: 8, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(value, style: AETheme.fraunces(size: 22, color: color, letterSpacing: -1),
            overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _ClientRow extends StatefulWidget {
  final Client client;
  final NumberFormat fmt;
  const _ClientRow({required this.client, required this.fmt});
  @override State<_ClientRow> createState() => _ClientRowState();
}
class _ClientRowState extends State<_ClientRow> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF8F7FF) : AETheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _hovered ? const Color(0x304F46E5) : const Color(0x10070921)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: _hovered ? 0.07 : 0.03),
              blurRadius: _hovered ? 16 : 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Color(c.colorValue),
                child: Text(c.initials, style: AETheme.syne(size: 11, color: Colors.white, weight: FontWeight.w800)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.fullName, style: AETheme.syne(size: 13, weight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis),
                  Text('${c.risk} · ${c.joined}', style: AETheme.syne(size: 9, color: AETheme.muted),
                      overflow: TextOverflow.ellipsis),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: const Color(0x14047857), borderRadius: BorderRadius.circular(20)),
                child: Text(c.status, style: AETheme.syne(size: 9, color: AETheme.green, weight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _Stat('AUM',      widget.fmt.format(c.aum),    AETheme.indigo2),
              _Stat('P&L',      '${c.totalPnl >= 0 ? '+' : ''}${widget.fmt.format(c.totalPnl.abs())}', c.totalPnl >= 0 ? AETheme.green : AETheme.red),
              _Stat('Return',   '${c.ret >= 0 ? '+' : ''}${c.ret}%', c.ret >= 0 ? AETheme.green : AETheme.red),
              _Stat('Win Rate', '${c.winRate}%', AETheme.amber),
              _Stat('Trades',   '${c.trades.length}', AETheme.ink),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(label.toUpperCase(), style: AETheme.syne(size: 7, color: AETheme.muted,
            weight: FontWeight.w800, letterSpacing: 1), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(value, style: AETheme.syne(size: 11, color: color, weight: FontWeight.w700),
            overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class AdminTopBar extends StatelessWidget {
  final String title, subtitle;
  const AdminTopBar({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    return Container(
      decoration: const BoxDecoration(
        color: AETheme.white,
        border: Border(bottom: BorderSide(color: Color(0x10070921))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Top row: logo + sign out
          Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(gradient: AETheme.indigoGradient, borderRadius: BorderRadius.circular(9)),
              child: const Icon(Icons.show_chart, color: Colors.white, size: 15),
            ),
            const SizedBox(width: 8),
            RichText(text: TextSpan(
              style: AETheme.fraunces(size: 15),
              children: const [
                TextSpan(text: 'Alpha'),
                TextSpan(text: 'Edge', style: TextStyle(color: AETheme.indigo2)),
                TextSpan(text: ' Admin', style: TextStyle(color: AETheme.muted, fontSize: 12)),
              ],
            )),
            const Spacer(),
            GestureDetector(
              onTap: () { context.read<AuthService>().logout(); context.go('/login'); },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0x08070921), borderRadius: BorderRadius.circular(8)),
                child: Text('Sign Out', style: AETheme.syne(size: 11, color: AETheme.muted, weight: FontWeight.w700)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          // Nav tabs row
          Row(children: [
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? const Color(0x124F46E5) : const Color(0x08070921),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: active ? const Color(0x304F46E5) : Colors.transparent),
                  ),
                  child: Text(item.$1, style: AETheme.syne(size: 12,
                      color: active ? AETheme.indigo2 : AETheme.slate, weight: FontWeight.w700)),
                ),
              ),
            );
          }).toList()),
        ],
      ),
    );
  }
}
