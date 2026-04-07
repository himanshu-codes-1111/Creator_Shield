import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/comment_model.dart';

class CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CommentModel>> streamPostComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => CommentModel.fromJson(doc.data())).toList());
  }

  Future<void> addComment(CommentModel comment) async {
    final batch = _firestore.batch();
    
    // Add comment to subcollection
    final commentRef = _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .doc(comment.id);
    batch.set(commentRef, comment.toJson());
    
    // Increment properties on Post
    final postRef = _firestore.collection('posts').doc(comment.postId);
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});
    
    await batch.commit();
  }
}
