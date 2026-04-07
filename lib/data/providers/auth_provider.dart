import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../../shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/user_repository.dart';
import '../../core/utils/snackbar_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final UserRepository _userRepo = UserRepository();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuthListener();
  }

  void refreshUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void _initAuthListener() {
    _authRepo.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
      } else {
        // Fetch full profile from Firestore
        final userProfile = await _userRepo.getUser(firebaseUser.uid);
        _currentUser = userProfile;
      }
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepo.loginWithEmail(email, password);
    } catch (e) {
      SnackBarService.showError(e.toString().replaceAll('Exception: ', ''));
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepo.signInWithGoogle();
    } catch (e) {
      SnackBarService.showError(e.toString().replaceAll('Exception: ', ''));
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authRepo.registerUser(
          email: email,
          password: password,
          displayName: displayName,
          username: username);
    } catch (e) {
      SnackBarService.showError(e.toString().replaceAll('Exception: ', ''));
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authRepo.signOut();
  }
}
