import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pemmob_modul3_demo/app/modules/register/views/register_page.dart';
import 'package:pemmob_modul3_demo/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/modules/auth/controllers/auth_controller.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/modules/login/views/login_page.dart';
import 'app/modules/notification/controllers/notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync(() async => await SharedPreferences.getInstance());
  await FirebaseMessagingHandler().initPushNotification();
  await FirebaseMessagingHandler().initLocalNotification();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AuthController _authController = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    ),
    initialRoute: _authController.isLoggedIn.value ? '/home' : '/login',
    getPages: [
      GetPage(name: '/login', page: () => LoginPage()),
      GetPage(name: '/home', page: () => HomePage()),
    ],
    );
  }
}