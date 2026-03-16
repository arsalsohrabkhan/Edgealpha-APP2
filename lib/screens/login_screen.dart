import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isAdmin = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _adminCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    _adminCtrl.dispose(); _animCtrl.dispose();
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
    final auth = context.watch<AuthService>();
    final h    = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AETheme.ink,
      body: SingleChildScrollView(
        child: SizedBox(
          height: h,
          child: Stack(
            children: [
              // Gradient background
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [AETheme.ink, AETheme.ink2, Color(0xFF1E1B4B), AETheme.indigo],
                    ),
                  ),
                ),
              ),
              // Decorative circle
              Positioned(top: -80, right: -80,
                child: Container(
                  width: 280, height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AETheme.indigo2.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Positioned(bottom: 200, left: -60,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AETheme.violet.withValues(alpha: 0.12),
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      // Top logo section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
                        child: Column(
                          children: [
                            // Logo mark
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                gradient: AETheme.indigoGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [BoxShadow(
                                  color: AETheme.indigo2.withValues(alpha: 0.5),
                                  blurRadius: 24, offset: const Offset(0, 8),
                                )],
                              ),
                              child: const Icon(Icons.show_chart_rounded,
                                  color: Colors.white, size: 32),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              text: TextSpan(
                                style: AETheme.fraunces(size: 32, color: Colors.white, letterSpacing: -1),
                                children: const [
                                  TextSpan(text: 'Alpha'),
                                  TextSpan(text: 'Edge',
                                      style: TextStyle(color: AETheme.indigo3)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Private Capital Portal',
                              style: AETheme.syne(size: 13, color: const Color(0x80FFFFFF),
                                  weight: FontWeight.w400)),
                            const SizedBox(height: 36),

                            // Stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _MiniStat(value: r'$4.2B', label: 'Total AUM'),
                                _Divider(),
                                _MiniStat(value: '247',  label: 'Clients'),
                                _Divider(),
                                _MiniStat(value: '98.4%', label: 'Uptime'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Bottom form card
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AETheme.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 40, offset: const Offset(0, -8)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tab switcher
                              Container(
                                decoration: BoxDecoration(
                                  color: AETheme.bg2,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    _Tab(label: 'Client Login', active: !_isAdmin,
                                        onTap: () => setState(() => _isAdmin = false)),
                                    _Tab(label: '🛡 Admin', active: _isAdmin, isAdmin: true,
                                        onTap: () => setState(() => _isAdmin = true)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              if (!_isAdmin) ...[
                                Text('Welcome back',
                                  style: AETheme.fraunces(size: 26, letterSpacing: -1)),
                                const SizedBox(height: 4),
                                Text('Sign in to your private portal',
                                  style: AETheme.syne(size: 13, color: AETheme.muted,
                                      weight: FontWeight.w400)),
                                const SizedBox(height: 24),
                                _Field(label: 'Email', ctrl: _emailCtrl,
                                    hint: 'your@email.com',
                                    keyboard: TextInputType.emailAddress,
                                    icon: Icons.email_outlined),
                                const SizedBox(height: 14),
                                _Field(label: 'Password', ctrl: _passCtrl,
                                    hint: 'Your password',
                                    obscure: true, icon: Icons.lock_outline),
                                const SizedBox(height: 24),
                                GradBtn(
                                  label: 'Enter Dashboard →',
                                  gradient: AETheme.indigoGradient,
                                  onTap: auth.loading ? null : _doClientLogin,
                                  loading: auth.loading,
                                ),
                              ] else ...[
                                Text('Admin Access',
                                  style: AETheme.fraunces(size: 26, letterSpacing: -1)),
                                const SizedBox(height: 4),
                                Text('Password: admin2026',
                                  style: AETheme.syne(size: 12, color: AETheme.muted,
                                      weight: FontWeight.w400)),
                                const SizedBox(height: 24),
                                _Field(label: 'Admin Password', ctrl: _adminCtrl,
                                    hint: 'admin2026',
                                    obscure: true, icon: Icons.admin_panel_settings_outlined),
                                const SizedBox(height: 24),
                                GradBtn(
                                  label: 'Enter Admin Panel →',
                                  gradient: AETheme.amberGradient,
                                  onTap: auth.loading ? null : _doAdminLogin,
                                  loading: auth.loading,
                                ),
                              ],

                              // Error
                              if (auth.error != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0x10DC2626),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0x30DC2626)),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline,
                                        color: AETheme.red, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(auth.error!,
                                        style: AETheme.syne(size: 12, color: AETheme.red,
                                            weight: FontWeight.w700))),
                                  ]),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  const _MiniStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: AETheme.fraunces(size: 20, color: Colors.white, letterSpacing: -0.5)),
    const SizedBox(height: 3),
    Text(label, style: AETheme.syne(size: 9, color: const Color(0x60FFFFFF), weight: FontWeight.w600)),
  ]);
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 30, color: const Color(0x25FFFFFF));
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active, isAdmin;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active,
    required this.onTap, this.isAdmin = false});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? AETheme.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: active ? [const BoxShadow(
              color: Color(0x18070921), blurRadius: 8, offset: Offset(0, 2))] : [],
        ),
        child: Text(label, textAlign: TextAlign.center,
          style: AETheme.syne(size: 13, weight: FontWeight.w800,
              color: active ? (isAdmin ? AETheme.amber : AETheme.ink) : AETheme.muted)),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final String label, hint;
  final TextEditingController ctrl;
  final bool obscure;
  final TextInputType keyboard;
  final IconData icon;
  const _Field({required this.label, required this.ctrl, required this.hint,
    required this.icon, this.obscure = false, this.keyboard = TextInputType.text});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label.toUpperCase(),
        style: AETheme.syne(size: 10, color: AETheme.slate,
            weight: FontWeight.w800, letterSpacing: 1)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl, obscureText: obscure, keyboardType: keyboard,
        style: AETheme.syne(size: 15, weight: FontWeight.w600),
        onSubmitted: (_) => FocusScope.of(context).nextFocus(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AETheme.syne(size: 15, color: AETheme.faint, weight: FontWeight.w400),
          prefixIcon: Icon(icon, color: AETheme.muted, size: 20),
          filled: true, fillColor: AETheme.bg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0x0F070921))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AETheme.indigo2, width: 2)),
        ),
      ),
    ],
  );
}
