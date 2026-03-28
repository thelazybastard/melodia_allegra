//     MelodiaAllegra is a unified audio workstation for podcasts, 
//     internet radio, and local music/audiobook management. 
//
//     Copyright (C) 2026 Monish H. Giani
//
//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.

import 'package:flutter/material.dart';
import 'package:melodia_allegra/music.dart';
import 'package:go_router/go_router.dart';
// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

void main() {
  runApp(const MyApp());
}

// ---------------------------------------------------------------------------
// Router — declared at the top level so it is never rebuilt.
// This is critical: creating GoRouter inside a build() method causes the
// "multiple widgets used the same GlobalKey" crash on hot-reload.
// ---------------------------------------------------------------------------

// Branch navigator keys — one per tab.
final _homeNavKey    = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _searchNavKey  = GlobalKey<NavigatorState>(debugLabel: 'searchNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

final GoRouter _router = GoRouter(
  initialLocation: '/home',

  // Flip to true while debugging routes.
  debugLogDiagnostics: false,

  routes: [
    // -----------------------------------------------------------------
    // StatefulShellRoute keeps each tab's navigation stack alive while
    // you switch between tabs (IndexedStack under the hood).
    // -----------------------------------------------------------------
    StatefulShellRoute.indexedStack(
      builder: (BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) {
        return ScaffoldWithBottomNav(navigationShell: navigationShell);
      },
      branches: [
        // ── Tab 0 : Home ──────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _homeNavKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                // Sub-route inside the Home tab — bottom bar stays visible.
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id'] ?? '';
                    return HomeDetailScreen(id: id);
                  },
                ),
              ],
            ),
          ],
        ),

        // ── Tab 1 : Search ────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _searchNavKey,
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),

        // ── Tab 2 : Profile ───────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: _profileNavKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // -----------------------------------------------------------------
    // Routes outside the shell — bottom bar is NOT shown.
    // Use parentNavigatorKey: _rootNavKey if you need to push on top of
    // everything. Without it go_router already targets the root navigator
    // for top-level GoRoutes.
    // -----------------------------------------------------------------
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// MyApp
// ---------------------------------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// ---------------------------------------------------------------------------
// Shell scaffold — wraps every tab screen.
// ---------------------------------------------------------------------------

class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops back to its initial route.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder screens — replace with your real screens.
// ---------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/home/detail/42'),
          child: const Text('Go to Detail 42'),
        ),
      ),
    );
  }
}

class HomeDetailScreen extends StatelessWidget {
  const HomeDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail $id')),
      body: Center(child: Text('Detail screen for item $id')),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(child: Text('Search screen')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile screen')),
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          child: const Text('Enter app'),
        ),
      ),
    );
  }
}