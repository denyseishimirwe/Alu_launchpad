import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkType {
  remote,
  onCampus,
  hybrid;

  String get firestoreValue {
    switch (this) {
      case WorkType.remote:
        return 'remote';
      case WorkType.onCampus:
        return 'on_campus';
      case WorkType.hybrid:
        return 'hybrid';
    }
  }

  String get label {
    switch (this) {
      case WorkType.remote:
        return 'Remote';
      case WorkType.onCampus:
        return 'On-campus';
      case WorkType.hybrid:
        return 'Hybrid';
    }
  }

  static WorkType fromString(String? value) {
    return WorkType.values.firstWhere(
      (type) => type.firestoreValue == value,
      orElse: () => WorkType.remote,
    );
  }
}

enum OpportunityStatus {
  open,
  closed;

  String get firestoreValue => name;

  static OpportunityStatus fromString(String? value) {
    return OpportunityStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OpportunityStatus.open,
    );
  }
}

class Opportunity {
  const Opportunity({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.category,
    required this.workType,
    required this.hoursPerWeek,
    required this.requiredSkills,
    required this.deadline,
    required this.status,
    required this.postedBy,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String startupId;
  final String startupName;
  final String title;
  final String description;
  final String category;
  final WorkType workType;
  final int hoursPerWeek;
  final List<String> requiredSkills;
  final DateTime deadline;
  final OpportunityStatus status;
  final String postedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Opportunity.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Opportunity(
      id: doc.id,
      startupId: data['startupId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      workType: WorkType.fromString(data['workType'] as String?),
      hoursPerWeek: data['hoursPerWeek'] as int? ?? 0,
      requiredSkills:
          List<String>.from(data['requiredSkills'] as List<dynamic>? ?? []),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: OpportunityStatus.fromString(data['status'] as String?),
      postedBy: data['postedBy'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'category': category,
      'workType': workType.firestoreValue,
      'hoursPerWeek': hoursPerWeek,
      'requiredSkills': requiredSkills,
      'deadline': Timestamp.fromDate(deadline),
      'status': status.firestoreValue,
      'postedBy': postedBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
