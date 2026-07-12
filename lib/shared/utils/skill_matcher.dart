int countSkillMatches(List<String> userSkills, List<String> requiredSkills) {
  if (requiredSkills.isEmpty) return 0;

  final normalizedUserSkills = userSkills
      .map((skill) => skill.trim().toLowerCase())
      .where((skill) => skill.isNotEmpty)
      .toSet();

  var matches = 0;
  for (final required in requiredSkills) {
    if (normalizedUserSkills.contains(required.trim().toLowerCase())) {
      matches++;
    }
  }
  return matches;
}
