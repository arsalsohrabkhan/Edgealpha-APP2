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
      active:   'dashboard',
      title:    '${C.first} ${C.last} — Dashboard',
      subtitle: 'Welcome back, ${C.first}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats row
            _StatsRow(C),
            const SizedBox(height: 14),
            // Mid row: equity + allocation
            _MidRow(C),
            const SizedBox(height: 14),
            // Bottom: full table + recent
            _BotRow(C),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Client C;
  const _StatsRow(this.C);

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final pos = C.totalPnl >= 0;
    final ret = C.ret >= 0;

    return Row(
      children: [
        Expanded(child: StatCard(
          label: 'Account Value',
          value: fmt.format(C.aum),
          valueColor: AETheme.indigo2,
          sub: 'Capital: ${fmt.format(C.capital)}',
          subColor: AETheme.muted,
          subBg: const Color(0x0A070921),
          icon: '💼',
          accentColor: AETheme.indigo2,
        )),
        const SizedBox(width: 14),
        Expanded(child: StatCard(
          label: 'Total Return',
          value: '${ret ? '+' : ''}${C.ret}%',
          valueColor: ret ? AETheme.green : AETheme.red,
          sub: '${pos ? '▲ Profit' : '▼ Loss'} ${fmt.format(C.totalPnl.abs())}',
          subColor: pos ? AETheme.green : AETheme.red,
          subBg: pos ? const Color(0x12047857) : const Color(0x12DC2626),
          icon: '📈',
          accentColor: AETheme.green,
        )),
        const SizedBox(width: 14),
        Expanded(child: StatCard(
          label: 'Win Rate',
          value: '${C.winRate}%',
          valueColor: AETheme.amber,
          sub: '▲ ${C.wins}W / ${C.losses}L',
          subColor: AETheme.green,
          subBg: const Color(0x12047857),
          icon: '✅',
          accentColor: AETheme.amber,
        )),
        const SizedBox(width: 14),
        Expanded(child: StatCard(
          label: 'Total Trades',
          value: C.trades.length.toString(),
          valueColor: AETheme.ink,
          sub: 'Closed positions',
          subColor: AETheme.muted,
          subBg: const Color(0x0A070921),
          icon: '📋',
          accentColor: AETheme.sky,
        )),
      ],
    );
  }
}

class _MidRow extends StatelessWidget {
  final Client C;
  const _MidRow(this.C);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Equity chart card
        Expanded(
          flex: 3,
          child: AECard(
            child: Column(
              children: [
                _CardHead(title: 'Account Growth', sub: 'Cumulative P&L across all trades', tag: 'Equity Curve'),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: EquityLineChart(equity: C.equity, months: C.months),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Asset mix
        SizedBox(
          width: 300,
          child: AECard(
            child: Column(
              children: [
                _CardHead(title: 'Asset Mix', sub: 'By traded asset class'),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AllocationDonut(
                    allocation: C.allocation,
                    winRate:    C.winRate,
                    colorValue: C.colorValue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BotRow extends StatelessWidget {
  final Client C;
  const _BotRow(this.C);

  @override
  Widget build(BuildContext context) {
    final fmt    = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final trades = C.trades.reversed.toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full trades table
        Expanded(
          flex: 3,
          child: AECard(
            child: Column(
              children: [
                _CardHead(title: 'Performance Summary', sub: 'All closed trades · newest first'),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AETheme.bg),
                    headingTextStyle: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1.5),
                    dataTextStyle: AETheme.syne(size: 12),
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('ASSET')),
                      DataColumn(label: Text('DIRECTION')),
                      DataColumn(label: Text('P&L'), numeric: true),
                      DataColumn(label: Text('RETURN'), numeric: true),
                      DataColumn(label: Text('CLOSED'), numeric: true),
                    ],
                    rows: trades.map((t) => DataRow(cells: [
                      DataCell(Text(t.asset, style: AETheme.syne(size: 12, weight: FontWeight.w800))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.isLong ? const Color(0x12047857) : const Color(0x12DC2626),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          t.isLong ? '▲ Long' : '▼ Short',
                          style: AETheme.syne(size: 9, color: t.isLong ? AETheme.green : AETheme.red, weight: FontWeight.w800),
                        ),
                      )),
                      DataCell(Text(
                        '${t.pnl >= 0 ? '+' : '−'}${fmt.format(t.pnl.abs())}',
                        style: AETheme.syne(size: 12, color: t.isWin ? AETheme.green : AETheme.red, weight: FontWeight.w700),
                      )),
                      DataCell(Text(
                        '${t.pct >= 0 ? '+' : ''}${t.pct}%',
                        style: AETheme.syne(size: 12, color: t.pct >= 0 ? AETheme.green : AETheme.red, weight: FontWeight.w700),
                      )),
                      DataCell(Text(t.closeDate, style: AETheme.syne(size: 10, color: AETheme.muted))),
                    ])).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Recent trades mini list
        SizedBox(
          width: 280,
          child: AECard(
            child: Column(
              children: [
                _CardHead(title: 'Recent Trades', sub: 'Latest 5'),
                ...C.trades.reversed.take(5).map((t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x08070921)))),
                  child: Row(
                    children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: t.isLong ? const Color(0x18047857) : const Color(0x14DC2626),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            t.isLong ? 'L' : 'S',
                            style: AETheme.syne(size: 10, color: t.isLong ? AETheme.green : AETheme.red, weight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.asset, style: AETheme.syne(size: 12, weight: FontWeight.w800)),
                            Text(t.closeDate, style: AETheme.syne(size: 10, color: AETheme.muted)),
                          ],
                        ),
                      ),
                      Text(
                        '${t.pnl >= 0 ? '+' : '−'}${fmt.format(t.pnl.abs())}',
                        style: AETheme.syne(size: 13, color: t.isWin ? AETheme.green : AETheme.red, weight: FontWeight.w800),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CardHead extends StatelessWidget {
  final String title, sub;
  final String? tag;
  const _CardHead({required this.title, required this.sub, this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x08070921)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AETheme.syne(size: 13, weight: FontWeight.w800)),
              const SizedBox(height: 1),
              Text(sub, style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w400)),
            ],
          ),
          if (tag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0x124F46E5), borderRadius: BorderRadius.circular(20)),
              child: Text(tag!, style: AETheme.syne(size: 8, color: AETheme.indigo2, weight: FontWeight.w800, letterSpacing: 1.5)),
            ),
        ],
      ),
    );
  }
}
