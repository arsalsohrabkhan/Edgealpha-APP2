import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/client_model.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/charts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final C    = auth.client;
    if (C == null) return const SizedBox();

    return ClientScaffold(
      active: 'dashboard',
      title: '${C.first} ${C.last} — Dashboard',
      subtitle: 'Welcome back, ${C.first}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(children: [
          _WelcomeBanner(C),
          const SizedBox(height: 16),
          _StatsGrid(C),
          const SizedBox(height: 16),
          _EquityCard(C),
          const SizedBox(height: 16),
          _AllocationCard(C),
          const SizedBox(height: 16),
          _TradesCard(C),
        ]),
      ),
    );
  }
}

// ── Welcome Banner ────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  final Client C;
  const _WelcomeBanner(this.C);
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final pos = C.totalPnl >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: AETheme.indigoGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: AETheme.indigo2.withValues(alpha: 0.35),
          blurRadius: 20, offset: const Offset(0, 8),
        )],
      ),
      padding: const EdgeInsets.all(22),
      child: Row(children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Portfolio Value',
              style: AETheme.syne(size: 11, color: const Color(0xA0FFFFFF),
                  weight: FontWeight.w600, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            Text(fmt.format(C.aum),
              style: AETheme.fraunces(size: 32, color: Colors.white, letterSpacing: -1)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: pos ? const Color(0x2510B981) : const Color(0x25EF4444),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(pos ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                    size: 12, color: pos ? AETheme.green2 : AETheme.red2),
                const SizedBox(width: 4),
                Text(
                  '${pos ? '+' : ''}${fmt.format(C.totalPnl)} (${C.ret >= 0 ? '+' : ''}${C.ret}%)',
                  style: AETheme.syne(size: 11, weight: FontWeight.w700,
                      color: pos ? AETheme.green2 : AETheme.red2),
                ),
              ]),
            ),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          CircleAvatar(
            radius: 26, backgroundColor: Color(C.colorValue),
            child: Text(C.initials, style: AETheme.syne(
                size: 16, color: Colors.white, weight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x25FFFFFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(C.risk, style: AETheme.syne(
                size: 9, color: Colors.white, weight: FontWeight.w700)),
          ),
        ]),
      ]),
    );
  }
}

// ── Stats Grid ────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final Client C;
  const _StatsGrid(this.C);
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final pos = C.totalPnl >= 0;
    final ret = C.ret >= 0;
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        StatCard(
          label: 'Total Return', value: '${ret ? '+' : ''}${C.ret}%',
          valueColor: ret ? AETheme.green : AETheme.red,
          sub: '${pos ? '▲' : '▼'} ${fmt.format(C.totalPnl.abs())}',
          subColor: pos ? AETheme.green : AETheme.red,
          subBg: pos ? const Color(0x12047857) : const Color(0x12DC2626),
          icon: '📈', accentColor: AETheme.green,
        ),
        StatCard(
          label: 'Win Rate', value: '${C.winRate}%',
          valueColor: AETheme.amber,
          sub: '${C.wins}W · ${C.losses}L',
          subColor: AETheme.amber, subBg: const Color(0x14B45309),
          icon: '🏆', accentColor: AETheme.amber,
        ),
        StatCard(
          label: 'Sharpe Ratio', value: C.sharpe.toStringAsFixed(2),
          valueColor: AETheme.indigo2,
          sub: 'Annualised',
          subColor: AETheme.indigo2, subBg: const Color(0x124F46E5),
          icon: '⚡', accentColor: AETheme.indigo2,
        ),
        StatCard(
          label: 'Total Trades', value: '${C.trades.length}',
          valueColor: AETheme.ink, sub: 'Closed positions',
          subColor: AETheme.muted, subBg: const Color(0x0A070921),
          icon: '📋', accentColor: AETheme.sky,
        ),
      ],
    );
  }
}

// ── Equity Card ───────────────────────────────────────────
class _EquityCard extends StatelessWidget {
  final Client C;
  const _EquityCard(this.C);
  @override
  Widget build(BuildContext context) => AECard(
    child: Column(children: [
      _CardHead(title: 'Account Growth', sub: 'Equity curve across all trades',
          tag: 'LIVE', tagColor: AETheme.green),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: EquityLineChart(equity: C.equity, months: C.months, height: 160),
      ),
    ]),
  );
}

// ── Allocation Card ───────────────────────────────────────
class _AllocationCard extends StatelessWidget {
  final Client C;
  const _AllocationCard(this.C);
  @override
  Widget build(BuildContext context) => AECard(
    child: Column(children: [
      _CardHead(title: 'Asset Mix', sub: 'By P&L contribution'),
      Padding(
        padding: const EdgeInsets.all(16),
        child: AllocationDonut(
          allocation: C.allocation, winRate: C.winRate,
          colorValue: C.colorValue, size: 130,
        ),
      ),
    ]),
  );
}

// ── Trades Card ───────────────────────────────────────────
class _TradesCard extends StatelessWidget {
  final Client C;
  const _TradesCard(this.C);
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final trades = C.trades.reversed.take(5).toList();
    return AECard(
      child: Column(children: [
        _CardHead(title: 'Recent Trades', sub: 'Latest ${trades.length} closed'),
        ...trades.map((t) => _TradeRow(trade: t, fmt: fmt)),
      ]),
    );
  }
}

class _TradeRow extends StatelessWidget {
  final Trade trade; final NumberFormat fmt;
  const _TradeRow({required this.trade, required this.fmt});
  @override
  Widget build(BuildContext context) {
    final t = trade;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0x08070921)))),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: t.isLong ? const Color(0x14047857) : const Color(0x14DC2626),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(
            t.isLong ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 18, color: t.isLong ? AETheme.green : AETheme.red,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.asset, style: AETheme.syne(size: 13, weight: FontWeight.w800)),
            Text(t.closeDate, style: AETheme.syne(size: 10, color: AETheme.muted)),
          ],
        )),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '${t.pnl >= 0 ? '+' : '−'}${fmt.format(t.pnl.abs())}',
            style: AETheme.fraunces(size: 16,
                color: t.isWin ? AETheme.green : AETheme.red, letterSpacing: -0.5),
          ),
          Text('${t.pct >= 0 ? '+' : ''}${t.pct}%',
            style: AETheme.syne(size: 10, weight: FontWeight.w700,
                color: t.pct >= 0 ? AETheme.green : AETheme.red)),
        ]),
      ]),
    );
  }
}

// ── Card Head ─────────────────────────────────────────────
class _CardHead extends StatelessWidget {
  final String title, sub;
  final String? tag;
  final Color tagColor;
  const _CardHead({required this.title, required this.sub,
    this.tag, this.tagColor = AETheme.indigo2});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x08070921)))),
    child: Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AETheme.syne(size: 14, weight: FontWeight.w800)),
          Text(sub, style: AETheme.syne(size: 11, color: AETheme.muted, weight: FontWeight.w400)),
        ],
      )),
      if (tag != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: tagColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(tag!, style: AETheme.syne(size: 9, color: tagColor,
              weight: FontWeight.w800, letterSpacing: 1)),
        ),
    ]),
  );
}
