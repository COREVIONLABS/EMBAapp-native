import 'package:flutter/foundation.dart';

/// Simple global app state (fake data, no backend).
class AppState extends ChangeNotifier {
  int points = 2850;
  int tickets = 12;
  bool spunToday = false;
  bool scratchedToday = false;

  void addPoints(int p) {
    points += p;
    notifyListeners();
  }

  void addTickets(int t) {
    tickets += t;
    notifyListeners();
  }

  void markSpun() { spunToday = true; notifyListeners(); }
  void markScratched() { scratchedToday = true; notifyListeners(); }

  // Demo helper to replay
  void resetDaily() { spunToday = false; scratchedToday = false; notifyListeners(); }
}

final appState = AppState();
