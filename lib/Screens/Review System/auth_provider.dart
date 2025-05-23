// lib/providers/auth_providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exposes the FirebaseAuth instance.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Streams the auth state (logged in / out).
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Synchronously gives you the current signed-in [User].
/// Throws if there is no user (you can catch or guard against this).
final authUserProvider = Provider<User>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user!,
    orElse: () => throw StateError('No authenticated user.'),
  );
});
