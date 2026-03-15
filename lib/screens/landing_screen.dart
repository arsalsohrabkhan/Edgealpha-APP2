import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AETheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xF0F7F5EF),
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 60,
            title: Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    gradient: AETheme.indigoGradient,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.show_chart, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(
                    style: AETheme.fraunces(size: 18, color: AETheme.ink),
                    children: const [
                      TextSpan(text: 'Alpha'),
                      TextSpan(text: 'Edge', style: TextStyle(color: AETheme.indigo2)),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: AETheme.ink,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text('Client Portal →',
                        style: AETheme.syne(size: 12, color: Colors.white, weight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(child: _HeroSection()),
          SliverToBoxAdapter(child: _StatsBand()),
          SliverToBoxAdapter(child: _FeaturesSection()),
          SliverToBoxAdapter(child: _CTASection()),
          SliverToBoxAdapter(child: _Footer()),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AETheme.ink, AETheme.ink2, Color(0xFF1E1B4B), AETheme.indigo],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0x1A4F46E5),
              border: Border.all(color: const Color(0x354F46E5)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 5, height: 5,
                    decoration: const BoxDecoration(color: AETheme.indigo2, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text('GLOBAL INVESTMENT MANAGEMENT · EST. 2024',
                    style: AETheme.syne(size: 8, color: AETheme.indigo3,
                        weight: FontWeight.w800, letterSpacing: 1.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 28),
          Text('Capital\nthat\nworks harder.',
            style: AETheme.fraunces(size: 56, color: Colors.white,
                letterSpacing: -2, height: 0.92),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 20),
          Text(
            'AlphaEdge Capital deploys institutional-grade strategies across crypto, equities, forex, and alternative assets — giving every client access to professional active management.',
            style: AETheme.syne(size: 13, color: const Color(0x99FFFFFF), weight: FontWeight.w400),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () => context.go('/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: AETheme.indigoGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                        color: AETheme.indigo2.withValues(alpha: 0.4),
                        blurRadius: 20, offset: const Offset(0, 6))],
                  ),
                  child: Text('Open Client Portal →',
                    textAlign: TextAlign.center,
                    style: AETheme.syne(size: 14, color: Colors.white, weight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x40FFFFFF)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Our Approach',
                  textAlign: TextAlign.center,
                  style: AETheme.syne(size: 14, color: Colors.white, weight: FontWeight.w700),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 40),
          Container(
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x25FFFFFF)))),
            padding: const EdgeInsets.only(top: 28),
            child: Row(
              children: [
                _ProofStat(value: r'$2.4B+', label: 'Capital Deployed', color: AETheme.indigo3),
                _ProofStat(value: '98K+',    label: 'Active Clients',   color: AETheme.red2),
                _ProofStat(value: '15+ Yrs', label: 'Experience',       color: AETheme.green2),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _ProofStat extends StatelessWidget {
  final String value, label;
  final Color color;
  const _ProofStat({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AETheme.fraunces(size: 22, color: color, letterSpacing: -1),
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(label, style: AETheme.syne(size: 9, color: const Color(0x70FFFFFF), weight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ],
    ),
  );
}

class _StatsBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'num': r'$2.4B', 'tag': 'Capital Deployed',  'sub': 'Across all accounts'},
      {'num': '74.2%',  'tag': 'Win Rate',           'sub': 'Audited · 12 months'},
      {'num': '98K+',   'tag': 'Active Clients',     'sub': 'Globally managed'},
      {'num': '9+',     'tag': 'Asset Classes',      'sub': 'Crypto · Equities · Forex'},
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AETheme.indigo, AETheme.violet, Color(0xFF4C1D95)],
        ),
      ),
      child: Column(
        children: stats.map((s) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x20FFFFFF)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['tag']!, style: AETheme.syne(size: 10, color: const Color(0x80FFFFFF),
                        weight: FontWeight.w800, letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(s['sub']!, style: AETheme.syne(size: 11, color: const Color(0x60FFFFFF),
                        weight: FontWeight.w400)),
                  ],
                ),
              ),
              Text(s['num']!, style: AETheme.fraunces(size: 36, color: Colors.white, letterSpacing: -2)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': '📈', 'title': 'Real-Time Dashboard',     'body': 'Live account value, equity curve, and total return. No black boxes.', 'tag': 'Real-time'},
      {'icon': '📊', 'title': 'Multi-Asset Allocation',  'body': 'Crypto, Equities, Forex, and Commodities with live exposure breakdowns.', 'tag': 'Analytics'},
      {'icon': '📄', 'title': 'Verified Reports',        'body': 'Account Summaries, Trade History, and Performance Reports on demand.', 'tag': 'Export'},
      {'icon': '💬', 'title': 'Direct Advisor Access',   'body': 'Private encrypted channel to your dedicated investment advisor.', 'tag': 'Comms'},
      {'icon': '⚡', 'title': 'Performance Metrics',     'body': 'Sharpe ratio, max drawdown, long/short split, per-asset P&L.', 'tag': 'Metrics'},
      {'icon': '🏛',  'title': 'Compliance & Oversight', 'body': 'Full portfolio-level oversight — AUM, P&L attribution, win rates.', 'tag': 'Admin'},
    ];
    return Container(
      color: AETheme.bg,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AETheme.bg2,
              border: Border.all(color: const Color(0x12070921)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Our Approach', style: AETheme.syne(size: 10, color: AETheme.indigo2,
                weight: FontWeight.w800, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 16),
          Text('Institutional strategy.\nFor everyone.',
              style: AETheme.fraunces(size: 36, letterSpacing: -1.5, height: 1.0)),
          const SizedBox(height: 14),
          Text('Professional active management, quantitative research, and real-time risk controls across every asset class.',
              style: AETheme.syne(size: 13, color: AETheme.slate, weight: FontWeight.w400)),
          const SizedBox(height: 36),
          ...features.map((f) => _FeatureCard(
              icon: f['icon']!, title: f['title']!, body: f['body']!, tag: f['tag']!)),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon, title, body, tag;
  const _FeatureCard({required this.icon, required this.title, required this.body, required this.tag});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AETheme.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x10070921)),
        boxShadow: const [BoxShadow(color: Color(0x07070921), blurRadius: 12, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: const Color(0x104F46E5), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AETheme.syne(size: 14, weight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(body, style: AETheme.syne(size: 12, color: AETheme.slate, weight: FontWeight.w400)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0x104F46E5), borderRadius: BorderRadius.circular(20)),
                  child: Text(tag, style: AETheme.syne(size: 9, color: AETheme.indigo2,
                      weight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 72),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AETheme.ink, Color(0xFF1E1B4B), AETheme.indigo, AETheme.violet],
        ),
      ),
      child: Column(
        children: [
          Text('Your capital.\nIn expert hands.',
            textAlign: TextAlign.center,
            style: AETheme.fraunces(size: 42, color: Colors.white, letterSpacing: -2, height: 0.95),
          ),
          const SizedBox(height: 20),
          Text('Join thousands of clients who trust AlphaEdge Capital to actively manage and grow their wealth.',
            textAlign: TextAlign.center,
            style: AETheme.syne(size: 13, color: const Color(0x80FFFFFF), weight: FontWeight.w400),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 20)],
              ),
              child: Text('Open Client Portal →',
                textAlign: TextAlign.center,
                style: AETheme.syne(size: 14, color: AETheme.indigo2, weight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AETheme.ink2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AlphaEdge Capital',
              style: AETheme.fraunces(size: 18, color: const Color(0xD9FFFFFF))),
          const SizedBox(height: 8),
          Text('© 2026 AlphaEdge Capital · All rights reserved',
              style: AETheme.syne(size: 11, color: const Color(0x50FFFFFF), weight: FontWeight.w400)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x25FFFFFF)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('REGULATED · TRANSPARENT',
                style: AETheme.syne(size: 8, color: const Color(0x50FFFFFF),
                    weight: FontWeight.w800, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}
