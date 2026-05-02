import '../models/ailment.dart';

class AilmentsData {
  static final List<Ailment> ailments = [
    Ailment(
      id: 'tension-headache',
      name: 'Tension Headache',
      description: 'Tension headaches are the most common type of headache, characterized by a dull, aching pain and tightness across the forehead, temples, or back of the head and neck. Often triggered by stress, poor posture, or muscle tension, they can range from mild to moderate in intensity and may last from 30 minutes to several days.',
      severity: 'Moderate',
      symptoms: [
        'Dull, aching head pain on both sides',
        'Tight band-like pressure around the forehead',
        'Tenderness in scalp, neck, and shoulder muscles',
        'Mild to moderate pain (not throbbing)',
        'Difficulty concentrating',
        'Sensitivity to light or noise (less common)',
      ],
      recommendedHerbIds: ['lavender', 'peppermint', 'ginger'],
      lifestyleTips: [
        'Practice regular stress-reduction techniques',
        'Maintain good posture throughout the day',
        'Stay hydrated and eat balanced meals',
        'Apply warm or cold compress to tense areas',
        'Take regular breaks from screens and repetitive tasks',
      ],
      redFlags: [
        'Sudden, severe headache ("thunderclap" onset)',
        'Headache accompanied by fever, stiff neck, or confusion',
        'Headache after head injury or trauma',
        'Progressive worsening despite treatment',
        'New headache pattern after age 50',
        'Headache with vision changes, weakness, or speech difficulties',
      ],
    ),
    Ailment(
      id: 'anxiety',
      name: 'Anxiety & Stress',
      description: 'Anxiety is characterized by persistent worry, nervousness, or fear that interferes with daily activities. Stress is the body\'s response to challenging situations. Both can manifest physically and emotionally.',
      severity: 'Common',
      symptoms: [
        'Persistent worry or fear',
        'Restlessness or feeling on edge',
        'Difficulty concentrating',
        'Muscle tension',
        'Sleep disturbances',
        'Rapid heartbeat or sweating',
      ],
      recommendedHerbIds: ['ashwagandha', 'lavender', 'chamomile', 'holy-basil'],
      lifestyleTips: [
        'Practice deep breathing exercises',
        'Maintain regular sleep schedule',
        'Engage in regular physical activity',
        'Limit caffeine and alcohol',
        'Practice mindfulness or meditation',
      ],
      redFlags: [
        'Panic attacks interfering with daily life',
        'Suicidal thoughts',
        'Severe chest pain',
        'Inability to function at work or home',
        'Self-medication with drugs or alcohol',
      ],
    ),
    Ailment(
      id: 'insomnia',
      name: 'Insomnia',
      description: 'Insomnia is difficulty falling asleep, staying asleep, or waking too early. It can be acute (short-term) or chronic (ongoing), significantly affecting daytime energy and mood.',
      severity: 'Common',
      symptoms: [
        'Difficulty falling asleep',
        'Waking frequently during the night',
        'Waking too early',
        'Daytime fatigue or sleepiness',
        'Irritability or mood changes',
        'Difficulty concentrating',
      ],
      recommendedHerbIds: ['valerian', 'chamomile', 'lavender', 'ashwagandha'],
      lifestyleTips: [
        'Maintain consistent sleep-wake schedule',
        'Create relaxing bedtime routine',
        'Keep bedroom cool, dark, and quiet',
        'Avoid screens 1 hour before bed',
        'Limit caffeine after 2 PM',
      ],
      redFlags: [
        'Chronic insomnia lasting more than 3 months',
        'Excessive daytime sleepiness affecting safety',
        'Snoring with breathing pauses (sleep apnea)',
        'Depression or anxiety accompanying insomnia',
      ],
    ),
    Ailment(
      id: 'digestive-issues',
      name: 'Digestive Issues',
      description: 'Digestive problems include bloating, gas, indigestion, and stomach discomfort. These can be caused by diet, stress, or underlying conditions.',
      severity: 'Mild',
      symptoms: [
        'Bloating or gas',
        'Abdominal pain or cramping',
        'Nausea',
        'Heartburn or acid reflux',
        'Changes in bowel movements',
        'Loss of appetite',
      ],
      recommendedHerbIds: ['peppermint', 'ginger', 'chamomile', 'turmeric'],
      lifestyleTips: [
        'Eat smaller, more frequent meals',
        'Chew food thoroughly',
        'Stay hydrated',
        'Identify and avoid trigger foods',
        'Manage stress levels',
      ],
      redFlags: [
        'Severe abdominal pain',
        'Blood in stool or vomit',
        'Unintended weight loss',
        'Difficulty swallowing',
        'Persistent vomiting',
      ],
    ),
    Ailment(
      id: 'inflammation',
      name: 'Inflammation',
      description: 'Chronic inflammation can affect joints, muscles, and tissues, causing pain and stiffness. Often associated with arthritis, overuse, or autoimmune conditions.',
      severity: 'Moderate',
      symptoms: [
        'Joint pain or stiffness',
        'Swelling or redness',
        'Reduced range of motion',
        'Warmth in affected area',
        'Muscle aches',
        'Fatigue',
      ],
      recommendedHerbIds: ['turmeric', 'ginger', 'holy-basil'],
      lifestyleTips: [
        'Maintain healthy weight',
        'Engage in low-impact exercise',
        'Follow anti-inflammatory diet',
        'Get adequate sleep',
        'Manage stress levels',
      ],
      redFlags: [
        'Severe joint swelling',
        'Inability to move joint',
        'Fever with joint pain',
        'Rapid progression of symptoms',
        'Signs of infection',
      ],
    ),
  ];

  static Ailment? getAilmentById(String id) {
    try {
      return ailments.firstWhere((ailment) => ailment.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Ailment> searchAilments(String query) {
    final lowerQuery = query.toLowerCase();
    return ailments.where((ailment) {
      return ailment.name.toLowerCase().contains(lowerQuery) ||
          ailment.description.toLowerCase().contains(lowerQuery) ||
          ailment.symptoms.any((s) => s.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
