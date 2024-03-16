import 'package:flutter/material.dart';

class HistoryNotifier {
  static final HistoryNotifier _instance = HistoryNotifier._internal();

  factory HistoryNotifier() {
    return _instance;
  }

  HistoryNotifier._internal();

  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}
