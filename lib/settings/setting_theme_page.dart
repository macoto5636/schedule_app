import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduleapp/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        child: ListView.builder(
            itemCount: themes.length,
            itemBuilder: (BuildContext context,int index){
              String key = themes.keys.elementAt(index);
              return ListTile(
                leading: checkIcon(),
                title: Text(themes[key][1]),
                onTap: () => onThemeChanged(key,context),
              );
            }
        ),
      ),
    );
  }

  //テーマの変更
  void onThemeChanged(String key,BuildContext context)async{
//    final themeNotifier = Provider.of<ThemeNotifier>(context);
      context.read<ThemeNotifier>().setTheme(key);
//    themeNotifier.setTheme(key);

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_key', key);
  }

  //現在のテーマにチェックを入れるウィジェット
  Widget checkIcon(){
    return Icon(Icons.check);
  }
}


