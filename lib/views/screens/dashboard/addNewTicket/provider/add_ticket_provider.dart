import 'package:flutter/cupertino.dart';
import 'package:makula_oem/helper/model/list_all_machines.dart';
import 'package:makula_oem/helper/model/list_customers.dart';
import 'package:makula_oem/helper/model/list_facility_users.dart';
import 'package:makula_oem/helper/utils/constants.dart';

import '../../../../../helper/model/get_list_support_accounts_response.dart';

class AddTicketProvider with ChangeNotifier {
  int _selectionTicketTypeRadio = 1;
  bool _isTitleFocused = false;
  bool _isDescriptionFocused = false;
  bool _isTitleValidated = false;
  bool _isDescriptionValidated = false;
  String _ticketTitle = "";
  String _ticketType = ticketTypeServiceRequest;
  Customers? _facilityData = Customers();
  ListMachines? _selectedMachineData = ListMachines();
  ListOwnOemFacilityUsers? _reporterData = ListOwnOemFacilityUsers();
  List<ListSupportAccounts>? _reporterList = [];
  List<ListMachines>? _machineList = [];
  DateTime? _selectedDate = null;

  int get selectionTicketTypeRadio => _selectionTicketTypeRadio;

  Customers? get facilityData => _facilityData;

  ListMachines? get selectedMachineData => _selectedMachineData;

  ListOwnOemFacilityUsers? get reporterData => _reporterData;

  List<ListSupportAccounts>? get reporterList => _reporterList;

  bool get isTitleFocused => _isTitleFocused;

  List<ListMachines>? get machineList => _machineList;

  bool get isDescriptionFocused => _isDescriptionFocused;

  bool get isTitleValidated => _isTitleValidated;

  bool get isDescriptionValidated => _isDescriptionValidated;

  String get ticketTitle => _ticketTitle;

  String get ticketType => _ticketType;

  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime? value) {
    _selectedDate = value;
    notifyListeners();
  }

  void radioTicketTypeSelection(int value) {
    _selectionTicketTypeRadio = value;
    notifyListeners();
  }

  void setIsTitleFocused(bool isValidated) {
    _isTitleFocused = isValidated;
    notifyListeners();
  }

  void setIsDescriptionFocused(bool isValidated) {
    _isDescriptionFocused = isValidated;
    notifyListeners();
  }

  void setIsTitleValidate(bool isValidated) {
    _isTitleValidated = isValidated;
    notifyListeners();
  }

  void setIsDescriptionValidate(bool isValidated) {
    _isDescriptionValidated = isValidated;
    notifyListeners();
  }

  void setTicketTitle(String value) {
    _ticketTitle = value;
    notifyListeners();
  }

  void setTicketType(String value) {
    _ticketType = value;
    notifyListeners();
  }

  void setFacilityData(Customers? value) {
    _facilityData = value;
    notifyListeners();
  }

  void setMachineData(ListMachines? value) {
    _selectedMachineData = value;
    notifyListeners();
  }

  void setReporterData(ListOwnOemFacilityUsers? value) {
    _reporterData = value;
    notifyListeners();
  }

  getMachineListFromFacility(List<ListMachines>? _machinesList) {
    _machineList = _machinesList;
    notifyListeners();
  }

  setReporterListFromFacility(List<ListSupportAccounts>? list) {
    _reporterList = list;
    notifyListeners();
  }

  void clearValues() {
    _facilityData = null;
    _machineList = [];
    _reporterList = [];
    _selectedMachineData = null;
    _reporterData = null;
    _selectionTicketTypeRadio = 1;
    _ticketTitle = "";
    _ticketType = ticketTypeServiceRequest;
    _isDescriptionValidated = false;
    _isTitleValidated = false;
    _isTitleFocused = false;
    _isDescriptionFocused = false;
  }

  void clearTitleValues() {
    _ticketTitle = "";
    _isTitleValidated = false;
    _isTitleFocused = false;
  }

  void clearDescValues() {
    _isDescriptionValidated = false;
    _isDescriptionFocused = false;
  }
}
