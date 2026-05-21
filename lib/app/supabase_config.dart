import 'package:beesports/app/env.dart';
import 'package:beesports/app/supabase_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    final supabaseHost = Uri.parse(Env.supabaseUrl).host;
    final persistSessionKey = 'sb-${supabaseHost.split('.').first}-auth-token';

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        localStorage: FileLocalStorage(persistSessionKey: persistSessionKey),
        pkceAsyncStorage: FileGotrueAsyncStorage(),
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
