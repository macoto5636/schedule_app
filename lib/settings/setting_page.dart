import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scheduleapp/settings/setting_startday_page.dart';
import 'package:scheduleapp/settings/setting_theme_page.dart';

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 15,top: 30,bottom: 5),
          child: Text(
            "基本設定",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: new BoxDecoration(
            border: new Border(
              bottom: new BorderSide(color: Colors.grey),
            ),
          ),
        ),
        Container(
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(color: Colors.grey),
              ),
            ),
            child: ListTile(
              title: Text('テーマカラーの変更'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingThemeChangePage())
                );
              },
            )
        ),
//        Container(
//            decoration: new BoxDecoration(
//              border: new Border(
//                bottom: new BorderSide(color: Colors.grey),
//              ),
//            ),
//            child: ListTile(
//              title: Text('ロック機能'),
//            )
//        ),
//        Container(
//            decoration: new BoxDecoration(
//              border: new Border(
//                bottom: new BorderSide(color: Colors.grey),
//              ),
//            ),
//            child: ListTile(
//              title: Text('起動時画面'),
//            )
//        ),
        Container(
          margin: EdgeInsets.only(left: 15,top: 50,bottom: 5),
          child: Text(
            "カレンダー",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          decoration: new BoxDecoration(
            border: new Border(
              bottom: new BorderSide(color: Colors.grey),
            ),
          ),
        ),
        Container(
            decoration: new BoxDecoration(
              border: new Border(
                bottom: new BorderSide(color: Colors.grey),
              ),
            ),
            child: ListTile(
              title: Text('週の開始曜日'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingStartDayPage())
                );
              },
            )
        ),
      ],
    );
  }
}