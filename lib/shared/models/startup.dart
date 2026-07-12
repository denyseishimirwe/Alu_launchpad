import 'package:cloud_firestore/cloud_firestore.dart';

class Startup {
  const Startup({
    required this.id,
    required this.name,
    required this.description,
    required this.founderId,
    required this.founderName,
    this.category,
    this.logoUrl,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String founderId;
  final String founderName;
  final String? category;
  final String? logoUrl;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Startup.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Startup(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      founderId: data['founderId'] as String? ?? '',
      founderName: data['founderName'] as String? ?? '',
      category: data['category'] as String?,
      logoUrl: data['logoUrl'] as String?,
      location: data['location'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'founderId': founderId,
      'founderName': founderName,
      if (category != null) 'category': category,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (location != null) 'location': location,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
