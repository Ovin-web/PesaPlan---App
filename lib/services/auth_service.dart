import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔁 Auth state stream
  Stream<User?> get user => _auth.authStateChanges();

  /// 🆕 SIGN UP
  Future<User?> signUp(String email, String password) async {
    try {
      final UserCredential result =
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _logAuthError("SIGN UP", e);
      return null;
    } catch (e) {
      print("❌ UNKNOWN SIGN UP ERROR → $e");
      return null;
    }
  }

  /// 🔐 SIGN IN
  Future<User?> signIn(String email, String password) async {
    try {
      final UserCredential result =
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = result.user;

      if (user == null) return null;

      if (!user.emailVerified) {
        print("⚠️ EMAIL NOT VERIFIED");
        // You may choose to block login in UI if needed
      }

      return user;
    } on FirebaseAuthException catch (e) {
      _logAuthError("LOGIN", e);
      return null;
    } catch (e) {
      print("❌ UNKNOWN LOGIN ERROR → $e");
      return null;
    }
  }

  /// 🚪 SIGN OUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("❌ LOGOUT ERROR → $e");
    }
  }

  /// 🔑 RESET PASSWORD
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _logAuthError("RESET PASSWORD", e);
      return false;
    }
  }

  /// 🗑 DELETE ACCOUNT
  Future<bool> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.delete();
      return true;
    } on FirebaseAuthException catch (e) {
      _logAuthError("DELETE ACCOUNT", e);
      return false;
    }
  }

  /// 🔐 RE-AUTHENTICATE
  Future<bool> reAuthenticate(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: password.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      _logAuthError("REAUTH", e);
      return false;
    }
  }

  /// 🧠 Centralized error logging
  void _logAuthError(String action, FirebaseAuthException e) {
    print(
      "❌ $action ERROR → ${e.code}: ${e.message}",
    );
  }
}
