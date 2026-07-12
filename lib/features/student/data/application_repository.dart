import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/application.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/opportunity.dart';

class ApplicationRepository {
  ApplicationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Application>> watchStudentApplications(String studentId) {
    return _firestore
        .collection(FirestoreCollections.applications)
        .where('studentId', isEqualTo: studentId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Application.fromFirestore).toList(),
        );
  }

  Future<bool> hasApplied({
    required String studentId,
    required String opportunityId,
  }) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.applications)
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> apply({
    required Opportunity opportunity,
    required AppUser student,
  }) async {
    final alreadyApplied = await hasApplied(
      studentId: student.uid,
      opportunityId: opportunity.id,
    );

    if (alreadyApplied) {
      throw StateError('You have already applied to this opportunity.');
    }

    final application = Application(
      id: '',
      opportunityId: opportunity.id,
      opportunityTitle: opportunity.title,
      startupId: opportunity.startupId,
      startupName: opportunity.startupName,
      studentId: student.uid,
      studentName: student.fullName,
      postedBy: opportunity.postedBy,
      status: ApplicationStatus.applied,
      appliedAt: DateTime.now(),
    );

    await _firestore
        .collection(FirestoreCollections.applications)
        .add(application.toFirestore());
  }

  Future<void> markAsRead(String applicationId) async {
    await _firestore
        .collection(FirestoreCollections.applications)
        .doc(applicationId)
        .update({
      ApplicationFields.hasUpdate: false,
      ApplicationFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }

  Future<void> withdraw(String applicationId) async {
    await _firestore
        .collection(FirestoreCollections.applications)
        .doc(applicationId)
        .delete();
  }
}
