import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:eco_angler/util/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier{



  ThemeData theme = Constants.lightTheme;
  Key key = UniqueKey();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setKey(value) {
    key = value;
    notifyListeners();
  }

  void setNavigatorKey(value) {
    navigatorKey = value;
    notifyListeners();
  }

  void setTheme(value) {
    theme = value;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("theme", "light"); // always light
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Constants.lightPrimary,
        statusBarIconBrightness: Brightness.dark,
      ));
    });
    notifyListeners();
  }


  ThemeData getTheme(value) {
    return theme;
  }

}