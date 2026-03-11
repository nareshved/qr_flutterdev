import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder imports for screens we haven't created yet
import '../screens/root_scaffold.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/generate/generate_home_screen.dart';
import '../screens/generate/generate_url_screen.dart';
import '../screens/generate/generate_phone_screen.dart';
import '../screens/manage/manage_home_screen.dart';
import '../screens/manage/item_detail_screen.dart';
import '../screens/settings/settings_screen.dart';

final uiKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: uiKey,
  initialLocation: '/scan',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RootScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scan',
              builder: (context, state) => const ScanScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/generate',
              builder: (context, state) => const GenerateHomeScreen(),
              routes: [
                GoRoute(
                  path: 'url',
                  builder: (context, state) => const GenerateUrlScreen(),
                ),
                GoRoute(
                  path: 'phone',
                  builder: (context, state) => const GeneratePhoneScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/manage',
              builder: (context, state) => const ManageHomeScreen(),
              routes: [
                GoRoute(
                  path: 'item/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ItemDetailScreen(itemId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
