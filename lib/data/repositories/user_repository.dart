import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toJson());
  }

  Future<bool> checkUsernameExists(String username) async {
    final query = await _firestore
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> toggleFollow({
    required String currentUserId,
    required String targetUserId,
    required bool isFollowing,
  }) async {
    final batch = _firestore.batch();

    final followingRef = _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId);
    final followersRef = _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(currentUserId);

    if (isFollowing) {
      batch.delete(followingRef);
      batch.delete(followersRef);
    } else {
      batch.set(followingRef, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(followersRef, {'timestamp': FieldValue.serverTimestamp()});
    }

    // Update counts
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'followingCount': FieldValue.increment(isFollowing ? -1 : 1),
    });
    batch.update(_firestore.collection('users').doc(targetUserId), {
      'followersCount': FieldValue.increment(isFollowing ? -1 : 1),
    });

    await batch.commit();
  }

  Future<bool> checkIsFollowing(String currentUserId, String targetUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('following')
        .doc(targetUserId)
        .get();
    return doc.exists;
  }

  Stream<int> streamFollowersCount(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => (snap.data()?['followersCount'] as int?) ?? 0);
  }
}
