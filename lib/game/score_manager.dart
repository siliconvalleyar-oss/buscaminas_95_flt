import 'package:shared_preferences/shared_preferences.dart';
import 'minefield.dart';

class ScoreRecord {
  final int seconds;
  final int rows;
  final int cols;
  final int mines;
  final bool isNewRecord;

  const ScoreRecord({
    required this.seconds,
    required this.rows,
    required this.cols,
    required this.mines,
    this.isNewRecord = false,
  });
}

class ScoreManager {
  static const _prefix = 'buscaminas_best_';

  static String _key(Difficulty d) => '${_prefix}${d.name}';
  static String _keyRows(Difficulty d) => '${_prefix}${d.name}_rows';
  static String _keyCols(Difficulty d) => '${_prefix}${d.name}_cols';
  static String _keyMines(Difficulty d) => '${_prefix}${d.name}_mines';

  /// Save a new score. Returns true if it's a new record.
  static Future<bool> saveIfBest({
    required Difficulty difficulty,
    required int seconds,
    required int rows,
    required int cols,
    required int mines,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key(difficulty));

    if (current == null || seconds < current) {
      await prefs.setInt(_key(difficulty), seconds);
      await prefs.setInt(_keyRows(difficulty), rows);
      await prefs.setInt(_keyCols(difficulty), cols);
      await prefs.setInt(_keyMines(difficulty), mines);
      return true; // new record!
    }
    return false;
  }

  /// Get the best score for a difficulty, or null if none.
  static Future<ScoreRecord?> getBest(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_key(difficulty));
    if (seconds == null) return null;

    final rows = prefs.getInt(_keyRows(difficulty)) ?? 0;
    final cols = prefs.getInt(_keyCols(difficulty)) ?? 0;
    final mines = prefs.getInt(_keyMines(difficulty)) ?? 0;

    return ScoreRecord(
      seconds: seconds,
      rows: rows,
      cols: cols,
      mines: mines,
    );
  }

  /// Get all best scores.
  static Future<Map<Difficulty, ScoreRecord>> getAll() async {
    final map = <Difficulty, ScoreRecord>{};
    for (final d in Difficulty.values) {
      final record = await getBest(d);
      if (record != null) {
        map[d] = record;
      }
    }
    return map;
  }

  /// Reset all scores.
  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final d in Difficulty.values) {
      await prefs.remove(_key(d));
      await prefs.remove(_keyRows(d));
      await prefs.remove(_keyCols(d));
      await prefs.remove(_keyMines(d));
    }
  }
}
