import 'package:flutter/material.dart';

final Map<String,List<dynamic>> themes = {
  'themeBlueLight'  : [themeBlueLight,"ライトブルー"],
  'themeGreenLight' : [themeGreenLight,"ライトグリーン"],
  'themePinkLight'  : [themePinkLight,"ライトピンク"]
};


final themeBlueLight = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light
);

final themeGreenLight = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light
);

final themePinkLight = ThemeData(
    primarySwatch: Colors.pink,
    brightness: Brightness.light
);

class ThemeNotifier with ChangeNotifier {
  String _themeKey;
  ThemeData _themeData;

  ThemeNotifier(String themeKey){
    this._themeKey = themeKey;
    this._themeData = themes[_themeKey][0];
  }

  getTheme() => _themeData;

  setTheme(String themeKey) async {
    _themeKey = themeKey;
    _themeData = themes[themeKey][0];
    notifyListeners();
  }
}