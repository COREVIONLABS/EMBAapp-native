import 'package:flutter/foundation.dart';

/// Tracks the once-a-day games (spin / scratch) and the fan's streak so the app
/// has a real "come back tomorrow" hook. Session-scoped in this prototype (no
/// persistence) — enough to demo the daily mechanic and streak.
class DailyGamesStore extends ChangeNotifier {
  bool spinDone = false;
  bool scratchDone = false;
  int streakDays = 5;

  void playSpin() {
    if (spinDone) return;
    spinDone = true;
    notifyListeners();
  }

  void playScratch() {
    if (scratchDone) return;
    scratchDone = true;
    notifyListeners();
  }
}

final dailyGames = DailyGamesStore();
