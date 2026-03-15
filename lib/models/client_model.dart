import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Trade Model ────────────────────────────────────────────
class Trade {
  final String id;
  final String asset;
  final String direction; // 'long' | 'short'
  final double pnl;
  final double pct;
  final String openDate;
  final String closeDate;

  const Trade({
    required this.id,
    required this.asset,
    required this.direction,
    required this.pnl,
    required this.pct,
    required this.openDate,
    required this.closeDate,
  });

  bool get isLong => direction == 'long';
  bool get isWin  => pnl >= 0;

  factory Trade.fromMap(Map<String, dynamic> m) => Trade(
        id:        m['id']        ?? '',
        asset:     m['asset']     ?? '',
        direction: m['direction'] ?? 'long',
        pnl:       (m['pnl']     ?? 0).toDouble(),
        pct:       (m['pct']     ?? 0).toDouble(),
        openDate:  m['openDate']  ?? '',
        closeDate: m['closeDate'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id':        id,
        'asset':     asset,
        'direction': direction,
        'pnl':       pnl,
        'pct':       pct,
        'openDate':  openDate,
        'closeDate': closeDate,
      };
}

// ── Message Model ──────────────────────────────────────────
class Message {
  final String id;
  final String from; // 'client' | 'admin'
  final String text;
  final String time;

  const Message({
    required this.id,
    required this.from,
    required this.text,
    required this.time,
  });

  bool get isAdmin  => from == 'admin';
  bool get isClient => from == 'client';

  factory Message.fromMap(Map<String, dynamic> m) => Message(
        id:   m['id']   ?? '',
        from: m['from'] ?? 'admin',
        text: m['text'] ?? '',
        time: m['time'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id':   id,
        'from': from,
        'text': text,
        'time': time,
      };
}

// ── Allocation Slice ───────────────────────────────────────
class AllocationSlice {
  final String label;
  final int pct;
  final int colorValue;

  const AllocationSlice({
    required this.label,
    required this.pct,
    required this.colorValue,
  });
}

// ── Client Model (raw) ─────────────────────────────────────
class Client {
  final int id;
  final String first;
  final String last;
  final String email;
  final String password;
  final String phone;
  final String initials;
  final int colorValue;
  final String status;
  final String risk;
  final String joined;
  final double capital;
  final List<Trade>   trades;
  final List<Message> messages;

  // computed
  final double aum;
  final double totalPnl;
  final double ret;
  final int    winRate;
  final int    wins;
  final int    losses;
  final double drawdown;
  final double sharpe;
  final List<AllocationSlice> allocation;
  final List<double> equity;
  final List<String> months;

  const Client({
    required this.id,
    required this.first,
    required this.last,
    required this.email,
    required this.password,
    required this.phone,
    required this.initials,
    required this.colorValue,
    required this.status,
    required this.risk,
    required this.joined,
    required this.capital,
    required this.trades,
    required this.messages,
    required this.aum,
    required this.totalPnl,
    required this.ret,
    required this.winRate,
    required this.wins,
    required this.losses,
    required this.drawdown,
    required this.sharpe,
    required this.allocation,
    required this.equity,
    required this.months,
  });

  String get fullName => '$first $last';

  factory Client.fromFirestore(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;

    final tradeList = (m['trades'] as List? ?? [])
        .map((t) => Trade.fromMap(Map<String, dynamic>.from(t)))
        .toList();
    final msgList = (m['messages'] as List? ?? [])
        .map((msg) => Message.fromMap(Map<String, dynamic>.from(msg)))
        .toList();

    return _enrich(
      id:       int.tryParse(doc.id) ?? 0,
      first:    m['first']    ?? '',
      last:     m['last']     ?? '',
      email:    m['email']    ?? '',
      password: m['password'] ?? '',
      phone:    m['phone']    ?? '',
      initials: m['initials'] ?? '',
      colorHex: m['color']    ?? '#4F46E5',
      status:   m['status']   ?? 'Active',
      risk:     m['risk']     ?? 'Moderate',
      joined:   m['joined']   ?? '',
      capital:  (m['capital'] ?? 0).toDouble(),
      trades:   tradeList,
      messages: msgList,
    );
  }

  // Mirror of enrichClient() from clients-data.js
  static Client _enrich({
    required int id,
    required String first,
    required String last,
    required String email,
    required String password,
    required String phone,
    required String initials,
    required String colorHex,
    required String status,
    required String risk,
    required String joined,
    required double capital,
    required List<Trade>   trades,
    required List<Message> messages,
  }) {
    final totalPnl = trades.fold(0.0, (s, t) => s + t.pnl);
    final wins     = trades.where((t) => t.pnl > 0).length;
    final losses   = trades.where((t) => t.pnl < 0).length;
    final winRate  = trades.isNotEmpty ? ((wins / trades.length) * 100).round() : 0;
    final totalRet = capital > 0 ? double.parse(((totalPnl / capital) * 100).toStringAsFixed(1)) : 0.0;
    final aum      = capital + totalPnl;

    double worstPnl = 0;
    for (final t in trades) { if (t.pnl < worstPnl) worstPnl = t.pnl; }
    final drawdown = capital > 0 ? double.parse(((worstPnl / capital) * 100).toStringAsFixed(1)) : 0.0;

    double sharpe = 0;
    if (trades.length > 1) {
      final avg = totalPnl / trades.length;
      final variance = trades.fold(0.0, (s, t) => s + pow(t.pnl - avg, 2)) / trades.length;
      final stddev = sqrt(variance);
      if (stddev > 0) sharpe = double.parse(((avg / stddev) * sqrt(12)).toStringAsFixed(2)).abs();
    }

    // Allocation
    final Map<String, double> assetTotals = {};
    for (final t in trades) {
      final cat = _assetCategory(t.asset);
      assetTotals[cat] = (assetTotals[cat] ?? 0) + t.pnl.abs();
    }
    final totalAbs = assetTotals.values.fold(0.0, (s, v) => s + v);
    const colorMap = {
      'Crypto':      0xFFF0A500,
      'Equities':    0xFF818CF8,
      'Forex':       0xFF22C55E,
      'Commodities': 0xFF38BDF8,
      'Other':       0xFFF472B6,
    };
    final allocation = assetTotals.entries.map((e) => AllocationSlice(
      label:      e.key,
      pct:        totalAbs > 0 ? ((e.value / totalAbs) * 100).round() : 0,
      colorValue: colorMap[e.key] ?? 0xFF888888,
    )).toList()
      ..sort((a, b) => b.pct.compareTo(a.pct));

    // Equity curve
    final step = max(1, (trades.length / 8).floor());
    final equity = [capital];
    var running = capital;
    for (var i = 0; i < trades.length; i++) {
      running += trades[i].pnl;
      if (i % step == step - 1 || i == trades.length - 1) equity.add(running);
    }
    if (equity.length < 2) equity.add(running);

    final List<String> months = trades.isNotEmpty
        ? [trades.first.openDate.split(',').first, ...trades
            .whereIndexed((i, _) => i % step == step - 1 || i == trades.length - 1)
            .map((t) => t.closeDate.split(',').first)]
        : ['Start', 'Now'];

    // parse hex color
    int colorVal = 0xFF4F46E5;
    try {
      colorVal = int.parse(colorHex.replaceFirst('#', '0xFF'));
    } catch (_) {}

    return Client(
      id: id, first: first, last: last, email: email,
      password: password, phone: phone, initials: initials,
      colorValue: colorVal, status: status, risk: risk,
      joined: joined, capital: capital, trades: trades, messages: messages,
      aum: aum, totalPnl: totalPnl, ret: totalRet,
      winRate: winRate, wins: wins, losses: losses,
      drawdown: drawdown, sharpe: sharpe,
      allocation: allocation.isEmpty
          ? [const AllocationSlice(label: 'Cash', pct: 100, colorValue: 0xFF555555)]
          : allocation,
      equity: equity, months: months,
    );
  }

  static String _assetCategory(String asset) {
    final a = asset.toUpperCase();
    const crypto = ['BTC','ETH','SOL','BNB','ADA','XRP'];
    const forex  = ['EUR/USD','GBP/USD','USD/JPY','AUD/USD','USD/CAD'];
    const commod = ['GOLD','XAU/USD','SILVER','CRUDE OIL','PLATINUM','COPPER'];
    if (crypto.contains(a)) return 'Crypto';
    if (forex.contains(a))  return 'Forex';
    if (commod.contains(a)) return 'Commodities';
    if (a.contains('USD') && a.contains('/')) return 'Forex';
    return 'Equities';
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<E> whereIndexed(bool Function(int index, E element) test) sync* {
    var i = 0;
    for (final e in this) {
      if (test(i, e)) yield e;
      i++;
    }
  }
}
