import 'package:flutter/material.dart';

class ProcedureProvider with ChangeNotifier {
  final Map<String, dynamic> _fieldValues = {};

  Map<String, dynamic> get fieldValues => _fieldValues;

  void setFieldValue(String fieldName, dynamic value) {
    _fieldValues[fieldName] = value;
    notifyListeners();
  }

  void clearFieldValues() {
    _fieldValues.clear();
    notifyListeners();
  }
}