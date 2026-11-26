import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/phone_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/tracking/tracking_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/admin/admin_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = Supabase.instance.client;
  return GoRouter(
    initialLocation: supabase.auth.currentSession != null ? '/home' : '/auth/phone',
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final onAuth = state.matchedLocation.startsWith('/auth');
      if (session == null && !onAuth) return '/auth/phone';
      if (session != null && onAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/auth/phone', builder: (c, s) => const PhoneScreen()),
      GoRoute(path: '/auth/otp', builder: (c, s) => OtpScreen(phone: s.extra as String)),
      ShellRoute(
        builder: (c, s, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
          GoRoute(path: '/tracking/:orderId', builder: (c, s) => TrackingScreen(orderId: s.pathParameters['orderId']!)),
          GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
          GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/admin', builder: (c, s) => const AdminShell()),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _locationToIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/history')) return 1;
    if (loc.startsWith('/tracking')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _locationToIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/home'); break;
            case 1: context.go('/history'); break;
            case 2: context.go('/tracking/none'); break;
            case 3: context.go('/profile'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Bosh sahifa'),
          NavigationDestination(icon: Icon(Icons.history_outlined), selectedIcon: Icon(Icons.history_rounded), label: 'Tarix'),
          NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on_rounded), label: 'Kuzatish'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
