import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as RiverPod;
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:makula_oem/database/app_database.dart';
import 'package:makula_oem/helper/graphQL/graph_ql_config.dart';
import 'package:makula_oem/helper/utils/constants.dart';
import 'package:makula_oem/helper/utils/routes.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/create_new_ticket_screen.dart';
import 'package:makula_oem/views/screens/dashboard/addNewTicket/provider/add_ticket_provider.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_provider.dart';
import 'package:makula_oem/views/screens/dashboard/dashboard_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/details/machine_detail_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/machines/provider/machine_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/details/procedure_screen.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/procedure_provider.dart';
import 'package:makula_oem/views/screens/dashboard/tabbar/tickets/provider/ticket_provider.dart';
import 'package:makula_oem/views/screens/splash/login/login_provider.dart';
import 'package:makula_oem/views/screens/splash/login/login_screen.dart';
import 'package:makula_oem/views/screens/splash/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

AppDatabase? appDatabase;

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
  appDatabase =
      await $FloorAppDatabase.databaseBuilder("app_database.db").build();
  /*await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
  );*/

  await Permission.camera.request();
  await Permission.microphone.request();
  await Permission.mediaLibrary.request();
  await Permission.storage.request();
  await Permission.accessMediaLocation.request();
  await initHiveForFlutter();

  HttpOverrides.global = MyHttpOverrides();
  ValueNotifier<GraphQLClient> client = GraphQLConfig().graphInit();
  var app = GraphQLProvider(client: client, child: const MyApp());
  runApp(const RiverPod.ProviderScope(
    child:MyApp()
  ));

  // Close the box when the application is shutting down
  // HiveResources.flush();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        ChangeNotifierProvider(create: (_) => ProcedureProvider())
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
