import 'package:makula_oem/helper/model/oem.dart';

class ListTemplateResponse {
  List<ListOwnOemTemplates>? listOwnOemTemplates;

  ListTemplateResponse({this.listOwnOemTemplates});

  ListTemplateResponse.fromJson(Map<String, dynamic> json) {
    if (json['listOwnOemTemplates'] != null) {
      listOwnOemTemplates = <ListOwnOemTemplates>[];
      json['listOwnOemTemplates'].forEach((v) {
        listOwnOemTemplates!.add(new ListOwnOemTemplates.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listOwnOemTemplates != null) {
      data['listOwnOemTemplates'] =
          this.listOwnOemTemplates!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListOwnOemTemplates {
  String? sId;
  TemplateData? templateData;
  String? templateId;
  Oem? oem;

  ListOwnOemTemplates({this.sId, this.templateData, this.templateId, this.oem});

  ListOwnOemTemplates.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    templateData = json['templateData'] != null
        ? new TemplateData.fromJson(json['templateData'])
        : null;
    templateId = json['templateId'];
    oem = json['oem'] != null ? new Oem.fromJson(json['oem']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.templateData != null) {
      data['templateData'] = this.templateData!.toJson();
    }
    data['templateId'] = this.templateId;
    if (this.oem != null) {
      data['oem'] = this.oem!.toJson();
    }
    return data;
  }
}

class TemplateData {
  String? id;
  String? name;
  String? description;
  bool? publicWebForm;
  bool? publicSubmissions;
  String? templateType;
  String? documentUrl;
  String? permanentDocumentUrl;
  String? documentState;
  String? documentFilename;
  bool? documentProcessed;
  bool? expireSubmissions;
  int? expireAfter;
  String? expirationInterval;
  bool? allowAdditionalProperties;
  bool? editableSubmissions;
  bool? locked;
  int? pageCount;
  Null? webhookUrl;
  String? path;
  String? parentFolderId;
  Null? slackWebhookUrl;
  String? redirectUrl;

  TemplateData(
      {this.id,
      this.name,
      this.description,
      this.publicWebForm,
      this.publicSubmissions,
      this.templateType,
      this.documentUrl,
      this.permanentDocumentUrl,
      this.documentState,
      this.documentFilename,
      this.documentProcessed,
      this.expireSubmissions,
      this.expireAfter,
      this.expirationInterval,
      this.allowAdditionalProperties,
      this.editableSubmissions,
      this.locked,
      this.pageCount,
      this.webhookUrl,
      this.path,
      this.parentFolderId,
      this.slackWebhookUrl,
      this.redirectUrl});

  TemplateData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    publicWebForm = json['public_web_form'];
    publicSubmissions = json['public_submissions'];
    templateType = json['template_type'];
    documentUrl = json['document_url'];
    permanentDocumentUrl = json['permanent_document_url'];
    documentState = json['document_state'];
    documentFilename = json['document_filename'];
    documentProcessed = json['document_processed'];
    expireSubmissions = json['expire_submissions'];
    expireAfter = json['expire_after'];
    expirationInterval = json['expiration_interval'];
    allowAdditionalProperties = json['allow_additional_properties'];
    editableSubmissions = json['editable_submissions'];
    locked = json['locked'];
    pageCount = json['page_count'];
    webhookUrl = json['webhook_url'];
    path = json['path'];
    parentFolderId = json['parent_folder_id'];
    slackWebhookUrl = json['slack_webhook_url'];
    redirectUrl = json['redirect_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['public_web_form'] = this.publicWebForm;
    data['public_submissions'] = this.publicSubmissions;
    data['template_type'] = this.templateType;
    data['document_url'] = this.documentUrl;
    data['permanent_document_url'] = this.permanentDocumentUrl;
    data['document_state'] = this.documentState;
    data['document_filename'] = this.documentFilename;
    data['document_processed'] = this.documentProcessed;
    data['expire_submissions'] = this.expireSubmissions;
    data['expire_after'] = this.expireAfter;
    data['expiration_interval'] = this.expirationInterval;
    data['allow_additional_properties'] = this.allowAdditionalProperties;
    data['editable_submissions'] = this.editableSubmissions;
    data['locked'] = this.locked;
    data['page_count'] = this.pageCount;
    data['webhook_url'] = this.webhookUrl;
    data['path'] = this.path;
    data['parent_folder_id'] = this.parentFolderId;
    data['slack_webhook_url'] = this.slackWebhookUrl;
    data['redirect_url'] = this.redirectUrl;
    return data;
  }
}
