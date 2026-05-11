import 'package:beesports/repos/auth_repository_impl.dart';
import 'package:beesports/repos/auth_repository.dart';
import 'package:beesports/blocs/auth_bloc.dart';
import 'package:beesports/repos/chat_repository_impl.dart';
import 'package:beesports/repos/chat_repository.dart';
import 'package:beesports/blocs/chat_bloc.dart';
import 'package:beesports/repos/leaderboard_repository_impl.dart';
import 'package:beesports/repos/leaderboard_repository.dart';
import 'package:beesports/blocs/leaderboard_bloc.dart';
import 'package:beesports/repos/lobby_repository_impl.dart';
import 'package:beesports/repos/lobby_repository.dart';
import 'package:beesports/blocs/create_lobby_bloc.dart';
import 'package:beesports/blocs/lobby_detail_bloc.dart';
import 'package:beesports/blocs/lobby_list_bloc.dart';
import 'package:beesports/repos/match_repository_impl.dart';
import 'package:beesports/repos/match_repository.dart';
import 'package:beesports/blocs/match_bloc.dart';
import 'package:beesports/repos/notification_repository_impl.dart';
import 'package:beesports/repos/notification_repository.dart';
import 'package:beesports/blocs/notification_bloc.dart';
import 'package:beesports/repos/profile_repository_impl.dart';
import 'package:beesports/repos/profile_repository.dart';
import 'package:beesports/blocs/profile_bloc.dart';
import 'package:beesports/repos/social_repository_impl.dart';
import 'package:beesports/repos/social_repository.dart';
import 'package:beesports/blocs/social_bloc.dart';
import 'package:beesports/repos/wallet_repository_impl.dart';
import 'package:beesports/repos/wallet_repository.dart';
import 'package:beesports/blocs/wallet_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<LobbyRepository>(
    () => LobbyRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(sl<ProfileRepository>()),
  );

  sl.registerFactory<LobbyListBloc>(
    () => LobbyListBloc(sl<LobbyRepository>()),
  );

  sl.registerFactory<LobbyDetailBloc>(
    () => LobbyDetailBloc(sl<LobbyRepository>()),
  );

  sl.registerFactory<CreateLobbyBloc>(
    () => CreateLobbyBloc(sl<LobbyRepository>()),
  );

  sl.registerFactory<WalletBloc>(
    () => WalletBloc(sl<WalletRepository>()),
  );

  sl.registerFactory<MatchBloc>(
    () => MatchBloc(sl<MatchRepository>()),
  );

  sl.registerFactory<LeaderboardBloc>(
    () => LeaderboardBloc(sl<LeaderboardRepository>()),
  );

  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerFactory<ChatBloc>(
    () => ChatBloc(sl<ChatRepository>()),
  );

  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(sl<NotificationRepository>()),
  );

  sl.registerLazySingleton<SocialRepository>(
    () => SocialRepositoryImpl(sl<SupabaseClient>()),
  );

  sl.registerFactory<SocialBloc>(
    () => SocialBloc(sl<SocialRepository>()),
  );
}
