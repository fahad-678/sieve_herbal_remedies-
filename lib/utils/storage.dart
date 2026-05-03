import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _favoritesKey = 'favorites';
  static const String _trackerLogsKey = 'tracker_logs';
  static Set<String>? _cachedFavorites;

  static Future<Set<String>> getFavorites() async {
    if (_cachedFavorites != null) return _cachedFavorites!;
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey) ?? [];
    _cachedFavorites = favoritesList.toSet();
    return _cachedFavorites!;
  }

  static Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
    _cachedFavorites = favorites;
  }

  static Future<bool> toggleFavorite(String herbId) async {
    final favorites = await getFavorites();
    final wasFavorite = favorites.contains(herbId);

    final updated = Set<String>.from(favorites);
    if (wasFavorite) {
      updated.remove(herbId);
    } else {
      updated.add(herbId);
    }

    // Optimistically update cache and persist
    _cachedFavorites = updated;
    await saveFavorites(updated);
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
