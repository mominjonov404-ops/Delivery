import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref.watch(supabaseProvider)));

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  final data = await supabase.from('profiles').select().eq('id', user.id).single();
  return ProfileModel.fromJson(data);
});

class AuthService {
  final SupabaseClient _client;
  AuthService(this._client);

  Future<void> sendOtp(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp(String phone, String token) async {
    return await _client.auth.verifyOTP(phone: phone, token: token, type: OtpType.sms);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
