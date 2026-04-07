import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_repository.dart';
import '../../shared/models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepo = UserRepository();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> loginWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Fetch creator profile from firestore
      if (cred.user != null) {
        return await _userRepo.getUser(cred.user!.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(cred);
      final user = userCred.user;

      if (user != null) {
        // check if user exists
        final existingUser = await _userRepo.getUser(user.uid);
        if (existingUser != null) {
          return existingUser;
        } else {
          // create a new profile for Google user
          final newUser = UserModel(
            id: user.uid,
            displayName: user.displayName ?? 'Creator',
            username: user.email != null ? user.email!.split('@').first : 'creator_${user.uid.substring(0, 5)}',
            avatarUrl: user.photoURL,
            joinedAt: DateTime.now(),
          );
          await _userRepo.createUserDocument(newUser);
          return newUser;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> registerUser({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    try {
      // 1. Create auth user
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;

      if (user != null) {
        // 2. Build creator model
        final newUser = UserModel(
          id: user.uid,
          displayName: displayName,
          username: username.toLowerCase(),
          joinedAt: DateTime.now(),
        );
        // 3. Save profile to Firestore
        await _userRepo.createUserDocument(newUser);
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
