import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/general_response.dart';
import 'package:makula_oem/helper/model/get_ticket_detail_response.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class TicketViewModel {
  Future<ApiResultState> getListOwnOemOpenTickets() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result =
        await _client.query(QueryOptions(document: gql(listOwnOemOpenTickets)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("TicketViewModel - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = ListOpenTickets.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getListOwnFacilityCloseTickets() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client
        .query(QueryOptions(document: gql(listOwnOemClosedTickets)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("TicketViewModel - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = ListCloseTickets.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getListOwnOemUserOpenTickets() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client
        .query(QueryOptions(document: gql(listOwnOemUserOpenTickets)));
    if (result.isLoading) {
      console("TicketViewModel1 - hasException => ${result.exception}");
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("TicketViewModel2- hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      //console("TicketViewModel3 - data => ${result.data}");
      var response = ListUserOpenTickets.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getListOwnOemUserCloseTickets() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client
        .query(QueryOptions(document: gql(listOwnOemUserClosedTickets)));
    if (result.isLoading) {
      console("TicketViewModel1 - hasException => ${result.exception}");
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console("TicketViewModel2- hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      //console("TicketViewModel3 - data => ${result.data}");
      var response = ListUserCloseTickets.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getTicketById(String ticketId) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: gql(getOwnOemTicketById),
        variables: {"id": ticketId},
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "TicketViewModel: getTicketById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GetTicketDetailResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> updateTicketStatus(String ticketId, String status) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: gql(updateOwnOemTicket),
        variables: {
          "input": {
            "ticketId": ticketId,
            "status": status
          }
        },
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "TicketViewModel: getTicketById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GeneralResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> updateTicketAssignee(String ticketId, String assignee) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.query(
      QueryOptions(
        document: gql(updateOwnOemTicket),
        variables: {
          "input": {
            "ticketId": ticketId,
            "assignee": assignee
          }
        },
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "TicketViewModel: getTicketById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GeneralResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }
  Future<ApiResultState> updateTicketReporter(String ticketId, String reporter) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    console("updateTicketReporter => $ticketId -- $reporter");
    QueryResult result = await _client.query(
      QueryOptions(
        document: gql(updateOwnOemTicket),
        variables: {
          "input": {
            "ticketId": ticketId,
            "user": reporter
          }
        },
      ),
    );
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      console(
          "TicketViewModel: getTicketById - hasException => ${result.exception}");
      return ApiResultState.failed(unexpectedError);
    } else if (result.data != null) {
      var response = GeneralResponse.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }
}
