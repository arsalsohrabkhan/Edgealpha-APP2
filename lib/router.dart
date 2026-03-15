import 'package:go_router/go_router.dart';
import 'services/firebase_service.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/trades_screen.dart';
import 'screens/performance_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/admin_messages_screen.dart';
import 'screens/admin/admin_reports_screen.dart';

GoRouter createRouter(AuthService auth) => GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = auth.loggedIn;
    final isAdmin  = auth.isAdmin;
    final loc      = state.uri.path;
    if (loc == '/' || loc == '/login') return null;
    if (loc.startsWith('/admin') && !isAdmin)  return '/login';
    if (!loc.startsWith('/admin') && !loggedIn) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/',               builder: (_, __) => const LandingScreen()),
    GoRoute(path: '/login',          builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/dashboard',      builder: (_, __) => const DashboardScreen()),
    GoRoute(path: '/trades',         builder: (_, __) => const TradesScreen()),
    GoRoute(path: '/performance',    builder: (_, __) => const PerformanceScreen()),
    GoRoute(path: '/messages',       builder: (_, __) => const MessagesScreen()),
    GoRoute(path: '/reports',        builder: (_, __) => const ReportsScreen()),
    GoRoute(path: '/admin',          builder: (_, __) => const AdminScreen()),
    GoRoute(path: '/admin/messages', builder: (_, __) => const AdminMessagesScreen()),
    GoRoute(path: '/admin/reports',  builder: (_, __) => const AdminReportsScreen()),
  ],
  refreshListenable: auth,
);
