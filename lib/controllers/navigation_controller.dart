import 'package:flutter/material.dart';

class NavigationController extends ChangeNotifier {
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void changePage(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Right drawer toggle
  bool _isDrawerOpen = false;
  bool get isDrawerOpen => _isDrawerOpen;

  void openDrawer() {
    _isDrawerOpen = true;
    notifyListeners();
  }

  void closeDrawer() {
    _isDrawerOpen = false;
    notifyListeners();
  }
}
