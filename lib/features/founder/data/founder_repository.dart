import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/opportunity.dart';
import '../../../shared/models/startup.dart';
import '../../student/data/notification_repository.dart';

class FounderRepository {
  FounderRepository({
    FirebaseFirestore? firestore,
    NotificationRepository? notificationRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notifications = notificationRepository ?? NotificationRepository();

  final FirebaseFirestore _firestore;
  final NotificationRepository _notifications;

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
    required Application application,
    required ApplicationStatus status,
  }) async {
    await _firestore
        .collection(FirestoreCollections.applications)
        .doc(application.id)
        .update({
      ApplicationFields.status: status.firestoreValue,
      ApplicationFields.hasUpdate: true,
      ApplicationFields.updatedAt: FieldValue.serverTimestamp(),
    });

    await _notifications.createNotification(
      userId: application.studentId,
      title: 'Application update',
      body:
          'Your application for ${application.opportunityTitle} is now ${status.label}.',
      relatedApplicationId: application.id,
    );
  }

  Future<void> closeOpportunity(String opportunityId) async {
    await _firestore
        .collection(FirestoreCollections.opportunities)
        .doc(opportunityId)
        .update({
      OpportunityFields.status: OpportunityStatus.closed.firestoreValue,
      OpportunityFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
