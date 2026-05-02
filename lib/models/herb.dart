class Herb {
  final String id;
  final String name;
  final String scientificName;
  final String category;
  final List<String> commonNames;
  final String origin;
  final List<String> primaryBenefits;
  final String briefDescription;
  final String detailedInformation;
  final String traditionalUses;
  final String modernApplications;
  final List<String> activeCompounds;
  final List<String> preparationMethods;
  final String howToUse;
  final String dosage;
  final String bestTimeToTake;
  final String duration;
  final String contraindications;
  final String sideEffects;
  final String drugInteractions;
  final String pregnancyWarning;
  final String nursingWarning;
  final String storage;
  final String shelfLife;
  final List<String> relatedHerbs;
  final String imageUrl;
  final bool isFeatured;

  const Herb({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.commonNames,
    required this.origin,
    required this.primaryBenefits,
    required this.briefDescription,
    required this.detailedInformation,
    required this.traditionalUses,
    required this.modernApplications,
    required this.activeCompounds,
    required this.preparationMethods,
    required this.howToUse,
    required this.dosage,
    required this.bestTimeToTake,
    required this.duration,
    required this.contraindications,
    required this.sideEffects,
    required this.drugInteractions,
    required this.pregnancyWarning,
    required this.nursingWarning,
    required this.storage,
    required this.shelfLife,
    required this.relatedHerbs,
    required this.imageUrl,
    this.isFeatured = false,
  });
}
