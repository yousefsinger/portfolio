import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/admin_login_page.dart';
import '../../features/portfolio/presentation/pages/portfolio_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';

class AppRouter {
  static const String roleSelection = '/';
  static const String adminLogin = '/admin-login';
  static const String portfolio = '/portfolio';
  static const String adminDashboard = '/admin-dashboard';

  static final GoRouter router = GoRouter(
    initialLocation: portfolio,
    routes: [
      GoRoute(
        path: roleSelection,
        name: 'role-selection',
        pageBuilder: (context, state) => const CustomTransitionPage(
          child: RoleSelectionPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: adminLogin,
        name: 'admin-login',
        pageBuilder: (context, state) => const CustomTransitionPage(
          child: AdminLoginPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: portfolio,
        name: 'portfolio',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isAdmin = extra?['isAdmin'] as bool? ?? false;
          return CustomTransitionPage(
            child: PortfolioPage(isAdmin: isAdmin),
            transitionsBuilder: _fadeTransition,
          );
        },
      ),
      GoRoute(
        path: adminDashboard,
        name: 'admin-dashboard',
        pageBuilder: (context, state) => const CustomTransitionPage(
          child: AdminDashboardPage(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
    ],
  );

  static Widget _fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
