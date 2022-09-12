import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/get_machine_details_response.dart';
import 'package:makula_oem/helper/model/get_machine_folder_id.dart';
import 'package:makula_oem/helper/model/get_machine_list_response.dart';
import 'package:makula_oem/helper/model/machine_ticket_history_model.dart';
import 'package:makula_oem/helper/model/sign_download_model.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class MachineViewModel {

  Future<ApiResultState> getMachinesList() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client
        .query(QueryOptions(document: gql(listOwnCustomerMachines)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getMachinesList - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GetMachineListResponse.fromJson(result.data!);
      response.listOwnCustomerMachines!.sort((b, a) => -a.name.toString().compareTo(b.name.toString()));
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getMachinesDetailsById(String machineId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(QueryOptions(
        variables: {"id": machineId},
        document: gql(getOwnCustomerMachineById)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getMachinesDetailsById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GetMachineDetailResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getMachinesHistoryById(String machineId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(QueryOptions(
        variables: {"id": machineId},
        document: gql(listOwnOemMachineTicketHistory)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getMachinesHistoryById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      try {
        var response = MachineTicketHistory.fromJson(result.data!);
        return ApiResultState.loaded(response);
      }
      catch (e) {
        console(e.toString());
      }
      
    }
    return ApiResultState.failed(unexpectedError);
  }


  Future<ApiResultState> getSignS3Download(String url) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        variables: {
          "filename": url
        },
        document: gql(signS3Download),
        fetchPolicy: FetchPolicy.noCache,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
        if (result.exception!.graphqlErrors[0].message == noUserError) {
          return ApiResultState.failed(noUserError);
        } else if (result.exception!.graphqlErrors[0].message ==
            wrongPasswordError) {
          return ApiResultState.failed(wrongPasswordError);
        }
      }
      console("hasException => ${result.exception}");
      return ApiResultState.failed(noUserError);
    } else if (result.data != null) {
      var response = SignS3DownloadModel.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getMachinesFolderById(String machineId) async {
    console(machineId);
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(QueryOptions(
        variables: {"machineId": machineId},
        document: gql("getMachineFolderId")));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("getMachinesFolderById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      console("getMachinesFolderById - hasException => ${result.data}");
      try {
        var response = GetMachineFolderIdResponse.fromJson(result.data!);
        return ApiResultState.loaded(response);
      }
      catch (e) {
        console(e.toString());
      }

    }
    return ApiResultState.failed(unexpectedError);
  }
}
