import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/client_model.dart';
import '../theme/app_theme.dart';

class AESidebar extends StatelessWidget {
  final String active; // 'dashboard' | 'trades' | 'performance' | 'reports' | 'messages'

  const AESidebar({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final auth   = context.watch<AuthService>();
    final client = auth.client;

    final navItems = [
      _NavItem(icon: '▦',  label: 'Dashboard',   route: '/dashboard'),
      _NavItem(icon: '📊', label: 'My Trades',    route: '/trades'),
      _NavItem(icon: '↗',  label: 'Performance',  route: '/performance'),
      _NavItem(icon: '⊞',  label: 'Reports',      route: '/reports'),
      _NavItem(icon: '✉',  label: 'Messages',     route: '/messages'),
    ];

    return Container(
      width: 240,
      color: AETheme.ink,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0x10FFFFFF))),
            ),
            child: Row(
              children: [
                _LogoMark(),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: AETheme.fraunces(size: 17, color: Colors.white),
                        children: const [
                          TextSpan(text: 'Alpha'),
                          TextSpan(
                            text: 'Edge',
                            style: TextStyle(color: Color(0xFF818CF8)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'CAPITAL',
                      style: AETheme.syne(
                        size: 7.5,
                        color: const Color(0x48FFFFFF),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Nav section label
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              children: [
                _SectionLabel('My Account'),
                ...navItems.map((item) => _NavTile(
                      item:   item,
                      active: active == item.label.toLowerCase().replaceAll(' ', ''),
                    )),
                _SectionLabel('Session'),
                _NavTile(
                  item: _NavItem(icon: '⬡', label: 'Sign Out', route: '/login'),
                  active: false,
                  onTap: () {
                    context.read<AuthService>().logout();
                    context.go('/login');
                  },
                ),
              ],
            ),
          ),

          // User bottom
          if (client != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x10FFFFFF))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(client.colorValue),
                    child: Text(
                      client.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.fullName,
                        style: AETheme.syne(size: 12, color: const Color(0xCCFFFFFF)),
                      ),
                      Text(
                        'Private Client',
                        style: AETheme.syne(size: 9, color: const Color(0x48FFFFFF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF818CF8)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.show_chart, color: Colors.white, size: 20),
    );
  }
}

class _NavItem {
  final String icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final bool     active;
  final VoidCallback? onTap;

  const _NavTile({required this.item, required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.go(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0x1F4F46E5) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? const Color(0xFF4F46E5) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                item.icon,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? Colors.white : const Color(0x60FFFFFF),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              item.label,
              style: AETheme.syne(
                size: 12,
                color: active ? Colors.white : const Color(0x60FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Text(
        label.toUpperCase(),
        style: AETheme.syne(
          size: 8,
          color: const Color(0x30FFFFFF),
          letterSpacing: 2,
        ),
      ),
    );
  }
}

// ── Top bar reused across client screens ──────────────────
class AETopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;

  const AETopBar({super.key, required this.title, required this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = _weekday(now.weekday) + ', '
        + _month(now.month) + ' ${now.day}, ${now.year}';

    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xF7F7F5EF),
        border: Border(bottom: BorderSide(color: Color(0x14070921))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AETheme.fraunces(size: 17)),
              Text(subtitle, style: AETheme.syne(size: 11, color: AETheme.muted, weight: FontWeight.w400)),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AETheme.bg2,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0x12070921)),
                ),
                child: Text(dateStr, style: AETheme.syne(size: 11, color: AETheme.muted, weight: FontWeight.w600)),
              ),
              const SizedBox(width: 10),
              _LivePill(),
            ],
          ),
        ],
      ),
    );
  }

  String _weekday(int d) =>
      ['','Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d];
  String _month(int m) =>
      ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}

class _LivePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x14047857),
        border: Border.all(color: const Color(0x30047857)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 5, height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: AETheme.syne(size: 9, color: AETheme.green, letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Scaffold wrapper for all client screens ───────────────
class ClientScaffold extends StatelessWidget {
  final String    active;
  final String    title;
  final String    subtitle;
  final Widget    body;

  const ClientScaffold({
    super.key,
    required this.active,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: AETheme.bg,
      drawer: narrow ? Drawer(child: AESidebar(active: active)) : null,
      appBar: narrow
          ? AppBar(
              backgroundColor: AETheme.white,
              title: Text(title, style: AETheme.fraunces(size: 16)),
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, color: AETheme.ink),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          if (!narrow) AESidebar(active: active),
          Expanded(
            child: Column(
              children: [
                if (!narrow)
                  AETopBar(title: title, subtitle: subtitle),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
