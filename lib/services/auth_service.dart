import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithEmailPasswordCheckedRole({
    required String email,
    required String password,
    required bool isProvider,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user?.uid;
    if (uid == null) return cred;

    final expectedCollection = isProvider ? 'providers' : 'users';
    final otherCollection = isProvider ? 'users' : 'providers';

    final expectedSnap = await _db
        .collection(expectedCollection)
        .doc(uid)
        .get();
    if (expectedSnap.exists) return cred;

    final otherSnap = await _db.collection(otherCollection).doc(uid).get();
    await _auth.signOut();

    if (otherSnap.exists) {
      throw FirebaseAuthException(
        code: 'role-mismatch',
        message: isProvider
            ? 'This account is registered as a user. Please switch to User login.'
            : 'This account is registered as a provider. Please switch to Provider login.',
      );
    }

    throw FirebaseAuthException(
      code: 'role-unknown',
      message: 'Account role is not set up. Please sign up again.',
    );
  }

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() => _auth.signOut();
}

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account is disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'network-request-failed':
        return 'Network error. Check your internet.';
      case 'role-mismatch':
      case 'role-unknown':
        return error.message ?? 'Authentication failed.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
  return 'Authentication failed.';
}
