import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseValueProvider with ChangeNotifier {
  int _currentValue = 0;
  String _itemName = "";
  bool _purchasePending = false;

  PurchaseValueProvider() {
    // _loadFromPrefs();
  }

  int get currentValue => _currentValue;
  String get itemName => _itemName;
  bool get purchasePending => _purchasePending;

  void setPurchasePending(bool purchasePending) {
    _purchasePending = purchasePending;
    // _saveToPrefs();
    notifyListeners();
  }

  void setCurrentValue(String name, int value) {
    _currentValue = value;
    _itemName = name;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedValue = prefs.getInt("itemValue");
    if (storedValue != null) {
      _currentValue = storedValue;
    }
    final storedItemName = prefs.getString("itemName");
    if (storedItemName != null) {
      _itemName = storedItemName;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('itemValue', _currentValue);
    await prefs.setString('itemName', _itemName);
  }
}
