import 'package:escrow_app/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 
  firebase_auth.User? get firebaseUser => _auth.currentUser;

  
  AppUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'Unknown',
    );
  }

  
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Unknown',
      );
    });
  }

  AppUser? get user {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return AppUser(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'Unknown',
    );
  }

  
  Future<void> signUp(String email, String password, String name) async {
    try {
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
        
      );
      final user = AppUser(
        id: userCredential.user!.uid,
        email: email,
        name: name,
      );
      
      await _firestore.collection('users').doc(user.id).set(user.toMap());
      
    } catch (e) {
      
      throw Exception('Failed to sign up: $e');
    }
  }

  
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }


  Future<void> signOut() async => await _auth.signOut();
}
