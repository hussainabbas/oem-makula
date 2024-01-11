import 'package:flutter/material.dart';
import 'package:makula_oem/helper/model/get_inventory_part_list_response.dart';
import 'package:makula_oem/helper/model/get_list_support_accounts_response.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/model/safe_sign_s3_response.dart';
import 'package:makula_oem/helper/model/signature_model.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class ProcedureProvider with ChangeNotifier {
  final Map<String, dynamic> _fieldValues = {};

  bool _isValid = true;

  bool get isValid => _isValid;

  ListOwnOemProcedureTemplates? _selectedProcedure;

  ListOwnOemProcedureTemplates? get selectedProcedure => _selectedProcedure;

  Map<String, dynamic> get fieldValues => _fieldValues;

  List<PartsModel>? _selectedPartsList = [];

  List<PartsModel>? get selectedPartsList => _selectedPartsList;


  List<ListOwnOemSupportAccounts>? _selectedSupportAccount = [];

  List<ListOwnOemSupportAccounts>? get selectedSupportAccount => _selectedSupportAccount;


  List<String>? _selectedPartsSIdList = [];

  List<String>? get selectedPartsSIdList => _selectedPartsSIdList;

  List<String>? _selectedSupportAccountSIdList = [];

  List<String>? get selectedSupportAccountSIdList => _selectedSupportAccountSIdList;

  List<String>? _selectedImageList = [];

  List<String>? get selectedImageList => _selectedImageList;

  List<ColumnsModel>? _tableDataRequest = [];

  List<ColumnsModel>? get tableDataRequest => _tableDataRequest;


  List<ImageRequestModel>? _imageRequestModel = [];

  List<ImageRequestModel>? get imageRequestModel => _imageRequestModel;

  List<SafeSigns3Response>? _uploadedImageList = [];

  List<SafeSigns3Response>? get uploadedImageList => _uploadedImageList;


  List<SignatureRequestModel>? _signatureModel = [];
  List<SignatureRequestModel>? get signatureModel => _signatureModel;


  ListOwnOemProcedureTemplates? _myProcedureRequest;

  ListOwnOemProcedureTemplates? get myProcedureRequest => _myProcedureRequest;

  void addPartModel(PartsModel? model) {
    _selectedPartsList ??= [];
    if (!_selectedPartsList!.contains(model)) {
      _selectedPartsList?.add(model!);
    }
    console("addPartModel => ${_selectedPartsList?.length}");
    notifyListeners();
  }


  void addPartModelSId(String? model) {
    _selectedPartsSIdList ??= [];
    if (!_selectedPartsSIdList!.contains(model)) {
      _selectedPartsSIdList?.add(model!);
    }
    console("addPartModel => ${_selectedPartsList?.length}");
    notifyListeners();
  }

  void removePartModel(PartsModel? model) {
    _selectedPartsList?.remove(model!);
    notifyListeners();
  }
  void removePartModelSId(String? model) {
    _selectedPartsSIdList?.remove(model!);
    notifyListeners();
  }


  void addSupportAccount(ListOwnOemSupportAccounts? model) {
    _selectedSupportAccount ??= [];
    if (!_selectedSupportAccount!.contains(model)) {
      _selectedSupportAccount?.add(model!);
    }
    console("addSupportAccount => ${_selectedSupportAccount?.length}");
    notifyListeners();
  }

  void addSupportAccountSid(String? model) {
    _selectedSupportAccountSIdList ??= [];
    if (!_selectedSupportAccountSIdList!.contains(model)) {
      _selectedSupportAccountSIdList?.add(model!);
    }
    console("addSupportAccountSid => ${_selectedSupportAccountSIdList?.length}");
    notifyListeners();
  }

  void removeSupportAccount(ListOwnOemSupportAccounts? model) {
    _selectedSupportAccount?.remove(model!);
    notifyListeners();
  }
  void removeSupportAccountSId(String? model) {
    _selectedSupportAccountSIdList?.remove(model!);
    notifyListeners();
  }


  void clearSupportAccount() {
    _selectedSupportAccount?.clear();
    notifyListeners();
  }

  void clearSupportAccountSid() {
    _selectedSupportAccountSIdList?.clear();
    notifyListeners();
  }



  void removeAllPartModels() {
    _selectedPartsList?.clear();
    notifyListeners();
  }

  void setFieldValue(String fieldName, dynamic value) {
    _fieldValues[fieldName] = value;

    console("setFieldValue => $_fieldValues");
    _isValid = !hasNullValues(fieldValues);
    notifyListeners();
  }

  void removeFieldValue(String fieldName) {
    if (_fieldValues.containsKey(fieldName)) {
      _fieldValues.remove(fieldName);

      console("removeFieldValue => $_fieldValues");
      _isValid = !hasNullValues(fieldValues);
      notifyListeners();
    }
  }

  void setTableFieldValue(String name, List<List<String>> tableData) {
    fieldValues[name] = tableData;
    notifyListeners();
  }

  void setImageFieldValue(String fieldName, String fileUrl) {
    // _selectedImageList = _fieldValues[fieldName] ?? [];
    if (_selectedImageList?.contains(fileUrl) == false) {
      _selectedImageList?.add(fileUrl);
      _fieldValues[fieldName] = _selectedImageList;
    }
    _isValid = !hasNullValues(fieldValues);

    notifyListeners(); // Notify listeners to rebuild widgets that depend on this provider
  }

  void setUploadedImageList(SafeSigns3Response s3, String fieldName) {
    _uploadedImageList?.add(s3);
    _isValid = !hasNullValues(fieldValues);
    _fieldValues[fieldName] = _selectedImageList;
    notifyListeners();
  }

  void addSignature(SignatureRequestModel model) {
    _signatureModel?.add(model);
    notifyListeners();
  }

  void clearSignature() {
    _signatureModel?.clear();
    notifyListeners();
  }


  void clearImageFieldValue() {
    _selectedImageList?.clear();
    notifyListeners();
  }

  void deleteImageFieldValue(String path) {
    _selectedImageList?.remove(path);
    notifyListeners();
  }


  void setImageRequestModel(ImageRequestModel model) {
    _imageRequestModel?.add(model);
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this provider
  }

  void clearImageRequestModel() {
    _imageRequestModel?.clear();
    notifyListeners();
  }

  void deleteImageRequestModel(ImageRequestModel path) {
    _imageRequestModel?.remove(path);
    notifyListeners();
  }


  void setTableDataRequestModel(ColumnsModel model) {
    _tableDataRequest?.add(model);
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this provider
  }

  void clearTableDataRequestModel() {
    _tableDataRequest?.clear();
    notifyListeners();
  }

  void deleteTableDataRequestModel(int index) {
    _tableDataRequest?.removeAt(index);
    notifyListeners();
  }

  void clearFieldValues() {
    _fieldValues.clear();
    notifyListeners();
  }

  void updateSelectedProcedure(ListOwnOemProcedureTemplates? procedure) {
    _selectedProcedure = procedure;
    notifyListeners();
  }

  void setMyProcedureRequest(ListOwnOemProcedureTemplates? procedure) {
    _myProcedureRequest = procedure;
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
