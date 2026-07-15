// This file control all app navigation and check login status, so it
// send user to correct screen every time.
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/users/domain/entities/user_entity.dart';
import '../../features/users/presentation/pages/home_page.dart';
import 'go_router_refresh_stream.dart';
import 'min_delay_gate.dart';

GoRouter buildRouter(AuthBloc authBloc) {
  final splashGate = MinDelayGate(const Duration(milliseconds: 2500));

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authBloc.stream),
      splashGate,
    ]),
    redirect: (context, state) {
      final authState = authBloc.state;
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isUnauthRoute =
          location == '/onboarding' ||
          location == '/login' ||
          location == '/register';

      final authKnown = authState.status != AuthStatus.unknown;

      if (!authKnown || !splashGate.isElapsed) {
        return isSplash ? null : '/splash';
      }

      final isAuthenticated = authState.status == AuthStatus.authenticated;

      if (!isAuthenticated) {
        return isUnauthRoute ? null : '/onboarding';
      }

      if (isSplash || isUnauthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/chat/:peerId',
        builder: (context, state) =>
            ChatPage(peer: state.extra! as UserEntity),
      ),
    ],
  );
}
