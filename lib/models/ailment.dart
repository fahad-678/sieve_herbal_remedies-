class Ailment {
  final String id;
  final String name;
  final String description;
  final String severity;
  final List<String> symptoms;
  final List<String> recommendedHerbIds;
  final List<String> lifestyleTips;
  final List<String> redFlags;

  const Ailment({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    required this.symptoms,
    required this.recommendedHerbIds,
    required this.lifestyleTips,
    required this.redFlags,
  });
}
