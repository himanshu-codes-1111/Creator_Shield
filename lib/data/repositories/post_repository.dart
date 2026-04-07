import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPost(PostModel post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toJson());
  }

  Future<PostModel?> getPostById(String id) async {
    final doc = await _firestore.collection('posts').doc(id).get();
    if (doc.exists) {
      return PostModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<List<PostModel>> getUserPosts(String userId) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('creatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();
  }

  Future<List<PostModel>> getGlobalFeed({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => PostModel.fromJson(doc.data())).toList();
  }

  Stream<List<PostModel>> streamGlobalFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => PostModel.fromJson(doc.data())).toList());
  }

  Future<void> updatePostTxId(String postId, String txId) async {
    await _firestore.collection('posts').doc(postId).update({
      'txId': txId,
      'isOnChain': true,
    });
  }
}
