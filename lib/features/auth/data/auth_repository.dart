import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/user_role.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  bool _googleSignInInitialized = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<void> ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return AppUser.fromFirestore(snapshot);
    });
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();
    if (!snapshot.exists) return null;
    return AppUser.fromFirestore(snapshot);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Account could not be created.',
      );
    }

    await _createUserProfile(
      uid: user.uid,
      email: email,
      fullName: fullName,
      photoUrl: user.photoURL,
    );
  }

  Future<void> signInWithGoogle() async {
    await ensureGoogleSignInInitialized();

    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final googleAuth = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      final existingProfile = await getUserProfile(user.uid);
      if (existingProfile == null) {
        await _createUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          fullName: user.displayName ?? 'ALU User',
          photoUrl: user.photoURL,
        );
      }
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    }
  }

  Future<void> setUserRole({
    required String uid,
    required UserRole role,
  }) async {
    final update = <String, dynamic>{
      UserFields.role: role.firestoreValue,
      UserFields.updatedAt: FieldValue.serverTimestamp(),
    };

    if (role == UserRole.student) {
      update[UserFields.skills] = const [
        'Flutter',
        'Dart',
        'Figma',
        'UI Design',
        'User Research',
      ];
    }

    await _firestore.collection(FirestoreCollections.users).doc(uid).update(update);
  }

  Future<void> signOut() async {
    await ensureGoogleSignInInitialized();
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  Future<void> _createUserProfile({
    required String uid,
    required String email,
    required String fullName,
    String? photoUrl,
  }) async {
    final appUser = AppUser(
      uid: uid,
      email: email,
      fullName: fullName,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .set(appUser.toFirestore());
  }

  String mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}

bool isAluEmail(String email) {
  final normalized = email.trim().toLowerCase();
  return normalized.endsWith('@alueducation.com') ||
      normalized.endsWith('@africanleadershipuniversity.org');
}
