import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/garden.dart';

class LocationSuggestion {
  final String displayName;
  final double lat;
  final double lng;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lng,
  });

  // Helper to extract just the city name for cleaner UI
  String get shortName => displayName.split(',').first; 
}

class PlacesService {
  static String get apiKey => dotenv.env['LOCATIONIQ_API_KEY'] ?? '';

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // NEW: Geocode a custom text query (e.g., "London", "Central Park") into Lat/Lng
  Future<Map<String, double>> getCoordinatesFromQuery(String query) async {
    final url = Uri.parse(
        'https://us1.locationiq.com/v1/search.php'
        '?key=$apiKey'
        '&q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=1'); // We only need the top result

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        return {
          'lat': double.parse(data[0]['lat'].toString()),
          'lng': double.parse(data[0]['lon'].toString()),
        };
      }
    }
    throw Exception('Could not find location: "$query". Try a different city or area.');
  }

  // NEW: Fetch autocomplete suggestions as the user types
  Future<List<LocationSuggestion>> fetchCitySuggestions(String query) async {
    if (query.trim().length < 3) return []; // Only search if 3+ characters

    final url = Uri.parse(
        'https://api.locationiq.com/v1/autocomplete.php'
        '?key=$apiKey'
        '&q=${Uri.encodeComponent(query)}'
        '&limit=5' // Only show top 5 results
        '&dedupe=1'
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => LocationSuggestion(
          displayName: item['display_name'].toString(),
          lat: double.parse(item['lat'].toString()),
          lng: double.parse(item['lon'].toString()),
        )).toList();
      }
    } catch (e) {
      // Fail silently for autocomplete so it doesn't interrupt the user
    }
    return [];
  }

  // UPDATED: Now accepts optional customLat and customLng
  Future<List<Garden>> fetchNearbyGardens({double? customLat, double? customLng}) async {
    double searchLat;
    double searchLng;

    // Use custom coordinates if provided, otherwise grab device GPS
    if (customLat != null && customLng != null) {
      searchLat = customLat;
      searchLng = customLng;
    } else {
      final position = await _determinePosition();
      searchLat = position.latitude;
      searchLng = position.longitude;
    }
    
    final url = Uri.parse(
        'https://us1.locationiq.com/v1/nearby'
        '?key=$apiKey'
        '&lat=$searchLat'
        '&lon=$searchLng'
        '&tag=leisure:garden,leisure:park'
        '&radius=10000' 
        '&format=json'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      if (results.isEmpty) return [];

      double minLat = double.infinity, maxLat = -double.infinity;
      double minLng = double.infinity, maxLng = -double.infinity;

      for (var p in results) {
        final lat = double.parse(p['lat'].toString());
        final lng = double.parse(p['lon'].toString());
        minLat = min(minLat, lat); maxLat = max(maxLat, lat);
        minLng = min(minLng, lng); maxLng = max(maxLng, lng);
      }

      final latRange = max(maxLat - minLat, 0.001) * 1.2; 
      final lngRange = max(maxLng - minLng, 0.001) * 1.2;

      return results.map<Garden>((place) {
        final lat = double.parse(place['lat'].toString());
        final lng = double.parse(place['lon'].toString());

        final mapTop = 1.0 - ((lat - (minLat - latRange * 0.1)) / latRange);
        final mapLeft = (lng - (minLng - lngRange * 0.1)) / lngRange;

        // Calculate distance from the search center, NOT necessarily the device
        double distanceInMeters = Geolocator.distanceBetween(searchLat, searchLng, lat, lng);
        String distanceLabel = distanceInMeters > 1000 
            ? '${(distanceInMeters / 1000).toStringAsFixed(1)} km' 
            : '${distanceInMeters.round()} m';

        final name = place['name']?.toString() ?? 'Community Garden';
        
        return Garden(
          id: place['place_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: 'A local botanical space found via OpenStreetMap.',
          address: name, 
          distanceLabel: distanceLabel,
          herbVarieties: 10 + Random().nextInt(40),
          hours: 'Check local times',
          phone: 'N/A', 
          mapTop: mapTop.clamp(0.05, 0.95),
          mapLeft: mapLeft.clamp(0.05, 0.95),
          lat: lat,
          lng: lng,
        );
      }).toList();
    } else if (response.statusCode == 404) {
      return []; 
    } else {
      throw Exception('Failed to load gardens. Status code: ${response.statusCode}');
    }
  }
}