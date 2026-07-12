import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Opportunity>> watchOpenOpportunities() {
    return _firestore
        .collection(FirestoreCollections.opportunities)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(Opportunity.fromFirestore)
              .where((item) => item.status == OpportunityStatus.open)
              .toList(),
        );
  }

  Stream<Opportunity?> watchOpportunity(String id) {
    return _firestore
        .collection(FirestoreCollections.opportunities)
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return Opportunity.fromFirestore(snapshot);
    });
  }
}

List<Opportunity> filterOpportunities({
  required List<Opportunity> opportunities,
  String searchQuery = '',
  String category = 'All',
}) {
  final query = searchQuery.trim().toLowerCase();

  return opportunities.where((opportunity) {
    final matchesCategory =
        category == 'All' || opportunity.category == category;
    if (!matchesCategory) return false;

    if (query.isEmpty) return true;

    final haystack =
        '${opportunity.title} ${opportunity.startupName} ${opportunity.description} ${opportunity.requiredSkills.join(' ')}'
            .toLowerCase();
    return haystack.contains(query);
  }).toList();
}
