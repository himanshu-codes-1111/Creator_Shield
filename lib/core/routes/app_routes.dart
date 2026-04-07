import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/main/screens/main_screen.dart';
import '../../features/proof/screens/proof_screen.dart';
import '../../features/proof/screens/certificate_screen.dart';
import '../../features/verify/screens/verify_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';

class AppRoutes {
  AppRoutes._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) => _slide(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) => _slide(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (_, state) => _fade(state, const MainScreen()),
      ),
      GoRoute(
        path: '/proof/:id',
        pageBuilder: (_, state) => _slide(
          state,
          ProofScreen(postId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/certificate/:id',
        pageBuilder: (_, state) => _slide(
          state,
          CertificateScreen(postId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/verify',
        pageBuilder: (_, state) => _slide(state, const VerifyScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (_, state) => _slide(state, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/dashboard',
        pageBuilder: (_, state) => _slide(state, const DashboardScreen()),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (_, state) => _slide(state, const EditProfileScreen()),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );

  static CustomTransitionPage<void> _slide(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.12, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  static CustomTransitionPage<void> _fade(
    GoRouterState state,
    Widget child,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }
}
