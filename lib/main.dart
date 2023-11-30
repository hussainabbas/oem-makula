import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/model/chat_keys.dart';
import 'package:makula_oem/helper/model/facilities.dart';
import 'package:makula_oem/helper/model/get_current_user_details_model.dart';
import 'package:makula_oem/helper/model/get_status_response.dart';
import 'package:makula_oem/helper/model/list_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_open_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_close_tickets_model.dart';
import 'package:makula_oem/helper/model/list_user_open_tickets_model.dart';
import 'package:makula_oem/helper/model/login_mobile_oem_response.dart';
import 'package:makula_oem/helper/model/machine_information.dart';
import 'package:makula_oem/helper/model/open_ticket_model.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/hive_resources.dart';
import 'package:makula_oem/helper/utils/offline_resources.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/create_new_ticket_screen.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/provider/add_ticket_provider.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/details/machine_detail_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/ticket_detail_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/screens/splash/login/login_provider.dart';
import 'package:makula_oem/views/screens/splash/login/login_screen.dart';
import 'package:makula_oem/views/screens/splash/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );*/
  registerHive();
  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.mediaLibrary.request();
  await Permission.storage.request();
  await Permission.accessMediaLocation.request();
  await initHiveForFlutter();

  HttpOverrides.global = MyHttpOverrides();
  ValueNotifier<GraphQLClient> client = GraphQLConfig().graphInit();
  var app = GraphQLProvider(client: client, child: const MyApp());
  runApp(app);
}

void registerHive() async {
  await Hive.initFlutter();

  // Register Hive adapters for your models
  Hive.registerAdapter(LoginMobileAdapter());
  Hive.registerAdapter(CurrentUserAdapter());
  Hive.registerAdapter(ChatKeysAdapter());
  Hive.registerAdapter(StatusDataAdapter());
  Hive.registerAdapter(ListOwnOemOpenTicketsAdapter());
  Hive.registerAdapter(OemStatusAdapter());
  Hive.registerAdapter(StatusesAdapter());
  Hive.registerAdapter(ListUserOpenTicketsAdapter());
  Hive.registerAdapter(OpenTicketAdapter());
  Hive.registerAdapter(MachineInformationAdapter());
  Hive.registerAdapter(FacilityAdapter());

  Hive.registerAdapter(ListUserCloseTicketsAdapter());

  Hive.registerAdapter(ListOpenTicketsAdapter());

  Hive.registerAdapter(ListCloseTicketsAdapter());
  // Register adapters for other models as needed

  await hiveInitOpenBox();
}

Future<void> hiveInitOpenBox() async {
  if (HiveResources.loginBox == null) {
    await HiveResources.init();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ));
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TicketProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MachineProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddTicketProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),
      ],
      child: GetMaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        initialRoute: splashScreenRoute,
        theme: ThemeData.light(),
        routes: {
          splashScreenRoute: (context) => const SplashScreen(),
          loginScreenRoute: (context) => const LoginScreen(),
          dashboardScreenRoute: (context) => const DashboardScreen(),
          //ticketDetailScreenRoute: (context) => const TicketDetailScreen(),
          machineDetailScreenRoute: (context) => const MachineDetailsScreen(),
          addTicketStep0ScreenRoute: (context) => const CreateNewTicket(),
        },
      ),
    );
  }
}
