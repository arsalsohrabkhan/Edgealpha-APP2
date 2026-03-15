import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/client_model.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class TradesScreen extends StatefulWidget {
  const TradesScreen({super.key});
  @override State<TradesScreen> createState() => _TradesScreenState();
}

class _TradesScreenState extends State<TradesScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();
    final client = auth.client;
    if (client == null) return const SizedBox();

    final docId = client.id.toString();
    final fs    = context.read<FirestoreService>();

    return ClientScaffold(
      active:   'mytrades',
      title:    'My Trades',
      subtitle: 'All closed positions',
      body: StreamBuilder<Client?>(
        stream: fs.streamClient(docId),
        builder: (context, snap) {
          final C   = snap.data ?? client;
          final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

          List<Trade> trades = C.trades.reversed.toList();
          if (_filter == 'Long')  trades = trades.where((t) => t.isLong).toList();
          if (_filter == 'Short') trades = trades.where((t) => !t.isLong).toList();
          if (_filter == 'Win')   trades = trades.where((t) => t.isWin).toList();
          if (_filter == 'Loss')  trades = trades.where((t) => !t.isWin).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary bar
              Container(
                color: AETheme.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _SummaryPill('${C.trades.length} Trades', AETheme.ink, const Color(0x0A070921)),
                      const SizedBox(width: 8),
                      _SummaryPill('${C.wins}W · ${C.losses}L', AETheme.green, const Color(0x14047857)),
                      const SizedBox(width: 8),
                      _SummaryPill('${C.winRate}% Win Rate', AETheme.amber, const Color(0x14B45309)),
                    ],
                  ),
                ),
              ),
              // Filter chips
              Container(
                color: AETheme.bg,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                child: Row(
                  children: ['All', 'Long', 'Short', 'Win', 'Loss'].map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: _filter == f ? AETheme.indigo2 : AETheme.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _filter == f ? AETheme.indigo2 : const Color(0x20070921),
                          ),
                        ),
                        child: Text(
                          f,
                          style: AETheme.syne(
                            size: 11,
                            color: _filter == f ? Colors.white : AETheme.slate,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 8),
              // Trade list
              Expanded(
                child: trades.isEmpty
                    ? Center(child: Text('No ${_filter == 'All' ? '' : '$_filter '}trades found.', style: AETheme.syne(size: 13, color: AETheme.muted)))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        itemCount: trades.length,
                        itemBuilder: (_, i) => _TradeCard(trade: trades[i], fmt: fmt),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final Color color, bg;
  const _SummaryPill(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: AETheme.syne(size: 11, color: color, weight: FontWeight.w700)),
  );
}

class _TradeCard extends StatefulWidget {
  final Trade trade;
  final NumberFormat fmt;
  const _TradeCard({required this.trade, required this.fmt});
  @override State<_TradeCard> createState() => _TradeCardState();
}

class _TradeCardState extends State<_TradeCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final t = widget.trade;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(_hovered ? 6 : 0, _hovered ? -2 : 0, 0),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AETheme.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? (t.isWin ? const Color(0x40047857) : const Color(0x40DC2626))
                : const Color(0x12070921),
          ),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
            blurRadius: _hovered ? 24 : 10,
            offset: const Offset(0, 3),
          )],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Colored left bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: t.isWin
                        ? [AETheme.green, AETheme.green2]
                        : [AETheme.red,   AETheme.red2],
                  ),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                  child: Row(
                    children: [
                      // Asset icon box
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: t.isLong ? const Color(0x14047857) : const Color(0x14DC2626),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            t.isLong ? '▲' : '▼',
                            style: TextStyle(
                              fontSize: 18,
                              color: t.isLong ? AETheme.green : AETheme.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // P&L + meta
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.asset,
                              style: AETheme.syne(size: 14, weight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${t.isLong ? 'Long' : 'Short'} · ${t.openDate} → ${t.closeDate}',
                              style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: t.isWin ? const Color(0x14047857) : const Color(0x14DC2626),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t.isWin ? 'PROFIT' : 'LOSS',
                          style: AETheme.syne(size: 8, color: t.isWin ? AETheme.green : AETheme.red, weight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // P&L amount + pct
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${t.pnl >= 0 ? '+' : '−'}${widget.fmt.format(t.pnl.abs())}',
                            style: AETheme.fraunces(size: 22, color: t.isWin ? AETheme.green : AETheme.red, letterSpacing: -1),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${t.pct >= 0 ? '+' : ''}${t.pct}%',
                            style: AETheme.syne(size: 13, color: t.pct >= 0 ? AETheme.green : AETheme.red, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
