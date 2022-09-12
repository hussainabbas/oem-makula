import 'dart:convert';

import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/graphQL/api_calls.dart';
import 'package:makula_oem/helper/graphQL/api_result_state.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_new_chat_token.dart';
import 'package:makula_oem/helper/model/login_mobile_oem_response.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/utils.dart';

class LoginViewModel {
  Future<ApiResultState> login(String email, String password) async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client.mutate(
      MutationOptions(
        variables: {
          "input": {"username": email, "password": password}
        },
        document: gql(loginMobileOem),
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
      var loginMobile = result.data!['loginMobileOem'];
      Map<String, dynamic> jsonModel = json.decode(loginMobile);
      var response = LoginMobile.fromJson(jsonModel);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getCurrentUserDetails() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client
        .query(QueryOptions(document: gql(currentUser)));
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
      var response = CurrentUser.fromJson(result.data!['currentUser']);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }

  Future<ApiResultState> getNewChatToken() async {
    GraphQLConfig graphQLConfiguration = GraphQLConfig();
    GraphQLClient _client = graphQLConfiguration.clientToQuery();
    QueryResult result = await _client
        .query(QueryOptions(document: gql(newChatToken)));
    if (result.isLoading) {
      return ApiResultState.loading();
    }
    if (result.hasException) {
      if (result.exception!.graphqlErrors.isNotEmpty) {
          return ApiResultState.failed(result.exception!.graphqlErrors[0].message);
      }
      console("hasException => ${result.exception}");
      return ApiResultState.failed(noUserError);
    } else if (result.data != null) {
      var response = NewChatToken.fromJson(result.data!);
      return ApiResultState.loaded(response);
    }
    return ApiResultState.failed(unexpectedError);
  }
}
