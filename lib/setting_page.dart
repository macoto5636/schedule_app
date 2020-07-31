import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("設定"),
        centerTitle: true,
      ),
      body: ListView(
        children: listTiles,
      ),
    );

  }
  List<Widget> listTiles = <Widget>[
    Container(
      margin: EdgeInsets.only(top:30,left:15),
      child: Text(
        "基本設定",
//          style: TextStyle(fontSize:25, fontWeight: FontWeight.bold),
      ),
    ),
    Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(color: Colors.black),
        ),
      ),
    ),
    Container(
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(color: Colors.black),
          ),
        ),
        child: ListTile(
          title: Text('テーマカラー'),
        )
    ),
    Container(
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(color: Colors.black),
          ),
        ),
        child: ListTile(
          title: Text('ロック機能'),
        )
    ),
    Container(
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(color: Colors.black),
          ),
        ),
        child: ListTile(
          title: Text('起動時画面'),
        )
    ),
    Container(
      margin: EdgeInsets.only(top:50,left:15),
      child: Text(
          "カレンダー",
//          style: TextStyle(fontSize:25, fontWeight: FontWeight.bold),
        ),
    ),
    Container(
      decoration: new BoxDecoration(
        border: new Border(
          bottom: new BorderSide(color: Colors.black),
        ),
      ),
    ),
    Container(
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(color: Colors.black),
          ),
        ),
        child: ListTile(
          title: Text('週の開始曜日'),
        )
    ),
  ];
}