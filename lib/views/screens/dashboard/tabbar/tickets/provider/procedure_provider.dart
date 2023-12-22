import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class ProcedureProvider with ChangeNotifier {
  final Map<String, dynamic> _fieldValues = {};

  bool _isValid = true;

  bool get isValid => _isValid;

  ListOwnOemProcedureTemplates? _selectedProcedure;

  ListOwnOemProcedureTemplates? get selectedProcedure => _selectedProcedure;
  Map<String, dynamic> get fieldValues => _fieldValues;

  void setFieldValue(String fieldName, dynamic value) {
    _fieldValues[fieldName] = value;
    _isValid = !hasNullValues(fieldValues);
    notifyListeners();
  }

  void setTableFieldValue(String name, List<List<String>> tableData) {
    fieldValues[name] = tableData;
    notifyListeners();
  }


  void setImageFieldValue(String fieldName, String fileUrl) {
    List<String> currentList = _fieldValues[fieldName] ?? [];
    currentList.add(fileUrl);
    _fieldValues[fieldName] = currentList;

    notifyListeners(); // Notify listeners to rebuild widgets that depend on this provider
  }
  void clearFieldValues() {
    _fieldValues.clear();
    notifyListeners();
  }


  void updateSelectedProcedure(ListOwnOemProcedureTemplates? procedure) {
    _selectedProcedure = procedure;
    notifyListeners();
  }


  bool hasNullValues(Map<String, dynamic>? procedure) {
    console("hasNullValues => $procedure");
    if (procedure == null) {
      return false;

    }

    for (var value in procedure.values) {
      console("hasNullValues => $procedure");
      if (value == null) {
        return true; // Found a null value
      }
    }
    return false; // No null values found
  }
}