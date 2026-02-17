import 'package:beesports/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:beesports/features/auth/domain/repositories/auth_repository.dart';
import 'package:beesports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:beesports/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:beesports/features/profile/domain/repositories/profile_repository.dart';
import 'package:beesports/features/profile/presentation/bloc/profile_bloc.dart';
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

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(sl<ProfileRepository>()),
  );
}
