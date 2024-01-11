import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/attach_procedure_to_work_order_response.dart';
import 'package:makula_oem/helper/model/get_inventory_part_list_response.dart';
import 'package:makula_oem/helper/model/get_list_support_accounts_response.dart';
import 'package:makula_oem/helper/model/get_procedure_by_id_response.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
import 'package:makula_oem/helper/model/safe_sign_s3_response.dart';
import 'package:makula_oem/helper/model/signature_model.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class ProcedureViewModel {
  Future<ApiResultState> getListProcedureTemplates() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result = await client
        .query(QueryOptions(document: gql(listOwnOemProcedureTemplates)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "getListOwnOemSupportAccounts - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GetProcedureTemplatesResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getProcedureById(String procedureId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result = await client.query(
      QueryOptions(
        document: gql(getOwnOemProcedureById),
        variables: {"id": procedureId},
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getOwnOemProcedureById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getOwnOemProcedureById - data => ${result.data}");
      var response = GetProcedureByIdResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> attachProcedureToWorkOrder(
      String workOrderId, String templateId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        variables: {
          "input": {"workOrderId": workOrderId, "templateId": templateId}
        },
        document: gql(ATTACH_PROCEDURE_TO_WORK_ORDER),
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("hasException => ${result.exception}");
      return ApiResultState.failed(result.hasException.toString());
    } else if (result.data != null) {
      console("attachProcedureToWorkOrder => ${result.data}");
      var response = AttachProcedureToWorkOrderResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getInventoryPartList() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result = await client
        .query(QueryOptions(document: gql(LIST_OWN_OEM_INVENTORY_PART)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getInventoryPartList - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getInventoryPartList - data => ${result.data}");
      var response = GetInventoryPartListResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> safeSignS3(String filename, String filetype,
      bool foreCustomPath, String type) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result = await client.mutate(
      MutationOptions(
        variables: {
          "filename": filename,
          "filetype": filetype,
          "forceCustomPath": foreCustomPath,
          "type": type
        },
        document: gql(SAFE_SIGN_S3),
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("hasException => ${result.exception}");
      return ApiResultState.failed(result.hasException.toString());
    } else if (result.data != null) {
      console("safeSignS3 => ${result.data}");
      var response = SafeSigns3Response.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> finalizeOemProcedure(
      String sId,
      List<ChildrenModel>? childrenModel,
      List<SignatureRequestModel>? signatureRequestModel) async {
    console(
        "signatures => ${signatureRequestModel?.map((signature) => signature.toJson()).toList()}");
    console(
        "children => ${childrenModel?.map((children) => children.toJson()).toList()}");
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result = await client.mutate(
      MutationOptions(
        variables: {
          "input": {
            "_id": sId,
            "signatures": signatureRequestModel
                ?.map((signature) => signature.toJson())
                .toList(),
            //"children": childrenModel,
            "children":
                childrenModel?.map((children) => children.toJson()).toList(),
          }
        },
        document: gql(FINALIZE_OEM_PROCEDURE),
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("finalizeOemProcedure - hasException => ${result.exception}");
      return ApiResultState.failed(result.hasException.toString());
    } else if (result.data != null) {
      console("finalizeOemProcedure => ${result.data}");
      var response = FinalizeOemProcedureResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> saveAsDraftOemProcedure(
      String sId,
      List<ChildrenModel>? childrenModel,
      List<SignatureRequestModel>? signatureRequestModel) async {
    console(
        "saveAsDraftOemProcedure => signatures => ${signatureRequestModel?.map((signature) => signature.toJson()).toList()}");
    console(
        "saveAsDraftOemProcedure => children => ${childrenModel?.map((children) => children.toJson()).toList()}");
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result = await client.mutate(
      MutationOptions(
        variables: {
          "input": {
            "_id": sId,
            "signatures": signatureRequestModel
                ?.map((signature) => signature.toJson())
                .toList(),
            "children":
                childrenModel?.map((children) => children.toJson()).toList(),
          }
        },
        document: gql(SAVE_AS_DRAFT_OEM_PROCEDURE),
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("saveAsDraftOemProcedure - hasException => ${result.exception}");
      return ApiResultState.failed(result.hasException.toString());
    } else if (result.data != null) {
      console("saveAsDraftOemProcedure Success => ${result.data}");
      var response = FinalizeOemProcedureResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getListSupportAccounts() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient client = graphQLConfiguration.clientToQuery();
    QueryResult result =
        await client.query(QueryOptions(document: gql(LIST_SUPPORT_ACCOUNTS)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getListSupportAccounts - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getListSupportAccounts - data => ${result.data}");
      var response = GetListSupportAccountsResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }
}
