import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _favoritesKey = 'favorites';
  static const String _trackerLogsKey = 'tracker_logs';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
    return favoritesList.toSet();
  }

  static Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }

  static Future<bool> toggleFavorite(String herbId) async {
    final favorites = await getFavorites();
    final wasFavorite = favorites.contains(herbId);
    
    if (wasFavorite) {
      favorites.remove(herbId);
    } else {
      favorites.add(herbId);
    }
    
    await saveFavorites(favorites);
    return !wasFavorite;
  }

  static Future<bool> isFavorite(String herbId) async {
    final favorites = await getFavorites();
    return favorites.contains(herbId);
  }

  static Future<List<String>> getTrackerLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_trackerLogsKey) ?? [];
  }

  static Future<void> saveTrackerLogs(List<String> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_trackerLogsKey, logs);
  }

  static Future<void> addTrackerLog(String log) async {
    final logs = await getTrackerLogs();
    logs.insert(0, log);
    await saveTrackerLogs(logs);
  }

  static Future<void> deleteTrackerLog(int index) async {
    final logs = await getTrackerLogs();
    if (index >= 0 && index < logs.length) {
      logs.removeAt(index);
      await saveTrackerLogs(logs);
    }
  }

  static Future<void> clearAllTrackerLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trackerLogsKey);
  }
}
