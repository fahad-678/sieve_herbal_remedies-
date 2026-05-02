import '../models/preparation.dart';

class PreparationsData {
  static final Map<String, Preparation> preparations = {
    'tea-infusion': Preparation(
      id: 'tea-infusion',
      name: 'Tea Infusion',
      description: 'A gentle method for extracting delicate herbal properties using hot water.',
      bestFor: ['Leaves', 'Flowers', 'Soft herbs', 'Daily wellness'],
      timeInSeconds: 300,
      timeLabel: '5 minutes',
      steps: [
        'Add 1–2 teaspoons of dried herbs to a cup',
        'Pour hot water (200°F) over the herbs',
        'Cover and steep for 5–10 minutes',
        'Strain and enjoy warm',
      ],
      tips: [
        'Use water at 200-210°F for optimal extraction',
        'Covering while steeping preserves volatile oils',
        'For iced tea, double the herb amount and steep as usual, then pour over ice',
      ],
    ),
    'tincture': Preparation(
      id: 'tincture',
      name: 'Tincture',
      description: 'A concentrated herbal extract made by soaking herbs in alcohol or glycerin.',
      bestFor: ['Roots', 'Barks', 'Seeds', 'Long-term storage'],
      timeInSeconds: 0,
      timeLabel: '4–6 weeks',
      steps: [
        'Place dried herbs in a clean glass jar',
        'Cover completely with alcohol or glycerin',
        'Seal and store in a cool dark place',
        'Shake daily and strain after 4–6 weeks',
      ],
      tips: [
        'Use 80-proof vodka or glycerin as a solvent',
        'Label with herb name and date started',
        'Store finished tinctures in amber bottles away from light',
      ],
    ),
    'salve': Preparation(
      id: 'salve',
      name: 'Salve',
      description: 'A topical herbal preparation made with infused oil and beeswax.',
      bestFor: ['Skin support', 'Dryness', 'Minor irritation'],
      timeInSeconds: 1200,
      timeLabel: '20 minutes',
      steps: [
        'Warm herb-infused oil over low heat',
        'Add beeswax and stir until melted',
        'Pour into a clean container',
        'Let it cool until firm',
      ],
      tips: [
        'Use ratio of 1 oz beeswax to 8 oz infused oil',
        'Test consistency by cooling a small amount on a cold plate',
        'Store in tins or jars away from heat',
      ],
    ),
    'compress': Preparation(
      id: 'compress',
      name: 'Compress',
      description: 'A cloth soaked in strong herbal infusion and applied to the skin.',
      bestFor: ['Localized comfort', 'Topical support', 'Muscle tension'],
      timeInSeconds: 600,
      timeLabel: '10 minutes',
      steps: [
        'Prepare a strong herbal tea',
        'Soak a clean cloth in the warm liquid',
        'Apply the cloth to the affected area',
        'Reapply as needed',
      ],
      tips: [
        'Use hot compresses for muscle tension',
        'Use cool compresses for inflammation',
        'Alternate hot and cold for circulation support',
      ],
    ),
    'decoction': Preparation(
      id: 'decoction',
      name: 'Decoction',
      description: 'A simmering method for extracting properties from hard plant materials.',
      bestFor: ['Roots', 'Barks', 'Berries', 'Dense materials'],
      timeInSeconds: 1200,
      timeLabel: '20 minutes',
      steps: [
        'Add 2 tablespoons of herb to 2 cups cold water',
        'Bring to a boil, then reduce to simmer',
        'Simmer covered for 20–30 minutes',
        'Strain and use while warm',
      ],
      tips: [
        'Harder materials require longer simmering',
        'Reduce liquid by half for stronger extraction',
        'Store in refrigerator for up to 2 days',
      ],
    ),
    'poultice': Preparation(
      id: 'poultice',
      name: 'Poultice',
      description: 'Fresh or dried herbs applied directly to the skin for topical benefit.',
      bestFor: ['Fresh wounds', 'Inflammation', 'Drawing out toxins'],
      timeInSeconds: 900,
      timeLabel: '15 minutes',
      steps: [
        'Crush or chop fresh herbs (or rehydrate dried)',
        'Mix with a small amount of warm water',
        'Apply directly to affected area',
        'Wrap with clean cloth and leave for 15–20 minutes',
      ],
      tips: [
        'Fresh herbs work best for poultices',
        'Apply to clean skin only',
        'Change every few hours if needed',
      ],
    ),
    'herbal-oil': Preparation(
      id: 'herbal-oil',
      name: 'Herbal Oil',
      description: 'Herbs infused in carrier oil for topical massage and skin care.',
      bestFor: ['Massage', 'Skin nourishment', 'Base for salves'],
      timeInSeconds: 0,
      timeLabel: '2–4 weeks',
      steps: [
        'Fill a jar with dried herbs',
        'Cover completely with carrier oil',
        'Seal and place in warm sunny spot',
        'Shake daily, strain after 2–4 weeks',
      ],
      tips: [
        'Use olive, sweet almond, or jojoba oil',
        'Ensure herbs are completely dry to prevent mold',
        'Store finished oil in cool dark place',
      ],
    ),
    'syrup': Preparation(
      id: 'syrup',
      name: 'Herbal Syrup',
      description: 'A sweet herbal preparation combining decoction with honey or sugar.',
      bestFor: ['Throat support', 'Cough relief', 'Children-friendly'],
      timeInSeconds: 1800,
      timeLabel: '30 minutes',
      steps: [
        'Make a strong decoction of herbs',
        'Strain and measure liquid',
        'Add equal parts honey or sugar',
        'Simmer until syrupy, bottle while warm',
      ],
      tips: [
        'Use raw honey for additional benefits',
        'Add lemon juice for preservation',
        'Store in refrigerator for up to 6 months',
      ],
    ),
  };

  static Preparation? getPreparationById(String id) {
    return preparations[id];
  }

  static List<Preparation> getAllPreparations() {
    return preparations.values.toList();
  }
}
