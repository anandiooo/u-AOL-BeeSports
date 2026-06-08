import 'package:beesports/blocs/blocs.dart';
import 'package:beesports/repos/repos.dart';
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
    () => CreateLobbyBloc(sl<LobbyRepository>(), sl<WalletRepository>()),
  );

  sl.registerLazySingleton<WalletBloc>(
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
