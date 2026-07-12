import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/opportunity.dart';
import '../../../shared/models/startup.dart';

class FounderRepository {
  FounderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Opportunity>> watchFounderOpportunities(String founderId) {
    return _firestore
        .collection(FirestoreCollections.opportunities)
        .where('postedBy', isEqualTo: founderId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Opportunity.fromFirestore).toList(),
        );
  }

  Stream<List<Application>> watchFounderApplications(String founderId) {
    return _firestore
        .collection(FirestoreCollections.applications)
        .where('postedBy', isEqualTo: founderId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Application.fromFirestore).toList(),
        );
  }

  Stream<List<Application>> watchOpportunityApplications(String opportunityId) {
    return _firestore
        .collection(FirestoreCollections.applications)
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(Application.fromFirestore).toList(),
        );
  }

  Future<void> createOpportunity({
    required AppUser founder,
    required Startup startup,
    required String title,
    required String description,
    required String category,
    required WorkType workType,
    required int hoursPerWeek,
    required List<String> requiredSkills,
    required DateTime deadline,
  }) async {
    final doc = _firestore.collection(FirestoreCollections.opportunities).doc();
    final opportunity = Opportunity(
      id: doc.id,
      startupId: startup.id,
      startupName: startup.name,
      title: title,
      description: description,
      category: category,
      workType: workType,
      hoursPerWeek: hoursPerWeek,
      requiredSkills: requiredSkills,
      deadline: deadline,
      status: OpportunityStatus.open,
      postedBy: founder.uid,
      createdAt: DateTime.now(),
    );

    await doc.set(opportunity.toFirestore());
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    await _firestore
        .collection(FirestoreCollections.applications)
        .doc(applicationId)
        .update({
      ApplicationFields.status: status.firestoreValue,
      ApplicationFields.hasUpdate: true,
      ApplicationFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
