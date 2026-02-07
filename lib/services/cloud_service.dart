import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudService {
  // Getters to ensure Firebase is initialized
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Listens to login/logout changes
  Stream<User?> get userStream => _auth.authStateChanges();

  // --- AUTHENTICATION ---

  Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  Future<UserCredential?> register(String email, String password) async {
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email, 
      password: password,
    );

    if (credential.user != null) {
      await _db.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'atBatCount': 0,
        'accountStatus': 'free',
        'createdAt': FieldValue.serverTimestamp(),
        'seasons': ['CURRENT SEASON'], 
      });
    }
    return credential;
  }

  Future<void> signOut() async => await _auth.signOut();

  // --- AT-BAT LOG METHODS ---

  // SAVE: Writes to users/[uid]/atBats
  Future<void> logAtBat(Map<String, dynamic> atBatData) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final userDoc = _db.collection('users').doc(user.uid);
    // Use a specific ID if provided in atBatData, otherwise generate one
    final String logId = atBatData['id'] ?? _db.collection('users').doc().id;
    final atBatDoc = userDoc.collection('atBats').doc(logId);

    batch.set(atBatDoc, {
      ...atBatData,
      'id': logId, // Ensure the ID is stored in the doc
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(userDoc, {
      'atBatCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  // FETCH: Reads from users/[uid]/atBats
  Future<List<Map<String, dynamic>>> getAtBatLogs(String uid) async {
    try {
      var snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('atBats')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching logs: $e");
      return [];
    }
  }

  // DELETE: Removes specific log and decrements count
  Future<void> deleteAtBat(String logId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final userDoc = _db.collection('users').doc(user.uid);
    final atBatDoc = userDoc.collection('atBats').doc(logId);

    batch.delete(atBatDoc);
    batch.update(userDoc, {
      'atBatCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  // --- PROFILE & NAME METHODS ---

  Future<void> saveUserProfile(String uid, String name) async {
    await _db.collection('users').doc(uid).set({
      'displayName': name,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getUserName(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['displayName'] as String?;
    }
    return null;
  }

  // --- SEASON METHODS ---

  Future<void> saveSeasons(String uid, List<String> seasons) async {
    await _db.collection('users').doc(uid).set({
      'seasons': seasons,
    }, SetOptions(merge: true));
  }

  Future<List<String>> getSeasons(String uid) async {
    var doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      List<dynamic>? seasons = doc.data()?['seasons'];
      return seasons?.map((e) => e.toString()).toList() ?? [];
    }
    return [];
  }
}