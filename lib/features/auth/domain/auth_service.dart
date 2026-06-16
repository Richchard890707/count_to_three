import 'models/app_user.dart';

abstract interface class AuthService {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
}
