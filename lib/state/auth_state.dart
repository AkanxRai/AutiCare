import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier() : super(null) {
    _initialize();
  }

  void _initialize() {
    // Listen to FirebaseAuth changes and update the state
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user?.uid; // Update the state with the user's UID or null
    });
  }
}

// Riverpod provider for the AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier();
});
