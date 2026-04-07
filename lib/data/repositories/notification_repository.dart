import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Listen to all public notifications
  Stream<List<NotificationModel>> streamGlobalNotifications() {
    return _firestore
        .collection('global_notifications')
        .orderBy('time', descending: true)
        .limit(40)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NotificationModel.fromJson(doc.data()))
            .toList());
  }

  /// Create a public notification visible to everyone
  Future<void> sendGlobalNotification({
    required String title,
    required String subtitle,
    required String type,
  }) async {
    final id = _uuid.v4();
    final model = NotificationModel(
      id: id,
      title: title,
      subtitle: subtitle,
      type: type,
      time: DateTime.now(),
    );

    await _firestore
        .collection('global_notifications')
        .doc(id)
        .set(model.toJson());
  }
}
