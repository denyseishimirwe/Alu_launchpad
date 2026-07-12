import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firestore_constants.dart';
import '../../shared/models/opportunity.dart';
import '../../shared/models/startup.dart';

class SampleDataSeeder {
  SampleDataSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedIfEmpty() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.opportunities)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    final now = DateTime.now();

    final startups = [
      Startup(
        id: 'nexus-digital-health',
        name: 'Nexus Digital Health',
        description: 'Digital health startup improving access to care.',
        founderId: 'seed-founder',
        founderName: 'ALU Founder',
        category: 'Design',
        location: 'Kigali',
        createdAt: now,
      ),
      Startup(
        id: 'kreat-connect',
        name: 'Kreat Connect',
        description: 'Creative agency connecting African brands to talent.',
        founderId: 'seed-founder',
        founderName: 'ALU Founder',
        category: 'Design',
        location: 'Remote',
        createdAt: now,
      ),
      Startup(
        id: 'solarpulse',
        name: 'SolarPulse',
        description: 'Clean energy analytics for East African markets.',
        founderId: 'seed-founder',
        founderName: 'ALU Founder',
        category: 'Data',
        location: 'Kigali',
        createdAt: now,
      ),
      Startup(
        id: 'greenloop',
        name: 'GreenLoop',
        description: 'Sustainability startup focused on circular economies.',
        founderId: 'seed-founder',
        founderName: 'ALU Founder',
        category: 'Marketing',
        location: 'Kigali',
        createdAt: now,
      ),
    ];

    for (final startup in startups) {
      batch.set(
        _firestore.collection(FirestoreCollections.startups).doc(startup.id),
        startup.toFirestore(),
      );
    }

    final opportunities = [
      Opportunity(
        id: 'product-design-fellow',
        startupId: 'nexus-digital-health',
        startupName: 'Nexus Digital Health',
        title: 'Product Design Fellow',
        description:
            'Join our product team to shape user experiences for patients and clinicians. You will conduct user research, create prototypes, and collaborate with engineering.',
        category: 'Design',
        workType: WorkType.remote,
        hoursPerWeek: 18,
        requiredSkills: const [
          'Figma',
          'UI Design',
          'Prototyping',
          'User Research',
          'Design Systems',
        ],
        deadline: now.add(const Duration(days: 45)),
        status: OpportunityStatus.open,
        postedBy: 'seed-founder',
        createdAt: now,
      ),
      Opportunity(
        id: 'product-designer',
        startupId: 'kreat-connect',
        startupName: 'Kreat Connect',
        title: 'Product Designer',
        description:
            'Support brand and product design projects for early-stage startups across Africa.',
        category: 'Design',
        workType: WorkType.remote,
        hoursPerWeek: 15,
        requiredSkills: const ['Figma', 'UI Design', 'Prototyping'],
        deadline: now.add(const Duration(days: 30)),
        status: OpportunityStatus.open,
        postedBy: 'seed-founder',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Opportunity(
        id: 'data-analyst-intern',
        startupId: 'solarpulse',
        startupName: 'SolarPulse',
        title: 'Data Analyst Intern',
        description:
            'Analyze solar adoption data and build dashboards that guide expansion decisions.',
        category: 'Data',
        workType: WorkType.onCampus,
        hoursPerWeek: 12,
        requiredSkills: const ['Python', 'Data Analysis', 'SQL'],
        deadline: now.add(const Duration(days: 21)),
        status: OpportunityStatus.open,
        postedBy: 'seed-founder',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      Opportunity(
        id: 'social-media-assistant',
        startupId: 'greenloop',
        startupName: 'GreenLoop',
        title: 'Social Media Assistant',
        description:
            'Create content and manage campaigns that grow our community of climate-conscious students.',
        category: 'Marketing',
        workType: WorkType.hybrid,
        hoursPerWeek: 10,
        requiredSkills: const ['Marketing', 'Public Speaking'],
        deadline: now.add(const Duration(days: 14)),
        status: OpportunityStatus.open,
        postedBy: 'seed-founder',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Opportunity(
        id: 'flutter-developer',
        startupId: 'nexus-digital-health',
        startupName: 'Nexus Digital Health',
        title: 'Flutter Developer',
        description:
            'Build mobile features for our patient app using Flutter, Firebase, and modern state management.',
        category: 'Engineering',
        workType: WorkType.onCampus,
        hoursPerWeek: 20,
        requiredSkills: const ['Flutter', 'Dart', 'Firebase'],
        deadline: now.add(const Duration(days: 60)),
        status: OpportunityStatus.open,
        postedBy: 'seed-founder',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ];

    for (final opportunity in opportunities) {
      batch.set(
        _firestore
            .collection(FirestoreCollections.opportunities)
            .doc(opportunity.id),
        opportunity.toFirestore(),
      );
    }

    await batch.commit();
  }
}
