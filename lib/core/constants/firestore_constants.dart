/// Firestore collection and field names for LaunchPad ALU.
class FirestoreCollections {
  static const users = 'users';
  static const startups = 'startups';
  static const opportunities = 'opportunities';
  static const applications = 'applications';
  static const notifications = 'notifications';
}

class UserFields {
  static const email = 'email';
  static const fullName = 'fullName';
  static const role = 'role';
  static const photoUrl = 'photoUrl';
  static const skills = 'skills';
  static const degree = 'degree';
  static const year = 'year';
  static const location = 'location';
  static const startupId = 'startupId';
  static const savedOpportunityIds = 'savedOpportunityIds';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}

class StartupFields {
  static const name = 'name';
  static const description = 'description';
  static const founderId = 'founderId';
  static const founderName = 'founderName';
  static const category = 'category';
  static const logoUrl = 'logoUrl';
  static const location = 'location';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}

class OpportunityFields {
  static const startupId = 'startupId';
  static const startupName = 'startupName';
  static const title = 'title';
  static const description = 'description';
  static const category = 'category';
  static const workType = 'workType';
  static const hoursPerWeek = 'hoursPerWeek';
  static const requiredSkills = 'requiredSkills';
  static const deadline = 'deadline';
  static const status = 'status';
  static const postedBy = 'postedBy';
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';
}

class ApplicationFields {
  static const opportunityId = 'opportunityId';
  static const opportunityTitle = 'opportunityTitle';
  static const startupId = 'startupId';
  static const startupName = 'startupName';
  static const studentId = 'studentId';
  static const studentName = 'studentName';
  static const postedBy = 'postedBy';
  static const status = 'status';
  static const hasUpdate = 'hasUpdate';
  static const appliedAt = 'appliedAt';
  static const updatedAt = 'updatedAt';
}

class NotificationFields {
  static const title = 'title';
  static const body = 'body';
  static const read = 'read';
  static const relatedApplicationId = 'relatedApplicationId';
  static const createdAt = 'createdAt';
}
