import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/client_model.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final C   = context.watch<AuthService>().client;
    if (C == null) return const SizedBox();
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return ClientScaffold(
      active: 'reports',
      title: 'Reports',
      subtitle: 'Download your account reports',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ReportCard(
                  icon: '📄',
                  title: 'Account Summary',
                  desc: 'Full account overview with current value, capital, total P&L, win rate, and key performance metrics.',
                  color: AETheme.indigo2,
                  gradient: AETheme.indigoGradient,
                  onGenerate: () => _showSummary(context, C, fmt),
                ),
                const SizedBox(height: 14),
                _ReportCard(
                  icon: '📊',
                  title: 'Trade History',
                  desc: 'Complete log of all closed trades with asset, direction, P&L, return %, open and close dates.',
                  color: AETheme.green,
                  gradient: AETheme.greenGradient,
                  onGenerate: () => _showTradeHistory(context, C, fmt),
                ),
                const SizedBox(height: 14),
                _ReportCard(
                  icon: '📈',
                  title: 'Performance Report',
                  desc: 'Sharpe ratio, max drawdown, long/short breakdown, per-asset attribution and equity curve data.',
                  color: AETheme.amber,
                  gradient: AETheme.amberGradient,
                  onGenerate: () => _showPerformance(context, C),
                ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSummary(BuildContext context, Client C, NumberFormat fmt) {
    _showReportDialog(context, 'Account Summary — ${C.fullName}', [
      ['Client',        C.fullName],
      ['Email',         C.email],
      ['Joined',        C.joined],
      ['Risk Profile',  C.risk],
      ['Initial Capital', fmt.format(C.capital)],
      ['Current AUM',   fmt.format(C.aum)],
      ['Total P&L',     '${C.totalPnl >= 0 ? '+' : ''}${fmt.format(C.totalPnl)}'],
      ['Total Return',  '${C.ret >= 0 ? '+' : ''}${C.ret}%'],
      ['Win Rate',      '${C.winRate}%'],
      ['Total Trades',  '${C.trades.length}'],
      ['Wins / Losses', '${C.wins}W · ${C.losses}L'],
      ['Sharpe Ratio',  C.sharpe.toStringAsFixed(2)],
      ['Max Drawdown',  '${C.drawdown}%'],
    ]);
  }

  void _showTradeHistory(BuildContext context, Client C, NumberFormat fmt) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogHeader(title: 'Trade History — ${C.fullName}'),
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1.5),
                    dataTextStyle: AETheme.syne(size: 12),
                    columns: const [
                      DataColumn(label: Text('ASSET')),
                      DataColumn(label: Text('DIR')),
                      DataColumn(label: Text('P&L'), numeric: true),
                      DataColumn(label: Text('RET%'), numeric: true),
                      DataColumn(label: Text('OPENED')),
                      DataColumn(label: Text('CLOSED')),
                    ],
                    rows: C.trades.map((t) => DataRow(cells: [
                      DataCell(Text(t.asset, style: AETheme.syne(size: 12, weight: FontWeight.w800))),
                      DataCell(Text(t.isLong ? '▲ Long' : '▼ Short', style: AETheme.syne(size: 10, color: t.isLong ? AETheme.green : AETheme.red, weight: FontWeight.w700))),
                      DataCell(Text('${t.pnl >= 0 ? '+' : '−'}${fmt.format(t.pnl.abs())}', style: AETheme.syne(size: 12, color: t.isWin ? AETheme.green : AETheme.red, weight: FontWeight.w700))),
                      DataCell(Text('${t.pct >= 0 ? '+' : ''}${t.pct}%', style: AETheme.syne(size: 12, color: t.pct >= 0 ? AETheme.green : AETheme.red))),
                      DataCell(Text(t.openDate, style: AETheme.syne(size: 10, color: AETheme.muted))),
                      DataCell(Text(t.closeDate, style: AETheme.syne(size: 10, color: AETheme.muted))),
                    ])).toList(),
                  ),
                ),
              ),
              _DialogFooter(),
            ],
          ),
        ),
      ),
    );
  }

  void _showPerformance(BuildContext context, Client C) {
    _showReportDialog(context, 'Performance Report — ${C.fullName}', [
      ['Sharpe Ratio',    C.sharpe.toStringAsFixed(2)],
      ['Max Drawdown',    '${C.drawdown}%'],
      ['Win Rate',        '${C.winRate}%'],
      ['Wins',            '${C.wins}'],
      ['Losses',          '${C.losses}'],
      ['Long Trades',     '${C.trades.where((t) => t.isLong).length}'],
      ['Short Trades',    '${C.trades.where((t) => !t.isLong).length}'],
      ['Best Trade',      '${C.trades.map((t) => t.pct).reduce((a, b) => a > b ? a : b)}%'],
      ['Worst Trade',     '${C.trades.map((t) => t.pct).reduce((a, b) => a < b ? a : b)}%'],
      ...C.allocation.map((a) => ['${a.label} Allocation', '${a.pct}%']),
    ]);
  }

  void _showReportDialog(BuildContext context, String title, List<List<String>> rows) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 540,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogHeader(title: title),
              ...rows.map((r) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x08070921)))),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(r[0], style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 0.5))),
                    Expanded(flex: 3, child: Text(r[1], style: AETheme.syne(size: 13, weight: FontWeight.w700))),
                  ],
                ),
              )),
              _DialogFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatefulWidget {
  final String icon, title, desc;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onGenerate;
  const _ReportCard({required this.icon, required this.title, required this.desc, required this.color, required this.gradient, required this.onGenerate});
  @override State<_ReportCard> createState() => _ReportCardState();
}
class _ReportCardState extends State<_ReportCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AETheme.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hovered ? widget.color.withValues(alpha: 0.3) : const Color(0x12070921)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.04), blurRadius: _hovered ? 24 : 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 20),
            Text(widget.title, style: AETheme.syne(size: 16, weight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(widget.desc, style: AETheme.syne(size: 13, color: AETheme.slate, weight: FontWeight.w400)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: widget.onGenerate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: widget.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Generate Report', textAlign: TextAlign.center, style: AETheme.syne(size: 13, color: Colors.white, weight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final String title;
  const _DialogHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        gradient: AETheme.darkGradient,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AETheme.fraunces(size: 16, color: Colors.white))),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 18), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _DialogFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x08070921)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('AlphaEdge Capital · Private & Confidential · ${DateTime.now().year}',
              style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
