import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/create_template_response.dart';
import 'package:makula_oem/helper/model/delete_document_response.dart';
import 'package:makula_oem/helper/model/get_document_by_id_response.dart';
import 'package:makula_oem/helper/model/list_my_documents_response.dart';
import 'package:makula_oem/helper/model/list_template_response.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class DocumentViewModel {
  Future<ApiResultState> getTemplateList() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result =
        await _client.query(QueryOptions(document: gql(listOwnOemTemplates)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "getListOwnOemSupportAccounts - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = ListTemplateResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getMyDocumentList() async {
    console("getMyDocumentList");
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result =
        await _client.query(QueryOptions(document: gql(listOwnOemSubmissions)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getMyDocumentList - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getMyDocumentList - hasException => ${result.exception}");
      var response = ListMyDocumentsResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getFormUrlByTemplateId(String templateId,
      String facilityId, String machineId, DateTime inspectionDate) async {
    var date =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(inspectionDate);
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();

    QueryResult result = await _client.mutate(
      MutationOptions(document: gql(getOwnOemFormUrlByTemplateId), variables: {
        "input": {
          "templateId": templateId,
          "facilityId": facilityId,
          "machineId": machineId,
          "inspectionDate": date,
          //"inspectionDate": "2022-07-20T03:29:56.901Z"
        }
      }),
    );

    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "getOwnOemFormUrlByTemplateId - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getOwnOemFormUrlByTemplateId - data => ${result.data}");
      var response = CreateTemplateResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getDocumentById(String submissionId) async {
    console("getMyDocumentList");
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(QueryOptions(
        document: gql(getOwnOemSubmissionById),
        variables: {"submissionId": submissionId}));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getDocumentById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getDocumentById - data => ${result.data}");
      var response = GetDocumentByIdResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> deleteDocument(String submissionId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        variables: {"submissionId": submissionId},
        document: gql(deleteOwnOemSubmissionById),
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("deleteDocument => ${result.data}");
      var response = DeleteDocumentResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }
}
