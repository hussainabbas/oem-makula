import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'helper/model/get_procedure_templates_response.dart';
import 'helper/utils/utils.dart';

final procedureTemplateProvider =
    StateNotifierProvider((ref) => ProcedureTemplateNotifier());

final selectedImageListProvider = StateProvider<List<String>?>((ref) => []);

class ProcedureTemplateNotifier
    extends StateNotifier<ListOwnOemProcedureTemplates?> {
  ProcedureTemplateNotifier() : super(ListOwnOemProcedureTemplates());

  void updateValue(ListOwnOemProcedureTemplates? templates) {
    state = templates;
  }
}

final procedureFormStateProvider =
    StateNotifierProvider((ref) => ProcedureFormStateNotifier());

class ProcedureFormStateNotifier extends StateNotifier<bool> {
  ProcedureFormStateNotifier() : super(false);

  void markChanges(dynamic beforeValue, dynamic afterValue) {
    // console(
    //     "markChanges => B: $beforeValue , A: $afterValue --- ${beforeValue == afterValue}");
    // if (beforeValue == afterValue) {
    //   state = false;
    // } else {
    //   state = true;
    // }

    state = true;
  }

  void resetChanges() {
    state = false;
  }
}

final procedureFormFinalizedProvider =
    StateNotifierProvider<ProcedureFormFinalizedNotifier, bool>(
  (ref) => ProcedureFormFinalizedNotifier(),
);

class ProcedureFormFinalizedNotifier extends StateNotifier<bool> {
  ProcedureFormFinalizedNotifier() : super(false);

  bool hasRequiredChildWithValue(ChildrenModel? child) {
    console("ProcedureFormFinalizedNotifier ChildrenModel => Name: ${child?.name} =---- Value: ${child?.value} ---- isRequired: ${child?.isRequired}");
    bool currentLevelResult =
        !child!.isRequired! || (child.value != null && !_isEmptyValue(child.value));

    bool nestedLevelResult = true;
    child.children?.forEach((nestedChild) {
      console("ProcedureFormFinalizedNotifier nestedChild => Name: ${nestedChild.name} =---- Value: ${nestedChild.value} ---- isRequired: ${nestedChild.isRequired}");
      if (nestedChild.isRequired! &&
          (nestedChild.value == null || _isEmptyValue(nestedChild.value))) {
        console("ProcedureFormFinalizedNotifier nestedLevelResult => this is required but the value is null - Name: ${nestedChild.name} =---- Value: ${nestedChild.value} ---- isRequired: ${nestedChild.isRequired}");
        nestedLevelResult =
            false; // Set to false if any required field is not filled
      }
    });

    console(
    "ProcedureFormFinalizedNotifier => $currentLevelResult =---- $nestedLevelResult");

    return currentLevelResult && nestedLevelResult;
  }

  bool _isEmptyValue(dynamic value) {
    console("_isEmptyValue = $value");
    if (value == null) {
      return true;
    } else if (value is String) {

      return value.isEmpty;
    } else if (value is Iterable) {
      return value.isEmpty;
    } else if (value is Map) {
      return value.isEmpty;
    }
    else if (value is bool) {
      return !value;
    }
    // Handle other types as needed
    return false;
  }

  void checkIfAllRequiredFieldsAreFilled(
      ListOwnOemProcedureTemplates? templates) {
    bool allFieldsFilled = true;
    templates?.children?.forEach((element) {
      if (!hasRequiredChildWithValue(element)) {
        allFieldsFilled = false;
      }
    });

    console("ProcedureFormFinalizedNotifier checkIfAllRequiredFieldsAreFilled: allFieldsFilled=> $allFieldsFilled");
    state = allFieldsFilled;
  }

  void reset() {
    state = false;
  }
}

final procedureSignatureStateProvider =
    StateNotifierProvider((ref) => ProcedureSignatureStateNotifier());

class ProcedureSignatureStateNotifier extends StateNotifier<bool> {
  ProcedureSignatureStateNotifier() : super(false);

  void update(ListOwnOemProcedureTemplates? model) {
    var isSignatureFilled = true;
    if (model?.signatures?.isEmpty == true) {
      isSignatureFilled = false;
    }
    model?.signatures?.forEach((element) {
      if (element.signatureUrl == null || element.signatureUrl == "") {
        isSignatureFilled = false;
      }
    });

    state = isSignatureFilled;
  }

  void reset() {
    state = false;
  }
}


final procedureSignatureCheckAnyTrueStateProvider =
StateNotifierProvider((ref) => ProcedureSignatureCheckAnyTrueStateNotifier());

class ProcedureSignatureCheckAnyTrueStateNotifier extends StateNotifier<bool> {
  ProcedureSignatureCheckAnyTrueStateNotifier() : super(false);

  void update(ListOwnOemProcedureTemplates? model) {
    var isSignatureFilled = true;
    if (model?.signatures?.isEmpty == true) {
      isSignatureFilled = true;
    }
    model?.signatures?.forEach((element) {
      if (element.signatureUrl != null) {
        console("procedureSignatureCheckAnyTrueStateProvider => ${element.signatureUrl}");
        isSignatureFilled = false;
      }
    });

    state = isSignatureFilled;
  }

  void reset() {
    state = false;
  }
}