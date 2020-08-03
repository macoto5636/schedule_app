import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryAddPage extends StatefulWidget {
  @override
  _DiaryAddPageState createState() => _DiaryAddPageState();
}

class _DiaryAddPageState extends State<DiaryAddPage> {
  DateTime date = DateTime.now();
  final formatView = DateFormat("yyyy年MM月dd日");
  final formatPost = DateFormat("yyyyMMdd");

  var _contextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => _closeDialog(),
        ),
        centerTitle: true,
        title: Text("日記を書く"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){  saveData(); },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                      child: Text(
                          formatView.format(date),
                          style: TextStyle(fontSize: 25.0),
                      )
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 12,top: 0,right: 12,bottom: 0),
              child: TextField(
                controller: _contextController,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(fontSize: 25),
                decoration: InputDecoration(
                  hintText: "内容",
                  focusedBorder: InputBorder.none
                ),
//              maxLines: 50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveData() async{
    if(_contextController.text == ""){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("内容が入力されていません"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: (){ Navigator.pop(context); },
              )
            ],
          );
        }
      );
      return;
    }
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    final data = {
      "date" : formatPost.format((date)),
      "article" : _contextController.text,
      "calendar_id" : calendarId
    };

    var result = await Network().postData(data, "diary/store");

    Navigator.pop(context,true);
  }

  void _closeDialog(){
    if(_contextController.text != ""){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("入力した内容が破棄されますが、よろしいですか？"),
              actions: <Widget>[
                FlatButton(
                  child: Text("キャンセル"),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("OK"),
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          }
      );
    }else{
      Navigator.pop(context);
    }
  }
}
