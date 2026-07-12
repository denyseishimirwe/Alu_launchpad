import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.role,
    this.photoUrl,
    this.skills = const [],
    this.degree,
    this.year,
    this.location,
    this.startupId,
    this.createdAt,
    this.updatedAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole? role;
  final String? photoUrl;
  final List<String> skills;
  final String? degree;
  final int? year;
  final String? location;
  final String? startupId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isStudent => role == UserRole.student;
  bool get isFounder => role == UserRole.founder;
  bool get hasRole => role != null;

  AppUser copyWith({
    String? fullName,
    UserRole? role,
    String? photoUrl,
    List<String>? skills,
    String? degree,
    int? year,
    String? location,
    String? startupId,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      skills: skills ?? this.skills,
      degree: degree ?? this.degree,
      year: year ?? this.year,
      location: location ?? this.location,
      startupId: startupId ?? this.startupId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String?),
      photoUrl: data['photoUrl'] as String?,
      skills: List<String>.from(data['skills'] as List<dynamic>? ?? []),
      degree: data['degree'] as String?,
      year: data['year'] as int?,
      location: data['location'] as String?,
      startupId: data['startupId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      if (role != null) 'role': role!.firestoreValue,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'skills': skills,
      if (degree != null) 'degree': degree,
      if (year != null) 'year': year,
      if (location != null) 'location': location,
      if (startupId != null) 'startupId': startupId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
