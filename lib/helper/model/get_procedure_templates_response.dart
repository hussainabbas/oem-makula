class GetProcedureTemplatesResponse {
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

class ListOwnOemProcedureTemplates {
  String? sId;
  String? name;
  String? state;
  String? pdfUrl;
  String? description;
  String? createdAt;
  String? updatedAt;
  List<SignatureModel>? signatures;
  List<ChildrenModel>? children;
  Null? pageHeader;

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['description'] = description;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
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

class ChildrenModel {
  String? sId;
  String? type;
  String? name;
  String? description;
  bool? isRequired;
  List<OptionsModel>? options;
  TableOptionModel? tableOption;
  List<AttachmentsModel>? attachments;
  List<ChildrenModel>? children;

  ChildrenModel(
      {this.sId,
      this.type,
      this.name,
      this.description,
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
    data['type'] = type;
    data['name'] = name;
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
      data['children'] = children!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TableOptionModel {
  Null? nId;
  Null? rowCount;
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

class ColumnsModel {
  String? sId;
  String? heading;
  int? width;

  ColumnsModel({this.sId, this.heading, this.width});

  ColumnsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    heading = json['heading'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['heading'] = heading;
    data['width'] = width;
    return data;
  }
}

class OptionsModel {
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

class AttachmentsModel {
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

class SignatureModel {
  String? sId;
  String? signatoryTitle;

  SignatureModel({this.sId, this.signatoryTitle});

  SignatureModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    signatoryTitle = json['signatoryTitle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['signatoryTitle'] = signatoryTitle;
    return data;
  }
}
