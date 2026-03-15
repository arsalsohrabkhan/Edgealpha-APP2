import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAdmin = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _adminCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _adminCtrl.dispose();
    super.dispose();
  }

  Future<void> _doClientLogin() async {
    final auth = context.read<AuthService>();
    auth.clearError();
    final ok = await auth.loginClient(_emailCtrl.text, _passCtrl.text);
    if (ok && mounted) context.go('/dashboard');
  }

  Future<void> _doAdminLogin() async {
    final auth = context.read<AuthService>();
    auth.clearError();
    final ok = await auth.loginAdmin(_adminCtrl.text);
    if (ok && mounted) context.go('/admin');
  }

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.of(context).size.width < 800;
    final auth   = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: AETheme.bg,
      body: Row(
        children: [
          // LEFT PANEL — dark branded side
          if (!narrow)
            Expanded(
              flex: 52,
              child: _LeftPanel(),
            ),

          // RIGHT PANEL — login form
          Expanded(
            flex: 48,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              gradient: AETheme.indigoGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.show_chart, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 9),
                          Text('AlphaEdge', style: AETheme.fraunces(size: 18)),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Text('Welcome back', style: AETheme.fraunces(size: 28, letterSpacing: -1)),
                      const SizedBox(height: 6),
                      Text('Sign in to your private trading portal', style: AETheme.syne(size: 12, color: AETheme.muted, weight: FontWeight.w400)),
                      const SizedBox(height: 28),

                      // Tabs
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AETheme.bg2,
                          border: Border.all(color: const Color(0x12070921)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            _Tab(label: '👤  Client Login', active: !_isAdmin, onTap: () => setState(() => _isAdmin = false)),
                            _Tab(label: '🛡  Admin',        active:  _isAdmin, onTap: () => setState(() => _isAdmin = true),  isAdmin: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Form
                      if (!_isAdmin) ...[
                        _FormField(label: 'Email Address', ctrl: _emailCtrl, hint: 'your@email.com',   keyboard: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _FormField(label: 'Password',      ctrl: _passCtrl,  hint: 'Your password',   obscure: true),
                        const SizedBox(height: 6),
                        _GradientButton(
                          label: auth.loading ? 'Signing in…' : 'Enter Dashboard →',
                          gradient: AETheme.indigoGradient,
                          onTap: auth.loading ? null : _doClientLogin,
                        ),
                      ] else ...[
                        _FormField(label: 'Admin Password', ctrl: _adminCtrl, hint: 'Enter admin password', obscure: true),
                        const SizedBox(height: 6),
                        _GradientButton(
                          label: auth.loading ? 'Verifying…' : 'Enter Admin Panel →',
                          gradient: AETheme.amberGradient,
                          onTap: auth.loading ? null : _doAdminLogin,
                        ),
                      ],

                      // Error
                      if (auth.error != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0x10DC2626),
                            border: Border.all(color: const Color(0x35DC2626)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(auth.error!, style: AETheme.syne(size: 12, color: AETheme.red, weight: FontWeight.w700), textAlign: TextAlign.center),
                        ),
                      ],

                      const SizedBox(height: 22),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go('/'),
                          child: Text.rich(
                            TextSpan(
                              style: AETheme.syne(size: 10, color: AETheme.faint, weight: FontWeight.w500),
                              children: [
                                const TextSpan(text: 'AlphaEdge © 2026 · '),
                                TextSpan(
                                  text: 'Back to home',
                                  style: AETheme.syne(size: 10, color: AETheme.indigo2, weight: FontWeight.w700),
                                ),
                                const TextSpan(text: ' · Private & Confidential'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AETheme.ink, AETheme.ink2, Color(0xFF1E1B4B), AETheme.indigo],
        ),
      ),
      child: Stack(
        children: [
          // Mesh gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -0.3),
                  radius: 1.0,
                  colors: [const Color(0x484F46E5), Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(52),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0x20FFFFFF),
                        border: Border.all(color: const Color(0x35FFFFFF)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.show_chart, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text('AlphaEdge', style: AETheme.fraunces(size: 22, color: Colors.white)),
                  ],
                ),

                const Spacer(),

                // Tag pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x15FFFFFF),
                    border: Border.all(color: const Color(0x25FFFFFF)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle)),
                      const SizedBox(width: 7),
                      Text('PRIVATE CAPITAL PORTAL', style: AETheme.syne(size: 9, color: const Color(0xA0FFFFFF), weight: FontWeight.w800, letterSpacing: 2)),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Text('Your edge\nstarts here.', style: AETheme.fraunces(size: 64, color: Colors.white, letterSpacing: -3, height: 0.9, italic: true)),
                const SizedBox(height: 20),
                Text(
                  'Secure access to your private trading dashboard. Real-time analytics, encrypted communications, and institutional-grade reporting.',
                  style: AETheme.syne(size: 13, color: const Color(0x74FFFFFF), weight: FontWeight.w400),
                ),

                const SizedBox(height: 40),

                // Proof
                Container(
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x15FFFFFF)))),
                  padding: const EdgeInsets.only(top: 28),
                  child: Row(
                    children: [
                      _Proof(value: r'$4.2B', label: 'Total AUM'),
                      _Proof(value: '247',    label: 'Clients'),
                      _Proof(value: '98.4%',  label: 'Uptime'),
                    ],
                  ),
                ),

                const Spacer(),

                // Floating performance card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x12FFFFFF),
                    border: Border.all(color: const Color(0x20FFFFFF)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PORTFOLIO PERFORMANCE', style: AETheme.syne(size: 8, color: const Color(0x60FFFFFF), weight: FontWeight.w800, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text('+13.8%', style: AETheme.fraunces(size: 26, color: const Color(0xFF34D399), letterSpacing: -1)),
                      const SizedBox(height: 3),
                      Text('Monthly return · Client avg', style: AETheme.syne(size: 10, color: const Color(0x66FFFFFF), weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Proof extends StatelessWidget {
  final String value, label;
  const _Proof({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AETheme.fraunces(size: 26, color: Colors.white, letterSpacing: -1)),
        const SizedBox(height: 3),
        Text(label, style: AETheme.syne(size: 9, color: const Color(0x50FFFFFF), weight: FontWeight.w700)),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active, isAdmin;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? (isAdmin ? const Color(0x1A4F46E5) : AETheme.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: active ? (isAdmin ? const Color(0x354F46E5) : const Color(0x12070921)) : Colors.transparent,
            ),
            boxShadow: active && !isAdmin ? [const BoxShadow(color: Color(0x14070921), blurRadius: 8, offset: Offset(0, 2))] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AETheme.syne(
              size: 12,
              weight: FontWeight.w800,
              color: active
                  ? (isAdmin ? AETheme.indigo2 : AETheme.ink)
                  : AETheme.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final bool obscure;
  final TextInputType keyboard;

  const _FormField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.obscure = false,
    this.keyboard = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AETheme.syne(size: 10, color: AETheme.slate, weight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboard,
          style: AETheme.syne(size: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AETheme.syne(size: 14, color: AETheme.faint, weight: FontWeight.w400),
            filled: true,
            fillColor: AETheme.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x1A070921), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x1A070921), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AETheme.indigo2, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final LinearGradient gradient;
  final VoidCallback? onTap;

  const _GradientButton({required this.label, required this.gradient, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        margin: const EdgeInsets.only(top: 6),
        decoration: BoxDecoration(
          gradient: onTap != null ? gradient : null,
          color: onTap == null ? AETheme.faint : null,
          borderRadius: BorderRadius.circular(10),
          boxShadow: onTap != null
              ? [BoxShadow(color: gradient.colors.first.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 4))]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AETheme.syne(size: 14, color: Colors.white, weight: FontWeight.w800),
        ),
      ),
    );
  }
}
