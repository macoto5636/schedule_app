import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingStartDayPage extends StatefulWidget {
  @override
  _SettingStartDayPageState createState() => _SettingStartDayPageState();
}

class _SettingStartDayPageState extends State<SettingStartDayPage> {
  static const String _startDayKey = 'start_day';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<bool> _futures;
  int _index;

  var rebuild = false;
  //1〜7 : 月〜日
  List<String> days = [
    "月曜日",
    "火曜日",
    "水曜日",
    "木曜日",
    "金曜日",
    "土曜日",
    "日曜日"
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futures = getStartDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("週の開始曜日の変更"),
      ),
      body: Container(
        child: FutureBuilder(
          future: _futures,
          builder: (BuildContext context,AsyncSnapshot snapshot){
            if(snapshot.hasData){
              return ListView.builder(
                itemCount: days.length,
                itemBuilder: (BuildContext context,int index){
                  return ListTile(
                    leading: checkListItem(index),
                    title: Text(days[index]),
                    onTap: () => onChangedStartDay(index),
                  );
                },
              );
            }else{
              return Text("処理待ち");
            }
          },
        )
      ),
    );
  }

  //現在の開始曜日の設定値を取得(1~7)
  Future<bool> getStartDay() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    _index = pref.getInt(_startDayKey) ?? 1;
    return true;
  }

  //選択されている場合にはチェックアイコンを設定
  checkListItem(int value){
    print(_index);
    if(value == (_index - 1)){
      return Icon(Icons.check);
    }else{
      return Icon(null);
    }
  }

  //開始曜日の設定値を変更・保存
  onChangedStartDay(int value) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt(_startDayKey, value + 1);
    setState(() {
      _index = value + 1;
    });
  }
}