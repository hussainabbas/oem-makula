import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_new_chat_token.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/utils/app_preferences.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/helper/utils/utils.dart';
import 'package:makula_oem/helper/viewmodels/login_view_model.dart';
import 'package:makula_oem/main.dart';

import '../../../helper/model/login_mobile_oem_response.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final appPreferences = AppPreferences();
  // var _token = "";
  // var _refreshToken = "";
  // final loginBox = Hive.box<LoginMobile>(OfflineResources.LOGIN_TOKEN_BOX);
  // final currentUserBox =
  //     Hive.box<CurrentUser>(OfflineResources.CURRENT_USER_BOX);
  // final oemStatusBox = Hive.box<StatusData>(OfflineResources.OEM_STATUS_BOX);

  @override
  void initState() {
    _getDetailsFromAppPreferences();
    super.initState();
  }

  _getDetailsFromAppPreferences() async {
    var userDetails = await appDatabase?.userDao.getCurrentUserDetailsFromDb();
    var loggedInResponse = await appDatabase?.loginMobileDao.getLoginResponseFromDb();
    var oemStatus = await appDatabase?.oemStatusDao.findAllGetOemStatusesResponses();

    if (loggedInResponse?.token != null) {
      GraphQLConfig.token = loggedInResponse?.token ?? "";
      GraphQLConfig.refreshToken = loggedInResponse?.refreshToken ?? "";

      console("token=> ${loggedInResponse?.token}");
      console("refreshToken=> ${loggedInResponse?.refreshToken}");

      var isConnected = await isConnectedToNetwork();
      if (isConnected) {
        _getCurrentUserDetails();
      } else {
        console("isConnected => $isConnected");
        if (context.mounted) {
          Timer(
              const Duration(seconds: 3),
                  () =>
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      dashboardScreenRoute, (Route<dynamic> route) => false));
        }
      }
    } else {
      Timer(const Duration(seconds: 3),
          () => Navigator.pushReplacementNamed(context, loginScreenRoute));
    }
  }

  _getCurrentUserDetails() async {
    try {
      var result = await LoginViewModel().getCurrentUserDetails();
      result.join(
          (failed) => {
                Navigator.pushReplacementNamed(context, loginScreenRoute),
                console("failed => ${failed.exception}")
              },
          (loaded) => {_getNewChatToken(loaded.data)},
          (loading) => {console("loading => ")});
    } catch (e) {
      console("_getCurrentUserDetails = $e");
      Navigator.pushReplacementNamed(context, loginScreenRoute);
    }
  }

  _getNewChatToken(CurrentUser user) async {
    try {
      var result = await LoginViewModel().getNewChatToken();
      result.join(
          (failed) => {
                Navigator.pushReplacementNamed(context, loginScreenRoute),
                console("failed => ${failed.exception}")
              },
          (loaded) => {
                // console("loaded => " + loaded.data)
                _saveUserDetailsInAppPreferences(user, loaded.data),
              },
          (loading) => {
                console("loading => "),
              });
    } catch (e) {
      console("_getNewChatToken = $e");
      Navigator.pushReplacementNamed(context, loginScreenRoute);
    }
  }

  _saveUserDetailsInAppPreferences(CurrentUser user, NewChatToken token) async {
    user.chatToken = token.getNewChatToken.toString();

    appDatabase?.userDao.insertCurrentUserDetailsIntoDb(user);
    await _getOEMStatues();
  }

  _getOEMStatues() async {
    try {
      var result = await LoginViewModel().getOEMStatuses();
      result.join(
          (failed) => {
                Navigator.pushReplacementNamed(context, loginScreenRoute),
                console("failed => ${failed.exception}")
              },
          (loaded) => {
                // console("loaded => " + loaded.data)
                _saveOEMStatues(loaded.data)
              },
          (loading) => {
                console("loading => "),
              });
    } catch (e) {
      console("_getOEMStatues = $e");
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, loginScreenRoute);
      }
    }
  }

  _saveOEMStatues(StatusData response) async {
    console("_saveOEMStatues => ${response.listOwnOemOpenTickets?.length}");
    await appDatabase?.oemStatusDao.insertGetOemStatusesResponse(response);
    if (context.mounted) {
     Navigator.of(context).pushNamedAndRemoveUntil(
        dashboardScreenRoute, (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      body: _splashScreenContent(context),
    );
  }
}

Widget _splashScreenContent(BuildContext context) {
  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset("assets/images/bg_splash_png.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.fill),
      Opacity(
        opacity: 1,
        child: Image.asset(
          "assets/images/Combined-Shape.png",
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
        ),
      ),
      SvgPicture.asset("assets/images/Makula_Logo_White.svg"),
    ],
  );
}
