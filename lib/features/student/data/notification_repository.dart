import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/app_notification.dart';

class NotificationRepository {
  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notifications(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.notifications);
  }

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _notifications(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(AppNotification.fromFirestore).toList(),
        );
  }

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String? relatedApplicationId,
  }) async {
    final notification = AppNotification(
      id: '',
      title: title,
      body: body,
      relatedApplicationId: relatedApplicationId,
      createdAt: DateTime.now(),
    );

    await _notifications(userId).add(notification.toFirestore());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _notifications(userId).doc(notificationId).update({
      NotificationFields.read: true,
    });
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notifications(userId)
        .where(NotificationFields.read, isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {NotificationFields.read: true});
    }
    await batch.commit();
  }
}
