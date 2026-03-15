import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/client_model.dart';
import '../../theme/app_theme.dart';
import 'admin_screen.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AETheme.bg,
      body: Column(
        children: [
          const AdminTopBar(title: 'Compliance Reporting', subtitle: 'Generate verified reports for any client'),
          Expanded(
            child: StreamBuilder<List<Client>>(
              stream: context.read<FirestoreService>().streamAllClients(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AETheme.indigo2));
                }
                final clients = snap.data ?? [];
                if (clients.isEmpty) {
                  return Center(child: Text('No clients found.', style: AETheme.syne(size: 13, color: AETheme.muted)));
                }
                return _ReportsBody(clients: clients);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  final List<Client> clients;
  const _ReportsBody({required this.clients});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ALL CLIENTS', style: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 2)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: clients.map((c) {
              final cardW = (MediaQuery.of(context).size.width - 96) / 3;
              return SizedBox(
                width: cardW < 260 ? double.infinity : cardW,
                child: _ClientReportCard(client: c, fmt: fmt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ClientReportCard extends StatefulWidget {
  final Client client;
  final NumberFormat fmt;
  const _ClientReportCard({required this.client, required this.fmt});
  @override State<_ClientReportCard> createState() => _ClientReportCardState();
}

class _ClientReportCardState extends State<_ClientReportCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.client;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AETheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _hovered ? const Color(0x304F46E5) : const Color(0x10070921)),
          boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
            blurRadius: _hovered ? 20 : 8,
            offset: const Offset(0, 3),
          )],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(c.colorValue),
                  child: Text(c.initials, style: AETheme.syne(size: 12, color: Colors.white, weight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.fullName, style: AETheme.syne(size: 14, weight: FontWeight.w800)),
                      Text('${c.risk} · Joined ${c.joined}', style: AETheme.syne(size: 10, color: AETheme.muted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0x14047857), borderRadius: BorderRadius.circular(20)),
                  child: Text(c.status, style: AETheme.syne(size: 8, color: AETheme.green, weight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Key stats
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AETheme.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _StatRow('Capital',   widget.fmt.format(c.capital),  AETheme.muted),
                  _StatRow('AUM',       widget.fmt.format(c.aum),       AETheme.indigo2),
                  _StatRow('Total P&L', '${c.totalPnl >= 0 ? '+' : ''}${widget.fmt.format(c.totalPnl)}', c.totalPnl >= 0 ? AETheme.green : AETheme.red),
                  _StatRow('Return',    '${c.ret >= 0 ? '+' : ''}${c.ret}%', c.ret >= 0 ? AETheme.green : AETheme.red),
                  _StatRow('Win Rate',  '${c.winRate}%',   AETheme.amber),
                  _StatRow('Sharpe',    c.sharpe.toStringAsFixed(2), AETheme.indigo2),
                  _StatRow('Drawdown',  '${c.drawdown}%',  AETheme.red),
                  _StatRow('Trades',    '${c.trades.length}', AETheme.ink),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Report buttons
            Row(
              children: [
                Expanded(
                  child: _ReportBtn(
                    label: 'Account Summary',
                    icon: '📄',
                    color: AETheme.indigo2,
                    gradient: AETheme.indigoGradient,
                    onTap: () => _showAccountSummary(context, c),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReportBtn(
                    label: 'Trade History',
                    icon: '📊',
                    color: AETheme.green,
                    gradient: AETheme.greenGradient,
                    onTap: () => _showTradeHistory(context, c),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _ReportBtn(
              label: 'Full Performance Report',
              icon: '📈',
              color: AETheme.amber,
              gradient: AETheme.amberGradient,
              fullWidth: true,
              onTap: () => _showPerformanceReport(context, c),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSummary(BuildContext context, Client c) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    _showReportDialog(
      context: context,
      title: 'Account Summary — ${c.fullName}',
      subtitle: 'Generated ${_nowStr()}',
      rows: [
        ['Client',          c.fullName],
        ['Email',           c.email],
        ['Phone',           c.phone],
        ['Joined',          c.joined],
        ['Risk Profile',    c.risk],
        ['Status',          c.status],
        ['Initial Capital', fmt.format(c.capital)],
        ['Current AUM',     fmt.format(c.aum)],
        ['Total P&L',       '${c.totalPnl >= 0 ? '+' : ''}${fmt.format(c.totalPnl)}'],
        ['Total Return',    '${c.ret >= 0 ? '+' : ''}${c.ret}%'],
        ['Win Rate',        '${c.winRate}%'],
        ['Wins / Losses',   '${c.wins}W · ${c.losses}L'],
        ['Total Trades',    '${c.trades.length}'],
        ['Sharpe Ratio',    c.sharpe.toStringAsFixed(2)],
        ['Max Drawdown',    '${c.drawdown}%'],
      ],
    );
  }

  void _showPerformanceReport(BuildContext context, Client c) {
    _showReportDialog(
      context: context,
      title: 'Performance Report — ${c.fullName}',
      subtitle: 'Generated ${_nowStr()}',
      rows: [
        ['Sharpe Ratio',   c.sharpe.toStringAsFixed(2)],
        ['Max Drawdown',   '${c.drawdown}%'],
        ['Win Rate',       '${c.winRate}%'],
        ['Wins',           '${c.wins}'],
        ['Losses',         '${c.losses}'],
        ['Long Trades',    '${c.trades.where((t) => t.isLong).length}'],
        ['Short Trades',   '${c.trades.where((t) => !t.isLong).length}'],
        ['Best Trade',     '+${c.trades.map((t) => t.pct).fold(0.0, (a, b) => a > b ? a : b)}%'],
        ['Worst Trade',    '${c.trades.map((t) => t.pct).fold(0.0, (a, b) => a < b ? a : b)}%'],
        ...c.allocation.map((a) => ['\${a.label}', '\${a.pct}%']),
      ],
    );
  }

  void _showTradeHistory(BuildContext context, Client c) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 720,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogHeader(title: 'Trade History — ${c.fullName}', subtitle: 'Generated ${_nowStr()}'),
              SizedBox(
                height: 420,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AETheme.bg),
                    headingTextStyle: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1.5),
                    dataTextStyle: AETheme.syne(size: 12),
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('ASSET')),
                      DataColumn(label: Text('DIRECTION')),
                      DataColumn(label: Text('P&L'),    numeric: true),
                      DataColumn(label: Text('RETURN'), numeric: true),
                      DataColumn(label: Text('OPENED')),
                      DataColumn(label: Text('CLOSED')),
                    ],
                    rows: c.trades.map((t) => DataRow(cells: [
                      DataCell(Text(t.asset, style: AETheme.syne(size: 12, weight: FontWeight.w800))),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: t.isLong ? const Color(0x12047857) : const Color(0x12DC2626),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(t.isLong ? '▲ Long' : '▼ Short', style: AETheme.syne(size: 9, color: t.isLong ? AETheme.green : AETheme.red, weight: FontWeight.w700)),
                      )),
                      DataCell(Text('${t.pnl >= 0 ? '+' : '−'}${fmt.format(t.pnl.abs())}', style: AETheme.syne(size: 12, color: t.isWin ? AETheme.green : AETheme.red, weight: FontWeight.w700))),
                      DataCell(Text('${t.pct >= 0 ? '+' : ''}${t.pct}%', style: AETheme.syne(size: 12, color: t.pct >= 0 ? AETheme.green : AETheme.red, weight: FontWeight.w700))),
                      DataCell(Text(t.openDate,  style: AETheme.syne(size: 10, color: AETheme.muted))),
                      DataCell(Text(t.closeDate, style: AETheme.syne(size: 10, color: AETheme.muted))),
                    ])).toList(),
                  ),
                ),
              ),
              _DialogFooter(clientName: c.fullName),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<List<String>> rows,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogHeader(title: title, subtitle: subtitle),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 480),
                child: SingleChildScrollView(
                  child: Column(
                    children: rows.map((r) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x08070921)))),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(r[0].toUpperCase(), style: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 0.8)),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(r[1], style: AETheme.syne(size: 13, weight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              _DialogFooter(clientName: title),
            ],
          ),
        ),
      ),
    );
  }

  String _nowStr() {
    final d = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _StatRow extends StatelessWidget {
  final String label, value;
  final Color  color;
  const _StatRow(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AETheme.syne(size: 11, color: AETheme.muted, weight: FontWeight.w600)),
        Text(value, style: AETheme.syne(size: 12, color: color, weight: FontWeight.w800)),
      ],
    ),
  );
}

class _ReportBtn extends StatelessWidget {
  final String label, icon;
  final Color  color;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ReportBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: AETheme.syne(size: 11, color: Colors.white, weight: FontWeight.w800)),
        ],
      ),
    ),
  );
}

class _DialogHeader extends StatelessWidget {
  final String title, subtitle;
  const _DialogHeader({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(24, 18, 16, 18),
    decoration: const BoxDecoration(
      gradient: AETheme.darkGradient,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AETheme.fraunces(size: 16, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: AETheme.syne(size: 10, color: const Color(0x80FFFFFF), weight: FontWeight.w400)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

class _DialogFooter extends StatelessWidget {
  final String clientName;
  const _DialogFooter({required this.clientName});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    decoration: const BoxDecoration(
      color: AETheme.bg,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      border: Border(top: BorderSide(color: Color(0x08070921))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('AlphaEdge Capital · Confidential', style: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w600)),
        Text('© ${DateTime.now().year}', style: AETheme.syne(size: 9, color: AETheme.muted)),
      ],
    ),
  );
}
