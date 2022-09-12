import 'package:flutter/cupertino.dart';

class MachineProvider with ChangeNotifier {
  String _machineId = "";
  String _machineName = "";
  double _height = 1;

  String get machineId => _machineId;

  String get machineName => _machineName;

  double get webViewHeight => _height;

  void setMachineId(String id) {
    _machineId = id;
    notifyListeners();
  }

  void setMachineName(String name) {
    _machineName = name;
    notifyListeners();
  }

  void setWebViewHeight(double height) {
    _height = height;
    notifyListeners();
  }
}
