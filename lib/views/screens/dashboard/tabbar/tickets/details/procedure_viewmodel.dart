import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/attach_procedure_to_work_order_response.dart';
import 'package:makula_oem/helper/model/get_procedure_by_id_response.dart';
import 'package:makula_oem/helper/model/get_procedure_templates_response.dart';
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
}
