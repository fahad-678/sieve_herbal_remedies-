// lib/models/garden.dart
class Garden {
  final String id;
  final String name;
  final String description;
  final String address;
  final String distanceLabel;
  final int herbVarieties;
  final String hours;
  final String phone;
  final double mapTop;
  final double mapLeft;
  final double lat;
  final double lng;

  const Garden({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.distanceLabel,
    required this.herbVarieties,
    required this.hours,
    required this.phone,
    required this.mapTop,
    required this.mapLeft,
    required this.lat,
    required this.lng,
  });
}