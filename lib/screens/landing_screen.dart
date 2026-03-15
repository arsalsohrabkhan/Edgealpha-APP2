import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final narrow = w < 900;

    return Scaffold(
      backgroundColor: AETheme.bg,
      body: CustomScrollView(
        slivers: [
          // NAV
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xEAF7F5EF),
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: 66,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Color(0xEAF7F5EF),
                border: Border(bottom: BorderSide(color: Color(0x12070921))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  // Logo
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft, end: Alignment.topRight,
                        colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF818CF8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
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
                  if (!narrow) ...[
                    TextButton(onPressed: () {}, child: Text('Services', style: AETheme.syne(size: 12, color: AETheme.slate))),
                    TextButton(onPressed: () {}, child: Text('Platform', style: AETheme.syne(size: 12, color: AETheme.slate))),
                    TextButton(onPressed: () {}, child: Text('Transparency', style: AETheme.syne(size: 12, color: AETheme.slate))),
                    const SizedBox(width: 16),
                    // Markets Open pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0x14047857),
                        border: Border.all(color: const Color(0x35047857)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(color: AETheme.green2, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text('Markets Open', style: AETheme.syne(size: 10, color: AETheme.green, weight: FontWeight.w800, letterSpacing: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  // CTA Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AETheme.ink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    onPressed: () => context.go('/login'),
                    child: Text('Client Portal →', style: AETheme.syne(size: 12, color: Colors.white, weight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),

          // HERO
          SliverToBoxAdapter(
            child: Container(
              constraints: const BoxConstraints(minHeight: 600),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AETheme.ink, AETheme.ink2, Color(0xFF1E1B4B), AETheme.indigo],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(56, 80, 56, 80),
              child: narrow
                  ? _HeroContent()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: _HeroContent()),
                        const SizedBox(width: 60),
                        Expanded(flex: 4, child: _HeroDashCard()),
                      ],
                    ),
            ),
          ),

          // STATS BAND
          SliverToBoxAdapter(child: _StatsBand()),

          // FEATURES
          SliverToBoxAdapter(child: _FeaturesSection()),

          // CTA
          SliverToBoxAdapter(child: _CTASection()),

          // FOOTER
          SliverToBoxAdapter(child: _Footer()),
        ],
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0x1A4F46E5),
            border: Border.all(color: const Color(0x354F46E5)),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5, height: 5,
                decoration: const BoxDecoration(color: AETheme.indigo2, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'GLOBAL INVESTMENT MANAGEMENT · EST. 2024',
                style: AETheme.syne(size: 9, color: AETheme.indigo3, weight: FontWeight.w800, letterSpacing: 2),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 32),

        // Headline
        Text(
          'Capital\nthat\nworks harder.',
          style: AETheme.fraunces(
            size: 72,
            color: Colors.white,
            letterSpacing: -4,
            height: 0.88,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

        const SizedBox(height: 24),

        Text(
          'AlphaEdge Capital deploys institutional-grade strategies across crypto, equities, forex, and alternative assets — giving every client access to professional active management, complete transparency, and real-time oversight.',
          style: AETheme.syne(size: 14, color: const Color(0x80FFFFFF), weight: FontWeight.w400, letterSpacing: 0),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 36),

        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AETheme.indigo2,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => GoRouter.of(context).go('/login'),
              child: Text('Open Client Portal →', style: AETheme.syne(size: 13, color: Colors.white, weight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x30FFFFFF), width: 1.5),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: Text('Our Approach', style: AETheme.syne(size: 13, color: Colors.white, weight: FontWeight.w700)),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 52),

        // Proof numbers
        Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0x15FFFFFF))),
          ),
          padding: const EdgeInsets.only(top: 36),
          child: Row(
            children: [
              _ProofStat(value: r'$2.4B+', label: 'Capital Deployed', color: AETheme.indigo3),
              _ProofStat(value: '98K+',   label: 'Active Clients',    color: AETheme.red),
              _ProofStat(value: '15+ Yrs',label: 'Combined Exp.',     color: AETheme.green2),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
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
            Text(value, style: AETheme.fraunces(size: 32, color: color, letterSpacing: -1.5)),
            const SizedBox(height: 4),
            Text(label, style: AETheme.syne(size: 9, color: const Color(0x60FFFFFF), weight: FontWeight.w700)),
          ],
        ),
      );
}

class _HeroDashCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xD0FFFFFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Column(
        children: [
          // Title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: AETheme.darkGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                ...['#FF5F56', '#FEBC2E', '#27C93F'].map((c) => Container(
                  width: 10, height: 10,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(color: Color(int.parse(c.replaceFirst('#', '0xFF'))), shape: BoxShape.circle),
                )),
                const SizedBox(width: 8),
                Text('dashboard — live', style: AETheme.syne(size: 9, color: const Color(0x60FFFFFF), letterSpacing: 1.5)),
                const Spacer(),
                Row(children: [
                  Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Live', style: AETheme.syne(size: 9, color: Color(0xFF34D399), weight: FontWeight.w800, letterSpacing: 1)),
                ]),
              ],
            ),
          ),
          // Stats grid
          Row(
            children: [
              _MiniStat(label: 'Account Value', value: r'$284,500', color: AETheme.indigo2),
              _MiniStat(label: 'Return', value: '+13.8%', color: AETheme.green),
              _MiniStat(label: 'Win Rate', value: '76.9%', color: AETheme.amber),
              _MiniStat(label: 'Trades', value: '13', color: AETheme.ink),
            ],
          ),
          // Trades
          ...[ ['BTC/USD','LONG','+\$12,400',true], ['NVDA','LONG','+\$8,750',true], ['EUR/USD','SHORT','−\$3,200',false],
               ['Gold','LONG','+\$5,100',true],
          ].map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x08070921)))),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(t[0].toString(), style: AETheme.syne(size: 11, weight: FontWeight.w800))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: t[1] == 'LONG' ? const Color(0x14047857) : const Color(0x14DC2626),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(t[1].toString(), style: AETheme.syne(size: 7, color: (t[3] as bool) ? AETheme.green : AETheme.red, weight: FontWeight.w800)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t[2].toString(),
                    textAlign: TextAlign.right,
                    style: AETheme.syne(size: 11, color: (t[3] as bool) ? AETheme.green : AETheme.red, weight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ).animate().slideX(begin: 0.15).fadeIn(delay: 300.ms);
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0x08070921)), bottom: BorderSide(color: Color(0x08070921)))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AETheme.syne(size: 7, color: AETheme.muted, weight: FontWeight.w800, letterSpacing: 1.2)),
              const SizedBox(height: 5),
              Text(value, style: AETheme.fraunces(size: 16, color: color, letterSpacing: -0.5)),
            ],
          ),
        ),
      );
}

class _StatsBand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      {'num': r'$2.4B', 'tag': 'Capital Deployed',    'sub': 'Across all client accounts'},
      {'num': '74.2%',  'tag': 'Historical Win Rate',  'sub': 'Audited · trailing 12 months'},
      {'num': '98K+',   'tag': 'Active Clients',       'sub': 'Verified · globally managed'},
      {'num': '9+',     'tag': 'Asset Classes',        'sub': 'Crypto · Equities · Forex'},
    ];
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AETheme.indigo, AETheme.violet, Color(0xFF4C1D95)],
        ),
      ),
      child: Row(
        children: stats.map((s) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
            decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0x18FFFFFF)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['tag']!, style: AETheme.syne(size: 9, color: const Color(0x66FFFFFF), weight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(height: 14),
                Text(s['num']!, style: AETheme.fraunces(size: 52, color: Colors.white, letterSpacing: -3)),
                const SizedBox(height: 6),
                Text(s['sub']!, style: AETheme.syne(size: 11, color: const Color(0x74FFFFFF), weight: FontWeight.w400)),
              ],
            ),
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
      {'icon': '📈', 'title': 'Real-Time Portfolio Dashboard', 'body': 'Every client has live access to their account value, total return, and equity curve. No black boxes.', 'tag': 'Real-time'},
      {'icon': '📊', 'title': 'Multi-Asset Allocation', 'body': 'We actively allocate across Crypto, Equities, Forex, and Commodities with live exposure breakdowns.', 'tag': 'Analytics'},
      {'icon': '📄', 'title': 'Verified Account Reports', 'body': 'Account Summaries, Trade History, and Performance Reports generated on demand as professional PDFs.', 'tag': 'Export'},
      {'icon': '💬', 'title': 'Direct Advisor Access', 'body': 'Every client has a private, encrypted channel to their dedicated investment advisor.', 'tag': 'Comms'},
      {'icon': '⚡', 'title': 'Institutional Performance Metrics', 'body': 'Sharpe ratio, max drawdown, long/short split, per-asset P&L — the same metrics institutional funds report.', 'tag': 'Metrics'},
      {'icon': '🏛', 'title': 'Compliance & Oversight', 'body': 'Full portfolio-level oversight for every account — AUM breakdown, P&L attribution, win rates.', 'tag': 'Admin'},
    ];

    return Container(
      color: AETheme.bg,
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: AETheme.bg2,
              border: Border.all(color: const Color(0x12070921)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Our Approach', style: AETheme.syne(size: 10, color: AETheme.indigo2, weight: FontWeight.w800, letterSpacing: 2)),
          ),
          const SizedBox(height: 20),
          Text('Institutional strategy.\nFor everyone.', style: AETheme.fraunces(size: 56, letterSpacing: -2.5, height: 0.95)),
          const SizedBox(height: 18),
          Text(
            'We combine professional active management, quantitative research, and real-time risk controls across every asset class.',
            style: AETheme.syne(size: 14, color: AETheme.slate, weight: FontWeight.w400),
          ),
          const SizedBox(height: 70),
          Wrap(
            spacing: 16, runSpacing: 16,
            children: features.map((f) => SizedBox(
              width: (MediaQuery.of(context).size.width - 128 - 32) / 3,
              child: _FeatureCard(icon: f['icon']!, title: f['title']!, body: f['body']!, tag: f['tag']!),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final String icon, title, body, tag;
  const _FeatureCard({required this.icon, required this.title, required this.body, required this.tag});
  @override State<_FeatureCard> createState() => _FeatureCardState();
}
class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AETheme.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hovered ? const Color(0x284F46E5) : const Color(0x12070921)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovered ? 0.1 : 0.05),
              blurRadius: _hovered ? 32 : 16,
              offset: const Offset(0, _hovered ? 8 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: const Color(0x124F46E5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(widget.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 22),
            Text(widget.title, style: AETheme.syne(size: 16, weight: FontWeight.w800, letterSpacing: -0.3)),
            const SizedBox(height: 10),
            Text(widget.body, style: AETheme.syne(size: 13, color: AETheme.slate, weight: FontWeight.w400)),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x124F46E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(widget.tag, style: AETheme.syne(size: 8, color: AETheme.indigo2, weight: FontWeight.w800, letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CTASection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 120),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AETheme.ink, Color(0xFF1E1B4B), AETheme.indigo, AETheme.violet],
        ),
      ),
      child: Column(
        children: [
          Text('Your capital.\nIn expert hands.', textAlign: TextAlign.center,
              style: AETheme.fraunces(size: 80, color: Colors.white, letterSpacing: -4, height: 0.88)),
          const SizedBox(height: 28),
          Text(
            'Join thousands of clients who trust AlphaEdge Capital to actively manage and grow their wealth.',
            textAlign: TextAlign.center,
            style: AETheme.syne(size: 16, color: const Color(0x80FFFFFF), weight: FontWeight.w400),
          ),
          const SizedBox(height: 52),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AETheme.indigo2,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => context.go('/login'),
                child: Text('Open Client Portal →', style: AETheme.syne(size: 14, color: AETheme.indigo2, weight: FontWeight.w800)),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 38),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('AlphaEdge Capital', style: AETheme.fraunces(size: 18, color: const Color(0xD9FFFFFF))),
          Text('© 2026 AlphaEdge Capital · All rights reserved', style: AETheme.syne(size: 11, color: const Color(0x40FFFFFF), weight: FontWeight.w400)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x20FFFFFF)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('REGULATED · TRANSPARENT', style: AETheme.syne(size: 8, color: const Color(0x33FFFFFF), weight: FontWeight.w800, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}
