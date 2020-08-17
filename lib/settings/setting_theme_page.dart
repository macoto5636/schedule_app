import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduleapp/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingThemeChangePage extends StatefulWidget {
  @override
  _SettingThemeChangePageState createState() => _SettingThemeChangePageState();
}

class _SettingThemeChangePageState extends State<SettingThemeChangePage> {
  Future<String> _futures;
  String _themeKey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futures = _getThemeKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("テーマカラーの変更"),
      ),
      body: Container(
        child: FutureBuilder(
          future: _futures,
          builder: (BuildContext context,AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: themes.length,
                  itemBuilder: (BuildContext context,int index){
                    String key = themes.keys.elementAt(index);
                    return ListTile(
                      leading: checkIcon(key),
                      title: Text(themes[key][1]),
                      onTap: () => onThemeChanged(key,context),
                    );
                  }
              );
            }else{
              return Center(
                  child: CircularProgressIndicator()
              );
            }
        }
      )
      ),
    );
  }

  Future<String> _getThemeKey() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _themeKey = prefs.getString("theme_key") ?? "themeLightBlue";
    return _themeKey;
  }

  //テーマの変更
  void onThemeChanged(String key,BuildContext context) async{
    context.read<ThemeNotifier>().setTheme(key);

    setState(() {
      _themeKey = key;
    });

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_key', key);
  }

  //現在のテーマにチェックを入れるウィジェット
  Widget checkIcon(String key){
    if(_themeKey == key){
      return Icon(Icons.check);
    }else{
      return Icon(null);
    }
  }
}


