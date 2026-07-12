import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_constants.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/startup.dart';

class StartupRepository {
  StartupRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<Startup?> watchFounderStartup(String founderId) {
    return _firestore
        .collection(FirestoreCollections.startups)
        .where('founderId', isEqualTo: founderId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return Startup.fromFirestore(snapshot.docs.first);
    });
  }

  Future<Startup> createStartup({
    required AppUser founder,
    required String name,
    required String description,
    String? location,
    String? category,
  }) async {
    final doc = _firestore.collection(FirestoreCollections.startups).doc();
    final startup = Startup(
      id: doc.id,
      name: name,
      description: description,
      founderId: founder.uid,
      founderName: founder.fullName,
      location: location,
      category: category,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(doc, startup.toFirestore());
    batch.update(
      _firestore.collection(FirestoreCollections.users).doc(founder.uid),
      {
        UserFields.startupId: doc.id,
        UserFields.updatedAt: FieldValue.serverTimestamp(),
      },
    );
    await batch.commit();

    return startup;
  }

  Future<void> updateStartup({
    required String startupId,
    required String name,
    required String description,
    String? location,
    String? category,
  }) async {
    await _firestore.collection(FirestoreCollections.startups).doc(startupId).update({
      StartupFields.name: name,
      StartupFields.description: description,
      if (location != null) StartupFields.location: location,
      if (category != null) StartupFields.category: category,
      StartupFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
