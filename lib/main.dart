import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:listly/utils/theme/app_theme.dart';

import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget with AppThemeData {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      builder: () {
        return GetMaterialApp(
          defaultTransition: Transition.fadeIn,
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController());
            Get.put(UserController());
          }),
          debugShowCheckedModeBanner: false,
          title: 'Listly',
          home: const SplashScreen(),
          theme: appThemeData,
        );
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Image.asset(
            'assets/icons/Logo.png',
            fit: BoxFit.contain,
            width: 230.w,
          ),
        ),
      ),
    );
  }
}
