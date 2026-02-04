import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudService {
  // We use getters here to ensure Firebase is fully initialized before we touch it
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Listens to login/logout changes automatically
  Stream<User?> get userStream => _auth.authStateChanges();

  // Basic Email/Password Login
  Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  // Register New User
  Future<UserCredential?> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async => await _auth.signOut();
}