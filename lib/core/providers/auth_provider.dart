import 'package:count_to_three/features/auth/data/firebase_auth_service.dart';
import 'package:count_to_three/features/auth/domain/auth_service.dart';
import 'package:count_to_three/features/auth/domain/models/app_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) => FirebaseAuthService();

@Riverpod(keepAlive: true)
Stream<AppUser?> authState(AuthStateRef ref) =>
    ref.watch(authServiceProvider).authStateChanges;

@riverpod
AppUser? currentUser(CurrentUserRef ref) =>
    ref.watch(authStateProvider).valueOrNull;
