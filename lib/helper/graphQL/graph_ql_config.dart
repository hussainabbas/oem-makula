import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/helper/utils/flavor_const.dart';

class GraphQLConfig with ChangeNotifier {
  //static String BASE_URL = "https://api-staging.makula.io/graphql/"; //STAGING;
  //static String BASE_URL = "https://api.makula.io/graphql/";  //PRODUCTION;
  static String token = "";
  static String refreshToken = "";

  var httpLink = HttpLink(
    baseUrl,
    defaultHeaders: <String, String>{
      'x-makula-refresh-token': refreshToken,
      'x-makula-token': token,
      'x-makula-auth-request-type': 'LOCAL_STORAGE',
    },
  );

  ValueNotifier<GraphQLClient> graphInit() {
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );

    final Link link = authLink.concat(httpLink);

    ValueNotifier<GraphQLClient> client = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(),
      ),
    );
    return client;
  }

  GraphQLClient clientToQuery() {
    AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $token',
    );
    final Link link = authLink.concat(httpLink);
    return GraphQLClient(
      cache: GraphQLCache(partialDataPolicy: PartialDataCachePolicy.reject),
      link: link,
    );
  }
}
