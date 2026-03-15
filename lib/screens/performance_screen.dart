import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/client_model.dart';
import '../theme/app_theme.dart';
import '../widgets/sidebar.dart';
import '../widgets/charts.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final C = context.watch<AuthService>().client;
    if (C == null) return const SizedBox();
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return ClientScaffold(
      active: 'performance',
      title: 'Performance Analysis',
      subtitle: 'Sharpe, drawdown, attribution & more',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _MetricCard(label: 'Sharpe Ratio', value: C.sharpe.toStringAsFixed(2), note: 'Annualised', color: AETheme.indigo2, gradient: AETheme.indigoGradient),
                _MetricCard(label: 'Max Drawdown', value: '${C.drawdown}%', note: 'Peak-to-trough', color: AETheme.red, gradient: LinearGradient(colors: [AETheme.red, AETheme.red2])),
                _MetricCard(label: 'Win Rate', value: '${C.winRate}%', note: '${C.wins}W · ${C.losses}L', color: AETheme.green, gradient: AETheme.greenGradient),
                _MetricCard(label: 'Total Return', value: '${C.ret >= 0 ? '+' : ''}${C.ret}%', note: 'From ${fmt.format(C.capital)}', color: AETheme.amber, gradient: AETheme.amberGradient),
              ],
            ),
            const SizedBox(height: 16),
            _CardWrap(
              title: 'Equity Growth Curve',
              sub: 'Account value over all trades',
              tag: 'Equity',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EquityLineChart(equity: C.equity, months: C.months, height: 200),
              ),
            ),
            const SizedBox(height: 14),
            _CardWrap(
              title: 'Asset Allocation',
              sub: 'By P&L contribution',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AllocationDonut(allocation: C.allocation, winRate: C.winRate, colorValue: C.colorValue, size: 150),
              ),
            ),
            const SizedBox(height: 14),
            _CardWrap(
              title: 'Long vs Short',
              sub: 'By trade count and P&L',
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _LongShortBar(
                  longCount:  C.trades.where((t) => t.isLong).length,
                  shortCount: C.trades.where((t) => !t.isLong).length,
                  longPnl:    C.trades.where((t) => t.isLong).fold(0.0, (s, t) => s + t.pnl),
                  shortPnl:   C.trades.where((t) => !t.isLong).fold(0.0, (s, t) => s + t.pnl),
                  fmt: fmt,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _CardWrap(
              title: 'Per-Asset P&L',
              sub: 'All closed trades grouped by asset',
              child: Column(children: _buildPerAsset(C, fmt)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPerAsset(Client C, NumberFormat fmt) {
    final Map<String, double> byAsset = {};
    for (final t in C.trades) {
      byAsset[t.asset] = (byAsset[t.asset] ?? 0) + t.pnl;
    }
    final sorted = byAsset.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x08070921)))),
      child: Row(
        children: [
          Expanded(child: Text(e.key, style: AETheme.syne(size: 12, weight: FontWeight.w800))),
          Text(
            '${e.value >= 0 ? '+' : '−'}${fmt.format(e.value.abs())}',
            style: AETheme.syne(size: 12, color: e.value >= 0 ? AETheme.green : AETheme.red, weight: FontWeight.w700),
          ),
        ],
      ),
    )).toList();
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, note;
  final Color color;
  final LinearGradient gradient;
  const _MetricCard({required this.label, required this.value, required this.note, required this.color, required this.gradient});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AETheme.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x12070921)),
        boxShadow: const [BoxShadow(color: Color(0x08070921), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: AETheme.syne(size: 8, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (b) => gradient.createShader(b),
            child: Text(value, style: AETheme.fraunces(size: 28, color: Colors.white, letterSpacing: -1.5)),
          ),
          const SizedBox(height: 4),
          Text(note, style: AETheme.syne(size: 9, color: AETheme.muted, weight: FontWeight.w500),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _CardWrap extends StatelessWidget {
  final String title, sub;
  final String? tag;
  final Widget child;
  const _CardWrap({required this.title, required this.sub, this.tag, required this.child});
  @override
  Widget build(BuildContext context) {
    return AECard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x08070921)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AETheme.syne(size: 13, weight: FontWeight.w800), overflow: TextOverflow.ellipsis),
                    Text(sub, style: AETheme.syne(size: 10, color: AETheme.muted, weight: FontWeight.w400)),
                  ],
                )),
                if (tag != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0x124F46E5), borderRadius: BorderRadius.circular(20)),
                    child: Text(tag!, style: AETheme.syne(size: 8, color: AETheme.indigo2, weight: FontWeight.w800, letterSpacing: 1.5)),
                  ),
                ],
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _LongShortBar extends StatelessWidget {
  final int longCount, shortCount;
  final double longPnl, shortPnl;
  final NumberFormat fmt;
  const _LongShortBar({required this.longCount, required this.shortCount,
    required this.longPnl, required this.shortPnl, required this.fmt});
  @override
  Widget build(BuildContext context) {
    final total = longCount + shortCount;
    final longFrac  = total > 0 ? longCount  / total : 0.5;
    final shortFrac = total > 0 ? shortCount / total : 0.5;
    return Column(
      children: [
        Row(children: [
          Expanded(child: _SideStat(label: 'Long',  count: longCount,  pnl: longPnl,  fmt: fmt, color: AETheme.green, isLeft: true)),
          Expanded(child: _SideStat(label: 'Short', count: shortCount, pnl: shortPnl, fmt: fmt, color: AETheme.red,   isLeft: false)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(children: [
            Flexible(flex: (longFrac * 100).round(),  child: Container(height: 8, color: AETheme.green)),
            Flexible(flex: (shortFrac * 100).round(), child: Container(height: 8, color: AETheme.red)),
          ]),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(longFrac * 100).round()}% Long',   style: AETheme.syne(size: 10, color: AETheme.green, weight: FontWeight.w700)),
          Text('${(shortFrac * 100).round()}% Short', style: AETheme.syne(size: 10, color: AETheme.red,   weight: FontWeight.w700)),
        ]),
      ],
    );
  }
}

class _SideStat extends StatelessWidget {
  final String label; final int count; final double pnl;
  final NumberFormat fmt; final Color color; final bool isLeft;
  const _SideStat({required this.label, required this.count, required this.pnl,
    required this.fmt, required this.color, required this.isLeft});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
    children: [
      Text(label, style: AETheme.syne(size: 11, color: color, weight: FontWeight.w800)),
      Text('$count trades', style: AETheme.syne(size: 10, color: AETheme.muted)),
      Text('${pnl >= 0 ? '+' : '−'}${fmt.format(pnl.abs())}', style: AETheme.syne(size: 14, color: color, weight: FontWeight.w700)),
    ],
  );
}
