import 'package:beesports/app/di.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/screens/login_screen.dart';
import 'package:beesports/screens/onboarding_screen.dart';
import 'package:beesports/screens/otp_screen.dart';
import 'package:beesports/screens/register_screen.dart';
import 'package:beesports/blocs/chat_bloc.dart';
import 'package:beesports/screens/lobby_chat_screen.dart';
import 'package:beesports/screens/home_screen.dart';
import 'package:beesports/blocs/leaderboard_bloc.dart';
import 'package:beesports/screens/leaderboard_screen.dart';
import 'package:beesports/blocs/create_lobby_bloc.dart';
import 'package:beesports/blocs/lobby_detail_bloc.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/screens/create_lobby_screen.dart';
import 'package:beesports/screens/lobby_detail_screen.dart';
import 'package:beesports/screens/lobby_list_screen.dart';
import 'package:beesports/blocs/match_bloc.dart';
import 'package:beesports/screens/match_history_screen.dart';
import 'package:beesports/screens/match_result_screen.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:beesports/screens/notification_screen.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/screens/profile_edit_screen.dart';
import 'package:beesports/screens/profile_screen.dart';
import 'package:beesports/blocs/social_bloc.dart';
import 'package:beesports/screens/friends_screen.dart';
import 'package:beesports/screens/user_search_screen.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:beesports/screens/top_up_screen.dart';
import 'package:beesports/screens/wallet_screen.dart';
import 'package:beesports/screens/withdraw_screen.dart';
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
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/onboarding';

      if (authState is Unauthenticated || authState is AuthError) {
        return isOnAuthRoute ? null : '/login';
      }

      if (authState is NeedsOtpVerification) {
        return '/otp';
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
      // auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onNavigateToRegister: () => context.go('/register'),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          onNavigateToLogin: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final authState = authBloc.state;
          final email =
              authState is NeedsOtpVerification ? authState.email : '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final authState = authBloc.state;
          if (authState is NeedsOnboarding) {
            return OnboardingScreen(user: authState.user);
          }
          return const SizedBox.shrink();
        },
      ),

      // profile routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileBloc>(),
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          final userId = authState is Authenticated ? authState.user.id : '';
          return BlocProvider(
            create: (_) => sl<ProfileBloc>()..add(ProfileLoadRequested(userId)),
            child: const ProfileEditScreen(),
          );
        },
      ),

      // main application routes
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<LobbyListBloc>(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/lobbies',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<LobbyListBloc>(),
              child: const LobbyListScreen(),
            ),
          ),
          GoRoute(
            path: '/lobbies/create',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<CreateLobbyBloc>(),
              child: const CreateLobbyScreen(),
            ),
          ),
          GoRoute(
            path: '/lobbies/:lobbyId',
            builder: (context, state) {
              final lobbyId = state.pathParameters['lobbyId']!;
              return BlocProvider(
                create: (_) =>
                    sl<LobbyDetailBloc>()..add(LoadLobbyDetail(lobbyId)),
                child: LobbyDetailScreen(lobbyId: lobbyId),
              );
            },
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<WalletBloc>(),
              child: const WalletScreen(),
            ),
          ),
          GoRoute(
            path: '/wallet/topup',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<WalletBloc>(),
              child: const TopUpScreen(),
            ),
          ),
          GoRoute(
            path: '/wallet/withdraw',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<WalletBloc>(),
              child: const WithdrawScreen(),
            ),
          ),
          GoRoute(
            path: '/match/:lobbyId/result',
            builder: (context, state) {
              final lobbyId = state.pathParameters['lobbyId']!;
              return BlocProvider(
                create: (_) => sl<MatchBloc>(),
                child: MatchResultScreen(lobbyId: lobbyId),
              );
            },
          ),
          GoRoute(
            path: '/match/history',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<MatchBloc>(),
              child: const MatchHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<LeaderboardBloc>(),
              child: const LeaderboardScreen(),
            ),
          ),
          GoRoute(
            path: '/lobbies/:lobbyId/chat',
            builder: (context, state) {
              final lobbyId = state.pathParameters['lobbyId']!;
              return BlocProvider(
                create: (_) => sl<ChatBloc>(),
                child: LobbyChatScreen(lobbyId: lobbyId),
              );
            },
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<NotificationBloc>(),
              child: const NotificationScreen(),
            ),
          ),
          GoRoute(
            path: '/friends',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<SocialBloc>(),
              child: const FriendsScreen(),
            ),
          ),
          GoRoute(
            path: '/users/search',
            builder: (context, state) => BlocProvider(
              create: (_) => sl<SocialBloc>(),
              child: const UserSearchScreen(),
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
