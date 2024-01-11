
import 'package:floor/floor.dart';
import 'package:makula_oem/database/type_converters/dynamic_file_converter.dart';
import 'package:makula_oem/database/type_converters/list_attachment_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_children_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_options_modal_converter.dart';
import 'package:makula_oem/database/type_converters/list_own_procedure_templates_model_converter.dart';
import 'package:makula_oem/database/type_converters/list_signature_modal_converter.dart';
import 'package:makula_oem/database/type_converters/table_option_model_converter.dart';

@entity
class GetProcedureTemplatesResponse {
  @primaryKey
  int? id;

  @TypeConverters([ListOwnOemProcedureTemplatesModelConverter])
  List<ListOwnOemProcedureTemplates>? listOwnOemProcedureTemplates;

  GetProcedureTemplatesResponse({this.listOwnOemProcedureTemplates});

  GetProcedureTemplatesResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemProcedureTemplates'] != null) {
      listOwnOemProcedureTemplates = <ListOwnOemProcedureTemplates>[];
      json['listOwnOemProcedureTemplates'].forEach((v) {
        listOwnOemProcedureTemplates!
            .add(ListOwnOemProcedureTemplates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listOwnOemProcedureTemplates != null) {
      data['listOwnOemProcedureTemplates'] =
          listOwnOemProcedureTemplates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class ListOwnOemProcedureTemplates {
  @primaryKey
  String? sId;

  String? name;
  String? state;
  String? pdfUrl;
  String? description;
  String? createdAt;
  String? updatedAt;
  @TypeConverters([ListSignatureModalConverter])
  List<SignatureModel>? signatures;
  @TypeConverters([ListChildrenModalConverter])
  List<ChildrenModel>? children;
  String? pageHeader;

  @TypeConverters([DynamicValueConverter])
  dynamic? value;

  ListOwnOemProcedureTemplates(
      {this.sId,
      this.name,
      this.description,
      this.createdAt,
      this.updatedAt,
      this.signatures,
      this.children,
      this.state,
      this.pdfUrl,
      this.value,
      this.pageHeader});

  ListOwnOemProcedureTemplates.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['signatures'] != null) {
      signatures = <SignatureModel>[];
      json['signatures'].forEach((v) {
        signatures!.add(SignatureModel.fromJson(v));
      });
    }
    if (json['children'] != null) {
      children = <ChildrenModel>[];
      json['children'].forEach((v) {
        children!.add(ChildrenModel.fromJson(v));
      });
    }
    pageHeader = json['pageHeader'];
    state = json['state'];
    pdfUrl = json['pdfUrl'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['value'] = value;
    if (signatures != null) {
      data['signatures'] = signatures!.map((v) => v.toJson()).toList();
    }
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    data['pageHeader'] = pageHeader;
    data['state'] = state;
    data['pdfUrl'] = pdfUrl;
    return data;
  }
}

@entity
class ChildrenModel {
  @primaryKey
  String? sId;
  String? type;
  String? name;
  String? description;

  @TypeConverters([DynamicValueConverter])
  dynamic? value;
  bool? isRequired;

  @TypeConverters([ListOptionsModelConverter])
  List<OptionsModel>? options;

  @TypeConverters([TableOptionModelConverter])
  TableOptionModel? tableOption;

  @TypeConverters([ListAttachmentsModelConverter])
  List<AttachmentsModel>? attachments;
  @TypeConverters([ListChildrenModalConverter])
  List<ChildrenModel>? children;

  ChildrenModel(
      {this.sId,
      this.type,
      this.name,
      this.description,
      this.value,
      this.isRequired,
      this.options,
      this.tableOption,
      this.attachments,
      this.children});

  ChildrenModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    name = json['name'];
    description = json['description'];
    value = json['value'];
    isRequired = json['isRequired'];
    if (json['options'] != null) {
      options = <OptionsModel>[];
      json['options'].forEach((v) {
        options!.add(OptionsModel.fromJson(v));
      });
    }
    tableOption = json['tableOption'] != null
        ? TableOptionModel.fromJson(json['tableOption'])
        : null;
    if (json['attachments'] != null) {
      attachments = <AttachmentsModel>[];
      json['attachments'].forEach((v) {
        attachments!.add(AttachmentsModel.fromJson(v));
      });
    }
    if (json['children'] != null) {
      children = <ChildrenModel>[];
      json['children'].forEach((v) {
        children!.add(ChildrenModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    // data['type'] = type;
    // data['name'] = name;
    data['value'] = value;
    // data['description'] = description;
    // data['isRequired'] = isRequired;
    // if (options != null) {
    //   data['options'] = options!.map((v) => v.toJson()).toList();
    // }
    // if (tableOption != null) {
    //   data['tableOption'] = tableOption!.toJson();
    // }
    // if (attachments != null) {
    //   data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    // }
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Map<String, dynamic> toJson2() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['name'] = name;
    data['value'] = value;
    data['description'] = description;
    data['isRequired'] = isRequired;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    if (tableOption != null) {
      data['tableOption'] = tableOption!.toJson();
    }
    if (attachments != null) {
      data['attachments'] = attachments!.map((v) => v.toJson()).toList();
    }
    if (children != null) {
      data['children'] = children!.map((v) => v.toJson2()).toList();
    }
    return data;
  }
}

class TableOptionModel {
  String? nId;
  String? rowCount;

  List<ColumnsModel>? columns;

  TableOptionModel({this.nId, this.rowCount, this.columns});

  TableOptionModel.fromJson(Map<String, dynamic> json) {
    nId = json['_id'];
    rowCount = json['rowCount'];
    if (json['columns'] != null) {
      columns = <ColumnsModel>[];
      json['columns'].forEach((v) {
        columns!.add(ColumnsModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = nId;
    data['rowCount'] = rowCount;
    if (columns != null) {
      data['columns'] = columns!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

@entity
class ColumnsModel {
  @primaryKey
  String? sId;
  String? heading;
  int? width;
  @TypeConverters([DynamicValueConverter])
  dynamic? value;

  ColumnsModel({this.sId, this.heading, this.width, this.value});

  ColumnsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    heading = json['heading'];
    width = json['width'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    // data['heading'] = heading;
    // data['width'] = width;
    data['value'] = value;
    return data;
  }

  Map<String, dynamic> toJson2() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['heading'] = heading;
    data['width'] = width;
    data['value'] = value;
    return data;
  }
}

@entity
class OptionsModel {
  @primaryKey
  String? sId;
  String? name;

  OptionsModel({this.sId, this.name});

  OptionsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

@entity
class AttachmentsModel {
  @primaryKey
  String? sId;
  String? name;
  String? type;
  String? url;
  String? size;

  AttachmentsModel({this.sId, this.name, this.type, this.url, this.size});

  AttachmentsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    type = json['type'];
    url = json['url'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['type'] = type;
    data['url'] = url;
    data['size'] = size;
    return data;
  }
}

@entity
class SignatureModel {
  @primaryKey
  String? sId;
  String? signatoryTitle;

  String? name;
  String? date;
  String? signatureUrl;

  SignatureModel({this.sId, this.signatoryTitle});

  SignatureModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    signatoryTitle = json['signatoryTitle'];
    name = json['name'];
    date = json['date'];
    signatureUrl = json['signatureUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['signatoryTitle'] = signatoryTitle;
    data['name'] = name;
    data['date'] = date;
    data['signatureUrl'] = signatureUrl;
    return data;
  }
}
