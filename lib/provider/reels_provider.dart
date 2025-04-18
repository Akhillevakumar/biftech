import 'package:biftech/services/database_helper.dart';
import 'package:flutter/material.dart';

class ReelsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _initialized = false;
  late List<bool> _liked;
  final Map<int, List<Map<String, dynamic>>> _commentsCache = {};

  List<bool> get liked => _liked;
  Map<int, List<Map<String, dynamic>>> get commentsCache => _commentsCache;

   void init(int count) {
    if (_initialized) return;
    _liked = List<bool>.filled(count, false);

    // Seed 3 dummy comments for the first video (index 0)
    _commentsCache[0] = [
      {
        'text': 'Awesome reel, loved it! — Alice',
        'timestamp': DateTime.now()
            .subtract(Duration(minutes: 5))
            .toIso8601String(),
      },
      {
        'text': 'Great job! — Bob',
        'timestamp': DateTime.now()
            .subtract(Duration(hours: 1))
            .toIso8601String(),
      },
      {
        'text': '🔥🔥🔥 — Carol',
        'timestamp':
        DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      },
    ];

    _initialized = true;
    notifyListeners();
  }

  void toggleLike(int idx) {
    _liked[idx] = !_liked[idx];
    notifyListeners();
  }

  /// Load from sqflite, but if none exist for idx=0, keep the dummy
  Future<void> loadComments(int idx) async {
    final list = await _dbHelper.getComments(idx);
    if (idx == 0 && _commentsCache[0]!.isNotEmpty && list.isEmpty) {
      // keeping seeded dummy
      return;
    }
    _commentsCache[idx] = list;
    notifyListeners();
  }

  Future<void> addComment(int idx, String text) async {
    await _dbHelper.insertComment(idx, text);
    await loadComments(idx);
  }
}
