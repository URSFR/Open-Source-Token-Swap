

import 'dart:js_util';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:js/js.dart';
import 'package:ostokenswap/provider/user.dart';
import 'package:ostokenswap/screens/login_screen.dart';
import 'package:provider/provider.dart';

import 'blockchain/metamask.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(measurementId: "",storageBucket: "",authDomain: "",apiKey: "", appId: "", messagingSenderId: "", projectId: ""));

  configLoading();
  // runApp(const MyApp());
  runApp(MultiProvider(providers:[ ChangeNotifierProvider<MetaMaskProvider>(
    create: (_)=> MetaMaskProvider(),),
    ChangeNotifierProvider(
      create: (_)=> UserProvider(),),
    // ChangeNotifierProvider(
    //   create: (_)=> StoreProvider(),),
    // ChangeNotifierProvider(
    //   create: (_)=> CartProvider(),),
    // ChangeNotifierProvider(
    //   create: (_)=> CouponProvider(),),
    // ChangeNotifierProvider(
    //   create: (_)=> OrderProvider(),),
  ],

    child: MaterialApp(home: MyApp(), builder: EasyLoading.init(),
    ),
  ),);
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      title: 'Token To Swap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}
