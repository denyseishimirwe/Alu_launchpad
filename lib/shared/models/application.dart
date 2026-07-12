import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  applied,
  review,
  shortlisted,
  accepted,
  rejected;

  String get firestoreValue => name;

  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.review:
        return 'Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  static ApplicationStatus fromString(String? value) {
    return ApplicationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ApplicationStatus.applied,
    );
  }
}

class Application {
  const Application({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.postedBy,
    required this.status,
    this.hasUpdate = false,
    this.appliedAt,
    this.updatedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String postedBy;
  final ApplicationStatus status;
  final bool hasUpdate;
  final DateTime? appliedAt;
  final DateTime? updatedAt;

  factory Application.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Application(
      id: doc.id,
      opportunityId: data['opportunityId'] as String? ?? '',
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      postedBy: data['postedBy'] as String? ?? '',
      status: ApplicationStatus.fromString(data['status'] as String?),
      hasUpdate: data['hasUpdate'] as bool? ?? false,
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupId': startupId,
      'startupName': startupName,
      'studentId': studentId,
      'studentName': studentName,
      'postedBy': postedBy,
      'status': status.firestoreValue,
      'hasUpdate': hasUpdate,
      'appliedAt': appliedAt != null
          ? Timestamp.fromDate(appliedAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
