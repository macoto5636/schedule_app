import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:scheduleapp/extension_diary/diary_add_page.dart';
import 'package:scheduleapp/network_utils/api.dart';

class DiaryMainPage extends StatefulWidget {
  @override
  _DiaryMainPageState createState() => _DiaryMainPageState();
}

class _DiaryMainPageState extends State<DiaryMainPage> {
  var resultList;
  var calendarId = 1;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
  }

  Future<List<dynamic>> _getData() async{
    http.Response res = await Network().getData("diary/get/$calendarId");

    final _data = jsonDecode(res.body);

    return _data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("日記"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return DiaryAddPage();
                  },
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              final _diaryList = snapshot.data;
              return ListView.builder(
                  itemCount: _diaryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    //記事が長い場合は先頭15文字を表示するようにしている
                    var _article = _diaryList[index]["article"].toString();

                    if(_article.length >= 10){
                      _article = _article.substring(0,15) + "...";
                    }
                    var _title = _diaryList[index]["date"] + "　　" + _article;

                    return ListTile(
                      title: Text(_title),
                      onTap: (){

                      },
                    );
                  }
              );
            } else {
              print(snapshot.data);
              return Text("データが存在しません");
            }
          },
        )
      ),
    );
  }
}
