import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_angler/providers/app_provider.dart';
import 'package:eco_angler/screens/splash.dart';
import 'package:eco_angler/util/const.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget? child) {
        return MaterialApp(
          key: appProvider.key,
          debugShowCheckedModeBanner: false,
          navigatorKey: appProvider.navigatorKey,
          title: Constants.appName,
          theme: appProvider.theme,
          darkTheme: null,
          home: SplashScreen(),
        );
      },
    );
  }
}