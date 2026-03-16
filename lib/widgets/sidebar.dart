import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

// ── Sidebar (desktop only) ────────────────────────────────
class AESidebar extends StatelessWidget {
  final String active;
  const AESidebar({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final client = context.watch<AuthService>().client;
    final navItems = [
      _N('dashboard',   Icons.dashboard_rounded,       'Dashboard'),
      _N('mytrades',    Icons.candlestick_chart_rounded,'My Trades'),
      _N('performance', Icons.trending_up_rounded,      'Performance'),
      _N('reports',     Icons.description_rounded,      'Reports'),
      _N('messages',    Icons.chat_bubble_rounded,      'Messages'),
    ];

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AETheme.ink, AETheme.ink2],
        ),
      ),
      child: Column(children: [
        // Logo
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x12FFFFFF)))),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: AETheme.indigoGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(text: TextSpan(
                style: AETheme.fraunces(size: 16, color: Colors.white),
                children: const [
                  TextSpan(text: 'Alpha'),
                  TextSpan(text: 'Edge', style: TextStyle(color: AETheme.indigo3)),
                ],
              )),
              Text('CAPITAL', style: AETheme.syne(
                  size: 7, color: const Color(0x50FFFFFF),
                  weight: FontWeight.w800, letterSpacing: 2)),
            ]),
          ]),
        ),
        // Nav
        Expanded(child: ListView(padding: const EdgeInsets.only(top: 12), children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Text('MY ACCOUNT', style: AETheme.syne(
                size: 8, color: const Color(0x40FFFFFF),
                weight: FontWeight.w800, letterSpacing: 2)),
          ),
          ...navItems.map((n) => _SidebarTile(item: n, active: active == n.key)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Text('SESSION', style: AETheme.syne(
                size: 8, color: const Color(0x40FFFFFF),
                weight: FontWeight.w800, letterSpacing: 2)),
          ),
          _SidebarTile(
            item: _N('signout', Icons.logout_rounded, 'Sign Out'),
            active: false,
            onTap: () { context.read<AuthService>().logout(); context.go('/login'); },
          ),
        ])),
        // User
        if (client != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x12FFFFFF)))),
            child: Row(children: [
              CircleAvatar(
                radius: 18, backgroundColor: Color(client.colorValue),
                child: Text(client.initials, style: AETheme.syne(
                    size: 11, color: Colors.white, weight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(client.fullName, style: AETheme.syne(
                    size: 12, color: const Color(0xD9FFFFFF), weight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
                Text('Private Client', style: AETheme.syne(
                    size: 9, color: const Color(0x50FFFFFF))),
              ])),
            ]),
          ),
      ]),
    );
  }
}

class _N { final String key; final IconData icon; final String label;
  const _N(this.key, this.icon, this.label); }

class _SidebarTile extends StatelessWidget {
  final _N item; final bool active; final VoidCallback? onTap;
  const _SidebarTile({required this.item, required this.active, this.onTap});
  @override
  Widget build(BuildContext context) {
    final routes = {
      'dashboard': '/dashboard', 'mytrades': '/trades',
      'performance': '/performance', 'reports': '/reports', 'messages': '/messages',
    };
    return GestureDetector(
      onTap: onTap ?? () => context.go(routes[item.key] ?? '/dashboard'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0x1A4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? const Color(0x304F46E5) : Colors.transparent),
        ),
        child: Row(children: [
          Icon(item.icon, size: 18,
              color: active ? AETheme.indigo3 : const Color(0x60FFFFFF)),
          const SizedBox(width: 10),
          Text(item.label, style: AETheme.syne(
              size: 13, weight: FontWeight.w700,
              color: active ? Colors.white : const Color(0x70FFFFFF))),
        ]),
      ),
    );
  }
}

// ── Bottom Nav Bar (mobile) ───────────────────────────────
class AEBottomNav extends StatelessWidget {
  final String active;
  const AEBottomNav({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final items = [
      _N('dashboard',   Icons.dashboard_rounded,        'Home'),
      _N('mytrades',    Icons.candlestick_chart_rounded, 'Trades'),
      _N('performance', Icons.trending_up_rounded,       'Stats'),
      _N('reports',     Icons.description_rounded,       'Reports'),
      _N('messages',    Icons.chat_bubble_rounded,       'Chat'),
    ];
    final routes = ['/dashboard','/trades','/performance','/reports','/messages'];

    return Container(
      decoration: BoxDecoration(
        color: AETheme.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = active == items[i].key;
              return GestureDetector(
                onTap: () => context.go(routes[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0x124F46E5) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(items[i].icon, size: 22,
                        color: isActive ? AETheme.indigo2 : AETheme.muted),
                    const SizedBox(height: 3),
                    Text(items[i].label, style: AETheme.syne(
                        size: 9, weight: FontWeight.w700,
                        color: isActive ? AETheme.indigo2 : AETheme.muted)),
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Client Scaffold ───────────────────────────────────────
class ClientScaffold extends StatelessWidget {
  final String active, title, subtitle;
  final Widget body;
  const ClientScaffold({
    super.key, required this.active, required this.title,
    required this.subtitle, required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: AETheme.bg,
      appBar: narrow ? AppBar(
        backgroundColor: AETheme.white,
        elevation: 0,
        leading: Builder(builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AETheme.ink, size: 24),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        title: Text(title.split('—').last.trim(),
            style: AETheme.fraunces(size: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x14047857),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                  decoration: const BoxDecoration(
                      color: AETheme.green2, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text('LIVE', style: AETheme.syne(
                  size: 9, color: AETheme.green, weight: FontWeight.w800, letterSpacing: 1.5)),
            ]),
          ),
        ],
      ) : null,
      drawer: narrow ? Drawer(child: AESidebar(active: active)) : null,
      body: Row(children: [
        if (!narrow) AESidebar(active: active),
        Expanded(child: Column(children: [
          if (!narrow) _TopBar(title: title, subtitle: subtitle),
          Expanded(child: body),
        ])),
      ]),
      bottomNavigationBar: narrow ? AEBottomNav(active: active) : null,
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title, subtitle;
  const _TopBar({required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const wd = ['','Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    const mo = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: AETheme.white,
        border: Border(bottom: BorderSide(color: Color(0x0F070921))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(children: [
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AETheme.fraunces(size: 16)),
            Text(subtitle, style: AETheme.syne(
                size: 11, color: AETheme.muted, weight: FontWeight.w400)),
          ],
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AETheme.bg2, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x0F070921)),
          ),
          child: Text('${wd[now.weekday]}, ${mo[now.month]} ${now.day}',
              style: AETheme.syne(size: 11, color: AETheme.muted, weight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
