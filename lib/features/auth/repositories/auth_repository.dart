import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createPetrolPump({
    required String name,
    required String ownerId,
  }) async {
    await _supabase.from('petrol_pumps').insert({
      'name': name,
      'owner_id': ownerId,
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider).client;
  return AuthRepository(supabase);
});
