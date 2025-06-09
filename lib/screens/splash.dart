import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_angler/screens/walkthrough.dart';
import 'package:eco_angler/util/const.dart';

import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    startTimeout();
  }

  void startTimeout() {
    Timer(const Duration(seconds: 2), () => changeScreen());
  }

  Future<void> changeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('hasLaunched') ?? false;

    if (!isFirstLaunch) {
      await prefs.setBool('hasLaunched', true);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Walkthrough()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainScreen()), // your actual app screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.asset(
                'assets/logotrans.png',
                height: 150.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 40.0),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 15.0),
                child: Text(
                  Constants.appName,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
