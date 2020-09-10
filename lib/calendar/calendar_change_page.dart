import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarChangePage extends StatefulWidget {
  @override
  _CalendarChangePageState createState() => _CalendarChangePageState();
}

class _CalendarChangePageState extends State<CalendarChangePage> {
  var _rebuildFlag;
  var selectedCalendar;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _rebuildFlag = false;
  }

  callback(){
    setState(() {
      _rebuildFlag = !_rebuildFlag;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("カレンダー"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){ _createCalendarDialog(); },
          )
        ],
      ),
      body: Container(
          child: FutureBuilder(
            future: _getCalendar(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                final _calendars = snapshot.data;
                return ListView.builder(
                    itemCount: _calendars.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey),
                          ),
                        ),
                          child: ListTile(
                            leading: checkIcon(_calendars[index]["id"]),
                            title: Text(_calendars[index]["cal_name"]),
                            onTap: () => changeSelectedCalendar(_calendars[index]),
                            trailing: PopupMenuButton(
                              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text("削除"),
                                    onTap:(){
                                      _deleteCalendar(_calendars[index]["id"]);
                                    }
                                  ),
                                ),
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text("名前の編集"),
                                    onTap:(){
                                      _editCalendarName();
                                    }
                                  ),
                                ),
                              ],
                            ),
                          ),
                      );
                    }
                );
              } else {
                return Text("データが存在しません");
              }
            },
          )
      ),
    );
  }

  ///ユーザーが現在選択しているカレンダー情報をローカルストレージから取得する
  ///ユーザーのカレンダーをデータベースから全て取得する
  ///ユーザーのカレンダーを全て返す
  _getCalendar() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    selectedCalendar = jsonDecode(localStorage.getString('calendar'));

    http.Response res = await Network().getData("calendar/get");

    return jsonDecode(res.body);
  }


  Widget checkIcon(int id){
    if(id == selectedCalendar["id"]){
      return Icon(Icons.check);
    }else{
      return Icon(null);
    }
  }

  ///カレンダーの選択を変更
  changeSelectedCalendar(item) async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.setString('calendar',json.encode(item));

    callback();
  }

  ///新しいカレンダーを作るためのダイアログ形式のフォーム
  _createCalendarDialog(){
    final _formKey = GlobalKey<FormState>();
    var postCalendarName;
    showDialog(
      context: context,
      builder: (BuildContext context) =>
        AlertDialog(
          title: Text("新規カレンダー作成"),
          content: Row(
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "カレンダー名",
                    ),
                    validator: (calendarName){
                      if(calendarName.isEmpty){
                        return "カレンダー名が入力されていません";
                      }
                      postCalendarName = calendarName;
                      return null;
                    },
                  ),
                ),
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("キャンセル"),
              onPressed: (){ Navigator.pop(context); },
              ),
            FlatButton(
              child: Text("追加する"),
              onPressed: (){
                if(_formKey.currentState.validate()){
                  _createCalendar(postCalendarName);
                }
              },
            )
          ],
        )
    );
  }

  ///新規カレンダー作成処理
  ///カレンダー名[value]を受け取りカレンダーテーブルに保存する
  ///作成後callback呼び出して一覧を更新する
  _createCalendar(value) async{
    final data = {
      "cal_name" : value
    };

    var result = await Network().postData(data, "calendar/store");

    Navigator.pop(context);
    callback();
  }

  _deleteCalendar(id) async{
    if(id == selectedCalendar["id"]) {
      print("消せない！！");
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: '選択中のカレンダーは削除できません',
      );
      return;
    }
    Navigator.of(context).pop();
    await Network().getData("calendar/delete/${id}");
    callback();
  }

  _editCalendarName() async{
    print("edit Calendar");
    Navigator.of(context).pop();
  }
}
