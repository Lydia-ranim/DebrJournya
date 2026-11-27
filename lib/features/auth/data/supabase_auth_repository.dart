import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'auth_repository.dart';

/// Accounts through Supabase Auth: e-mail + password (confirmed with an
/// e-mailed 6-digit code) and Google / Facebook (browser sign-in that comes
/// back to the app through [redirectUrl]).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._auth);

  factory SupabaseAuthRepository.fromInstance() =>
      SupabaseAuthRepository(sb.Supabase.instance.client.auth);

  final sb.GoTrueClient _auth;

  /// Deep link registered in AndroidManifest.xml and in Supabase
  /// (Authentication → URL Configuration → Redirect URLs).
  static const redirectUrl = 'com.debrjournya.debrjournya://login-callback';

  /// Codes live 1 hour by default in Supabase. Supabase answers the same
  /// error for a wrong and an expired code, so the age tells them apart.
  static const codeLifetime = Duration(hours: 1);
  final _sentAt = <String, DateTime>{};

  static AuthUser? _map(sb.User? u) =>
      u == null ? null : AuthUser(id: u.id, email: u.email);

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> get changes => _auth.onAuthStateChange
      .where((s) => s.event != sb.AuthChangeEvent.passwordRecovery)
      .map((s) => _map(s.session?.user));

  @override
  Stream<void> get passwordRecovery => _auth.onAuthStateChange
      .where((s) => s.event == sb.AuthChangeEvent.passwordRecovery)
      .map((_) {});

  @override
  Future<void> signUp(String email, String password) => _guard(() async {
    // emailRedirectTo: while the e-mail holds a link instead of a code (the
    // default Supabase template), opening it on the phone confirms the
    // account in the app (supabase_flutter reads the link and signs in).
    final res = await _auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectUrl,
    );
    // An already-confirmed e-mail comes back without identities (Supabase
    // hides whether the account exists from the API).
    if (res.user != null && (res.user!.identities ?? const []).isEmpty) {
      throw const EmailTakenException();
    }
    _sentAt[email] = DateTime.now();
  });

  @override
  Future<AuthUser> signIn(String email, String password) => _guard(() async {
    final res = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _map(res.user)!;
  });

  @override
  Future<void> sendCode(String email, CodePurpose purpose) => _guard(() async {
    if (purpose == CodePurpose.signUp) {
      await _auth.resend(
        type: sb.OtpType.signup,
        email: email,
        emailRedirectTo: redirectUrl,
      );
    } else {
      await _auth.resetPasswordForEmail(email, redirectTo: redirectUrl);
    }
    _sentAt[email] = DateTime.now();
  });

  @override
  Future<AuthUser> verifyCode(String email, String code, CodePurpose purpose) =>
      _guard(() async {
        try {
          final res = await _auth.verifyOTP(
            type: purpose == CodePurpose.signUp
                ? sb.OtpType.signup
                : sb.OtpType.recovery,
            email: email,
            token: code,
          );
          return _map(res.user)!;
        } on sb.AuthException catch (e) {
          if (e.code == 'otp_expired' || e.statusCode == '403') {
            final sent = _sentAt[email];
            final old =
                sent != null && DateTime.now().difference(sent) >= codeLifetime;
            throw old
                ? const CodeExpiredException()
                : const InvalidCodeException();
          }
          rethrow;
        }
      });

  @override
  Future<void> updatePassword(String password) => _guard(() async {
    await _auth.updateUser(sb.UserAttributes(password: password));
  });

  @override
  Future<void> signInWith(SocialProvider provider) => _guard(() async {
    await _auth.signInWithOAuth(
      provider == SocialProvider.google
          ? sb.OAuthProvider.google
          : sb.OAuthProvider.facebook,
      redirectTo: redirectUrl,
      authScreenLaunchMode: sb.LaunchMode.externalApplication,
    );
  });

  @override
  Future<void> signOut() => _auth.signOut();

  /// Turns Supabase errors into the app's exceptions.
  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on SocketException {
      throw const NoConnectionException();
    } on sb.AuthRetryableFetchException {
      throw const NoConnectionException();
    } on sb.AuthWeakPasswordException {
      throw const WeakPasswordException();
    } on sb.AuthException catch (e) {
      throw switch (e.code) {
        'invalid_credentials' => const InvalidCredentialsException(),
        'email_not_confirmed' => const EmailNotConfirmedException(),
        'user_already_exists' || 'email_exists' => const EmailTakenException(),
        'weak_password' => const WeakPasswordException(),
        'over_email_send_rate_limit' ||
        'over_request_rate_limit' => const TooManyRequestsException(),
        _ when e.statusCode == '429' => const TooManyRequestsException(),
        _ => e,
      };
    }
  }
}
