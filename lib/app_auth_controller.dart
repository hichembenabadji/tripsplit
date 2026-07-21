import 'dart:async';

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'trip_store.dart';

class AppAuthController extends ChangeNotifier {
  AppAuthController({
    required AuthService authService,
    required TripStore tripStore,
  }) : _authService = authService,
       _tripStore = tripStore,
       _currentUser = authService.currentUser,
       _authStateChanges = authService.authStateChanges().asBroadcastStream() {
    _syncTripStore(_currentUser);
    _authStateSubscription = _authStateChanges.listen((AppAuthUser? user) {
      _currentUser = user;
      _syncTripStore(user);
      notifyListeners();
    });
  }

  final AuthService _authService;
  final TripStore _tripStore;
  final Stream<AppAuthUser?> _authStateChanges;

  late final StreamSubscription<AppAuthUser?> _authStateSubscription;
  AppAuthUser? _currentUser;

  Stream<AppAuthUser?> get authStateChanges => _authStateChanges;
  AppAuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAvailable => _authService.isAvailable;
  bool get supportsGoogleSignIn => _authService.supportsGoogleSignIn;

  Future<AppAuthUser> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  Future<AppAuthUser> createUserWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _authService.createUserWithEmailAndPassword(email, password);
  }

  Future<AppAuthUser> signInWithGoogle() {
    return _authService.signInWithGoogle();
  }

  Future<void> signOut() {
    return _authService.signOut();
  }

  Future<AppAuthUser> updateDisplayName(String displayName) {
    return _authService.updateDisplayName(displayName);
  }

  void _syncTripStore(AppAuthUser? user) {
    if (user == null) {
      _tripStore.resetCurrentUserFromAuth();
      return;
    }

    _tripStore.syncCurrentUserFromAuth(user);
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}

class AppAuthScope extends InheritedNotifier<AppAuthController> {
  const AppAuthScope({
    super.key,
    required AppAuthController notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppAuthController of(BuildContext context) {
    final AppAuthScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppAuthScope>();
    assert(scope != null, 'No AppAuthScope found in context');
    return scope!.notifier!;
  }

  static AppAuthController read(BuildContext context) {
    final InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<AppAuthScope>();
    final AppAuthScope? scope = element?.widget as AppAuthScope?;
    assert(scope != null, 'No AppAuthScope found in context');
    return scope!.notifier!;
  }
}
