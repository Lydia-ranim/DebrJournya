import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_config.dart';
import 'supabase_auth_repository.dart';

/// Thrown when the device can't reach the server.
class NoConnectionException implements Exception {
  const NoConnectionException();
}

/// Wrong e-mail or password.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

/// An account already exists with this e-mail.
class EmailTakenException implements Exception {
  const EmailTakenException();
}

/// The password is refused by the server (too short or too common).
class WeakPasswordException implements Exception {
  const WeakPasswordException();
}

/// The account exists but its e-mail was never confirmed with the code.
class EmailNotConfirmedException implements Exception {
  const EmailNotConfirmedException();
}

/// The code typed doesn't match the one sent.
class InvalidCodeException implements Exception {
  const InvalidCodeException();
}

/// The code is too old; a new one must be requested.
class CodeExpiredException implements Exception {
  const CodeExpiredException();
}

/// Too many attempts or e-mails; wait before trying again.
class TooManyRequestsException implements Exception {
  const TooManyRequestsException();
}

/// Social sign-in providers.
enum SocialProvider { google, facebook }

/// Why a 6-digit code was e-mailed.
enum CodePurpose { signUp, recovery }

/// The signed-in user, as far as the app needs to know.
class AuthUser {
  const AuthUser({required this.id, this.email});

  final String id;
  final String? email;
}

/// E-mail + password accounts (e-mail confirmed with a 6-digit code) and
/// Google / Facebook sign-in.
abstract interface class AuthRepository {
  AuthUser? get currentUser;

  /// Emits the user after sign-in / sign-out / session expiry, including a
  /// social sign-in finishing in the browser.
  Stream<AuthUser?> get changes;

  /// Fires when the user is signed in to reset their password (recovery
  /// code checked, or reset link opened): the app must ask for a new one.
  /// Those sign-ins are not on [changes].
  Stream<void> get passwordRecovery;

  /// Creates the account and e-mails a 6-digit code to confirm it.
  Future<void> signUp(String email, String password);

  Future<AuthUser> signIn(String email, String password);

  /// E-mails a new code ([CodePurpose.signUp] or [CodePurpose.recovery]).
  Future<void> sendCode(String email, CodePurpose purpose);

  /// Checks the code; signs the user in on success.
  Future<AuthUser> verifyCode(String email, String code, CodePurpose purpose);

  /// Sets a new password for the signed-in user (after a recovery code).
  Future<void> updatePassword(String password);

  /// Opens the provider's sign-in page; the result arrives on [changes].
  Future<void> signInWith(SocialProvider provider);

  Future<void> signOut();
}

/// In-memory accounts for tests and previews without Supabase.
/// Every code is [validCode]. [offline] simulates no network, [expired]
/// makes every code expired.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.offline = false,
    this.expired = false,
    this.validCode = '123456',
    this.delay = const Duration(milliseconds: 600),
    Map<String, String>? accounts,
    AuthUser? signedIn,
  }) : _user = signedIn,
       _passwords = {...?accounts},
       _confirmed = {...?accounts?.keys};

  bool offline;
  bool expired;
  final String validCode;
  final Duration delay;

  AuthUser? _user;
  final Map<String, String> _passwords;
  final Set<String> _confirmed;
  final _changes = StreamController<AuthUser?>.broadcast();
  final _recoveries = StreamController<void>.broadcast();

  /// (email, purpose) of every code sent, in order (for tests).
  final codesSent = <(String, CodePurpose)>[];

  /// Social providers opened, in order (for tests).
  final socialOpened = <SocialProvider>[];

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get changes => _changes.stream;

  @override
  Stream<void> get passwordRecovery => _recoveries.stream;

  Future<void> _step() async {
    await Future<void>.delayed(delay);
    if (offline) throw const NoConnectionException();
  }

  AuthUser _signInAs(String email, {bool recovery = false}) {
    final user = AuthUser(id: 'fake-$email', email: email);
    _user = user;
    recovery ? _recoveries.add(null) : _changes.add(user);
    return user;
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _step();
    if (_confirmed.contains(email)) throw const EmailTakenException();
    if (password.length < 8) throw const WeakPasswordException();
    _passwords[email] = password;
    codesSent.add((email, CodePurpose.signUp));
  }

  @override
  Future<AuthUser> signIn(String email, String password) async {
    await _step();
    if (_passwords[email] != password) {
      throw const InvalidCredentialsException();
    }
    if (!_confirmed.contains(email)) throw const EmailNotConfirmedException();
    return _signInAs(email);
  }

  @override
  Future<void> sendCode(String email, CodePurpose purpose) async {
    await _step();
    codesSent.add((email, purpose));
  }

  @override
  Future<AuthUser> verifyCode(
    String email,
    String code,
    CodePurpose purpose,
  ) async {
    await _step();
    if (expired) throw const CodeExpiredException();
    if (code != validCode) throw const InvalidCodeException();
    _confirmed.add(email);
    return _signInAs(email, recovery: purpose == CodePurpose.recovery);
  }

  @override
  Future<void> updatePassword(String password) async {
    await _step();
    if (password.length < 8) throw const WeakPasswordException();
    final email = _user?.email;
    if (email != null) _passwords[email] = password;
  }

  @override
  Future<void> signInWith(SocialProvider provider) async {
    await _step();
    socialOpened.add(provider);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseConfig.isConfigured
      ? SupabaseAuthRepository.fromInstance()
      : FakeAuthRepository(),
);
