import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/facility_users_model.dart';
import 'package:makula_oem/helper/model/get_machines_response.dart';
import 'package:makula_oem/helper/model/list_assignee_response.dart';
import 'package:makula_oem/helper/model/list_own_oem_customers_model.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class AddTicketViewModel {
  Future<ApiResultState> addNewTicket(
      String machineId,
      String title,
      String description,
      String ticketType,
      String reportedID,
      String customerId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        variables: {
          "input": {
            "machineId": machineId,
            "userId": reportedID,
            "customerId": customerId,
            "title": title,
            "description": description,
            "ticketType": ticketType.replaceAll(" ", "")
          }
        },
        document: gql(createOwnOemTicket),
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("AddTicketViewModel: hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = OpenTicket.fromJson(result.data!['createOwnOemTicket']);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getListOwnOemCustomers() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result =
        await _client.query(QueryOptions(document: gql(listOwnOemCustomers)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getListOwnOemCustomers - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      //console("getTicketTypes => ${result.data!}");
      var response = OwnOemCustomersModel.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getAllMachines() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result =
        await _client.query(QueryOptions(document: gql(listOwnOemMachines)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getListOwnOemCustomers - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GetMachinesResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> listFacilityUsers(String facilityId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: gql(listOwnOemFacilityUsers),
        variables: {"facilityId": facilityId},
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "listFacilityUsers: getTicketById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = FacilityUsersModel.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }


  Future<ApiResultState> getListOwnOemSupportAccounts() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result =
    await _client.query(QueryOptions(document: gql(listOwnOemSupportAccounts)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getListOwnOemSupportAccounts - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = ListAssignee.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

}
