import 'package:flutter/material.dart';

class Store extends ChangeNotifier {
  static Store singleton = Store();

  Map<dynamic, dynamic> _state = {};

  Map<dynamic, dynamic> get state => _state;

  void setState(Map<dynamic, dynamic> state) {
    _state = {..._state, ...state};
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
