import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'user_repository.dart';

class AppAuthUser {
  const AppAuthUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.creationTime,
    this.isEmailVerified = false,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? creationTime;
  final bool isEmailVerified;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthFailure(code: $code, message: $message)';
}

abstract class AuthService {
  bool get isAvailable;
  bool get supportsGoogleSignIn;
  AppAuthUser? get currentUser;
  Stream<AppAuthUser?> authStateChanges();
  Future<AppAuthUser> signInWithEmailAndPassword(String email, String password);
  Future<AppAuthUser> createUserWithEmailAndPassword(
    String email,
    String password,
  );
  Future<AppAuthUser> signInWithGoogle();
  Future<void> signOut();
  Future<AppAuthUser> updateDisplayName(String displayName);
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    UserDirectoryRepository? userDirectoryRepository,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _userDirectoryRepository =
           userDirectoryRepository ?? FirestoreUserDirectoryRepository();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final UserDirectoryRepository _userDirectoryRepository;

  late final Future<void> _googleSignInInitialization =
      _initializeGoogleSignIn();

  @override
  bool get isAvailable => _supportsConfiguredFirebasePlatforms;

  @override
  bool get supportsGoogleSignIn => _supportsConfiguredFirebasePlatforms;

  @override
  AppAuthUser? get currentUser => _mapFirebaseUser(_firebaseAuth.currentUser);

  @override
  Stream<AppAuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AppAuthUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _ensureAuthenticationIsAvailable();

    try {
      final UserCredential credential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return _completeAuthenticatedSignIn(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<AppAuthUser> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _ensureAuthenticationIsAvailable();

    try {
      final UserCredential credential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return _completeAuthenticatedSignIn(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<AppAuthUser> signInWithGoogle() async {
    _ensureAuthenticationIsAvailable();

    try {
      await _googleSignInInitialization;

      if (!_googleSignIn.supportsAuthenticate()) {
        throw const AuthFailure(
          'Google Sign-In is not available on this platform yet.',
        );
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const AuthFailure(
          'Google Sign-In did not return a valid identity token.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      return _completeAuthenticatedSignIn(userCredential.user);
    } on GoogleSignInException catch (error) {
      throw _mapGoogleSignInException(error);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> signOut() async {
    _ensureAuthenticationIsAvailable();

    try {
      await _googleSignInInitialization;
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.signOut();
      }
    } on GoogleSignInException {
      // If the Google session is already gone, Firebase sign-out should still
      // continue so the app can recover cleanly.
    } finally {
      await _firebaseAuth.signOut();
    }
  }

  @override
  Future<AppAuthUser> updateDisplayName(String displayName) async {
    _ensureAuthenticationIsAvailable();

    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthFailure('No authenticated user is available.');
    }

    try {
      await user.updateDisplayName(displayName);
      await user.reload();
      final AppAuthUser updatedUser = _requireAuthUser(
        _firebaseAuth.currentUser,
      );
      await _ensureUserDirectoryRecord(updatedUser);
      return updatedUser;
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  Future<void> _initializeGoogleSignIn() async {
    if (!supportsGoogleSignIn) {
      return;
    }

    await _googleSignIn.initialize();
  }

  void _ensureAuthenticationIsAvailable() {
    if (!isAvailable) {
      throw const AuthFailure(
        'Authentication is currently available on Android and iOS only.',
      );
    }
  }

  Future<AppAuthUser> _completeAuthenticatedSignIn(User? user) async {
    final AppAuthUser authUser = _requireAuthUser(user);

    try {
      await _ensureUserDirectoryRecord(authUser);
      return authUser;
    } on AuthFailure {
      await _rollbackFailedDirectorySync();
      rethrow;
    }
  }

  AppAuthUser _requireAuthUser(User? user) {
    final AppAuthUser? authUser = _mapFirebaseUser(user);
    if (authUser == null) {
      throw const AuthFailure(
        'Authentication completed, but no user account was returned.',
      );
    }

    return authUser;
  }

  Future<void> _ensureUserDirectoryRecord(AppAuthUser user) async {
    final String normalizedEmail = user.email.trim();
    if (normalizedEmail.isEmpty) {
      throw const AuthFailure(
        'The authenticated account is missing an email address.',
      );
    }

    try {
      await _userDirectoryRepository.ensureUserDocument(
        userId: user.uid,
        email: normalizedEmail,
        displayName: user.displayName,
        createdAt: user.creationTime,
      );
    } on UserDirectoryFailure catch (error) {
      throw AuthFailure(error.message, code: 'user-directory-sync-failed');
    }
  }

  Future<void> _rollbackFailedDirectorySync() async {
    try {
      await signOut();
    } catch (_) {
      await _firebaseAuth.signOut();
    }
  }

  AppAuthUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppAuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      creationTime: user.metadata.creationTime,
      isEmailVerified: user.emailVerified,
    );
  }

  AuthFailure _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AuthFailure(
          'Enter a valid email address and try again.',
          code: 'invalid-email',
        );
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure(
          'Incorrect email or password. Please try again.',
          code: 'invalid-credential',
        );
      case 'email-already-in-use':
        return const AuthFailure(
          'That email address is already in use. Try signing in instead.',
          code: 'email-already-in-use',
        );
      case 'user-disabled':
        return const AuthFailure(
          'This account has been disabled. Contact support for help.',
          code: 'user-disabled',
        );
      case 'network-request-failed':
        return const AuthFailure(
          'No network connection was detected. Check your internet and try again.',
          code: 'network-request-failed',
        );
      case 'too-many-requests':
        return const AuthFailure(
          'Too many attempts were made. Please wait a moment and try again.',
          code: 'too-many-requests',
        );
      case 'operation-not-allowed':
        return const AuthFailure(
          'This sign-in method is not enabled for the project yet.',
          code: 'operation-not-allowed',
        );
      case 'weak-password':
        return const AuthFailure(
          'Choose a stronger password with at least 6 characters.',
          code: 'weak-password',
        );
      case 'account-exists-with-different-credential':
        return const AuthFailure(
          'An account already exists with a different sign-in method for this email.',
          code: 'account-exists-with-different-credential',
        );
      default:
        return AuthFailure(
          error.message ?? 'Authentication failed. Please try again.',
          code: error.code,
        );
    }
  }

  AuthFailure _mapGoogleSignInException(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
      case GoogleSignInExceptionCode.interrupted:
        return const AuthFailure('Google Sign-In was canceled.');
      case GoogleSignInExceptionCode.uiUnavailable:
        return const AuthFailure(
          'Google Sign-In is unavailable on this device right now.',
        );
      case GoogleSignInExceptionCode.clientConfigurationError:
        return const AuthFailure(
          'Google Sign-In is not fully configured for this app yet.',
        );
      default:
        return AuthFailure(
          error.description ?? 'Google Sign-In failed. Please try again.',
        );
    }
  }
}

bool get _supportsConfiguredFirebasePlatforms {
  if (kIsWeb) {
    return false;
  }

  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
