import 'package:flutter/material.dart';

class SettingThemeChangePage extends StatefulWidget {
  @override
  _SettingThemeChangePageState createState() => _SettingThemeChangePageState();
}

class _SettingThemeChangePageState extends State<SettingThemeChangePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("テーマカラーの変更"),
      ),
      body: Container(

      ),
    );
  }
}
