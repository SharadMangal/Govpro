import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/navigation/main_shell.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/projects/projects_screen.dart';
import '../features/project_details/project_details_screen.dart';
import '../features/compare/compare_screen.dart';
import '../features/authority_performance/authority_performance_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/notifications/notifications_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // ShellRoute for common BottomNav / NavRail
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/projects',
          builder: (context, state) => const ProjectsScreen(),
        ),
        GoRoute(
          path: '/compare',
          builder: (context, state) => const CompareScreen(),
        ),
        GoRoute(
          path: '/authorities',
          builder: (context, state) => const AuthorityPerformanceScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),
    
    // Full screen route pushed on top of the root navigator (e.g., Detail screen)
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/projects/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProjectDetailsScreen(projectId: id);
      },
    ),
  ],
);
