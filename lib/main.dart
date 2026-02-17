import 'package:beesports/core/config/supabase_config.dart';
import 'package:beesports/core/di/injection_container.dart';
import 'package:beesports/core/router/app_router.dart';
import 'package:beesports/core/theme/app_theme.dart';
import 'package:beesports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await SupabaseConfig.initialize();

  await initDependencies();

  runApp(const BeeSportsApp());
}

class BeeSportsApp extends StatelessWidget {
  const BeeSportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
      child: Builder(
        builder: (context) {
          final authBloc = context.read<AuthBloc>();
          final appRouter = AppRouter(authBloc);

          return MaterialApp.router(
            title: 'BeeSports',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
