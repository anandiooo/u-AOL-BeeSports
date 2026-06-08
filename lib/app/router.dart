import 'package:beesports/app/di.dart';
import 'package:beesports/blocs/blocs.dart';
import 'package:beesports/core/page_transitions.dart';
import 'package:beesports/screens/screens.dart';
import 'package:beesports/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: _AuthNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/onboarding';

      if (authState is Unauthenticated || authState is AuthError) {
        return isOnAuthRoute ? null : '/login';
      }

      if (authState is NeedsOnboarding) {
        return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      }

      if (authState is Authenticated && isOnAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: LoginScreen(
            onNavigateToRegister: () => context.go('/register'),
          ),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => FadeTransitionPage(
          key: state.pageKey,
          child: RegisterScreen(
            onNavigateToLogin: () => context.go('/login'),
          ),
        ),
      ),

      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) {
          final authState = authBloc.state;
          if (authState is NeedsOnboarding) {
            return FadeTransitionPage(
              key: state.pageKey,
              child: OnboardingScreen(user: authState.user),
            );
          }
          return FadeTransitionPage(
            key: state.pageKey,
            child: const SizedBox.shrink(),
          );
        },
      ),
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<ProfileBloc>(),
            child: const ProfileScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.id : '';
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) =>
                  sl<ProfileBloc>()..add(ProfileLoadRequested(userId)),
              child: const ProfileEditScreen(),
            ),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<NotificationBloc>(),
            child: const NotificationScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/friends',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<SocialBloc>(),
            child: const FriendsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/users/search',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<SocialBloc>(),
            child: const UserSearchScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/match/history',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideRightTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<MatchBloc>(),
            child: const MatchHistoryScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/map-picker',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SlideUpTransitionPage(
            key: state.pageKey,
            child: MapPickerScreen(
              initialLat: extra?['lat'] as double?,
              initialLng: extra?['lng'] as double?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/lobbies/create',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => sl<CreateLobbyBloc>(),
            child: const CreateLobbyScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/lobbies/:lobbyId',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final lobbyId = state.pathParameters['lobbyId']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) =>
                  sl<LobbyDetailBloc>()..add(LoadLobbyDetail(lobbyId)),
              child: LobbyDetailScreen(lobbyId: lobbyId),
            ),
          );
        },
      ),
      GoRoute(
        path: '/lobbies/:lobbyId/chat',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final lobbyId = state.pathParameters['lobbyId']!;
          return SlideRightTransitionPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => sl<ChatBloc>(),
              child: LobbyChatScreen(lobbyId: lobbyId),
            ),
          );
        },
      ),
      GoRoute(
        path: '/wallet/topup',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const TopUpScreen(),
        ),
      ),
      GoRoute(
        path: '/wallet/withdraw',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => SlideUpTransitionPage(
          key: state.pageKey,
          child: const WithdrawScreen(),
        ),
      ),

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => sl<LobbyListBloc>(),
                child: const HomeScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/lobbies',
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => sl<LobbyListBloc>(),
                child: const LobbyListScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/wallet',
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: const WalletScreen(),
            ),
          ),
          GoRoute(
            path: '/leaderboard',
            pageBuilder: (context, state) => FadeTransitionPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => sl<LeaderboardBloc>(),
                child: const LeaderboardScreen(),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
