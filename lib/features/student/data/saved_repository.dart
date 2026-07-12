import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';

class SavedRepository {
  SavedRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> toggleSaved({
    required String userId,
    required String opportunityId,
    required List<String> currentSaved,
  }) async {
    final updated = currentSaved.contains(opportunityId)
        ? currentSaved.where((id) => id != opportunityId).toList()
        : [...currentSaved, opportunityId];

    await _firestore.collection(FirestoreCollections.users).doc(userId).update({
      UserFields.savedOpportunityIds: updated,
      UserFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
