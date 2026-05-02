class Preparation {
  final String id;
  final String name;
  final String description;
  final List<String> bestFor;
  final int timeInSeconds;
  final String timeLabel;
  final List<String> steps;
  final List<String> tips;

  const Preparation({
    required this.id,
    required this.name,
    required this.description,
    required this.bestFor,
    required this.timeInSeconds,
    required this.timeLabel,
    required this.steps,
    required this.tips,
  });
}
