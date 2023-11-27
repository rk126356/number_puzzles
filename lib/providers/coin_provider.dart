import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinProvider with ChangeNotifier {
  int _coins = 100;

  CoinProvider() {
    _loadFromPrefs();
  }

  int get coins => _coins;

  set coins(int value) {
    _coins = value;
    _saveToPrefs();
    notifyListeners();
  }

  void addCoin(int value) {
    _coins += value;
    _saveToPrefs();
    notifyListeners();
  }

  void subtractCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedHearts = prefs.getInt("coins");
    if (storedHearts != null) {
      _coins = storedHearts;
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
  }
}
