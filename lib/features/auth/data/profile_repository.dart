import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/supabase/supabase_config.dart';

/// What the user came for, chosen once on A6 (fixed for v1).
enum UserRole { student, employer }

/// The signed-in user's own profile row (`public.profiles`).
abstract interface class ProfileRepository {
  /// The role, or null if A6 hasn't been answered yet.
  Future<UserRole?> myRole();

  Future<void> setRole(UserRole role);
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._db);

  final sb.SupabaseClient _db;

  String get _uid => _db.auth.currentUser!.id;

  @override
  Future<UserRole?> myRole() async {
    final row = await _db
        .from('profiles')
        .select('role')
        .eq('id', _uid)
        .maybeSingle();
    final role = row?['role'] as String?;
    return role == null ? null : UserRole.values.byName(role);
  }

  @override
  Future<void> setRole(UserRole role) =>
      _db.from('profiles').update({'role': role.name}).eq('id', _uid);
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({this.role});

  UserRole? role;

  @override
  Future<UserRole?> myRole() async => role;

  @override
  Future<void> setRole(UserRole r) async => role ??= r;
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseConfig.isConfigured
      ? SupabaseProfileRepository(sb.Supabase.instance.client)
      : FakeProfileRepository(),
);
