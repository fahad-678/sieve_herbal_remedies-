import '../models/garden.dart';

class GardensData {
  static const List<Garden> gardens = [
    Garden(
      id: 1,
      name: 'Botanical Herb Haven',
      description:
          'Organic medicinal herb garden with guided tours and workshops',
      address: '2847 Wellness Lane, Green Valley',
      distanceLabel: '0.8 mi',
      herbVarieties: 45,
      hours: 'Mon-Sat 9AM-6PM',
      phone: '(555) 234-5678',
      mapTop: 0.35,
      mapLeft: 0.45,
    ),
    Garden(
      id: 2,
      name: 'The Healing Nursery',
      description:
          'Specialty nursery focused on therapeutic and culinary herbs',
      address: '156 Herbal Way, Meadowbrook',
      distanceLabel: '1.2 mi',
      herbVarieties: 38,
      hours: 'Daily 8AM-7PM',
      phone: '(555) 876-5432',
      mapTop: 0.55,
      mapLeft: 0.60,
    ),
    Garden(
      id: 3,
      name: 'Sage & Soil Collective',
      description:
          'Community garden offering herb cultivation classes and seeds',
      address: '891 Garden Path, Riverside',
      distanceLabel: '2.1 mi',
      herbVarieties: 32,
      hours: 'Tue-Sun 10AM-5PM',
      phone: '(555) 432-1098',
      mapTop: 0.42,
      mapLeft: 0.70,
    ),
  ];

  static Garden? getById(int id) {
    for (final garden in gardens) {
      if (garden.id == id) {
        return garden;
      }
    }
    return null;
  }
}
