import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static SupabaseClient? _client;

  // Return the initialized client if available, otherwise fall back to the
  // instance client (helps when initialize() was called indirectly).
  static SupabaseClient get client {
    return _client ?? Supabase.instance.client;
  }

  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Supabase URL and Anon Key must be provided in .env file',
      );
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Enable debug for development to see requests/responses
    );

    _client = Supabase.instance.client;
  }

  // Helper method to check if user is authenticated
  static bool get isAuthenticated => client.auth.currentUser != null;

  // Helper method to get current user
  static User? get currentUser => client.auth.currentUser;
}
