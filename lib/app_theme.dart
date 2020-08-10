import 'package:flutter/material.dart';

final Map<String,List<dynamic>> themes = {
  'themeLightBlue'  : [themeLightBlue,"ライトブルー"],
  'themeLightGreen' : [themeLightGreen,"ライトグリーン"],
  'themeLightPink'  : [themeLightPink,"ライトピンク"],
  'themeDarkBlue'   : [themeDarkBlue,"ダークブルー"],
  'themeDarkGreen'  : [themeDarkGreen,"ダークグリーン"]
};

final defaultFloatingActionButtonTheme = FloatingActionButtonThemeData(foregroundColor: Colors.white);

//テーマ設定
final themeLightBlue = ThemeData(
    primarySwatch: Colors.blue,
    accentColor: Colors.blue,
    floatingActionButtonTheme: defaultFloatingActionButtonTheme,
    brightness: Brightness.light
);

final themeLightGreen = ThemeData(
    primarySwatch: Colors.green,
    accentColor: Colors.green,
    floatingActionButtonTheme: defaultFloatingActionButtonTheme,
    brightness: Brightness.light
);

final themeLightPink = ThemeData(
    primarySwatch: Colors.pink,
    accentColor: Colors.pink,
    floatingActionButtonTheme: defaultFloatingActionButtonTheme,
    brightness: Brightness.light
);

final themeDarkBlue = ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.blue,
  floatingActionButtonTheme: defaultFloatingActionButtonTheme,
  primaryColorDark: Colors.blue,
  brightness: Brightness.dark
);

final themeDarkGreen = ThemeData(
    primarySwatch: Colors.green,
    accentColor: Colors.green,
    floatingActionButtonTheme: defaultFloatingActionButtonTheme,
    primaryColorDark: Colors.green,
    brightness: Brightness.dark
);



//テーマ用のプロバイダー
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

//ダークテーマとライトテーマを判定して色を返す
getPrimaryColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark ? Theme.of(context).primaryColorDark : Theme.of(context).primaryColor;