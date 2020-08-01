import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:scheduleapp/extension_diary/diary_add_page.dart';
import 'package:scheduleapp/extension_diary/diary_detail_page.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diary_edit_page.dart';

class DiaryMainPage extends StatefulWidget {
  @override
  _DiaryMainPageState createState() => _DiaryMainPageState();
}

class _DiaryMainPageState extends State<DiaryMainPage> {
  final SlidableController slidableController = SlidableController();
  var resultList;
  var _rebuildFlag;

  Future<List<dynamic>> _getData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    http.Response res = await Network().getData("diary/get/$calendarId");

    return jsonDecode(res.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _rebuildFlag = false;
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
              _returnValueFromDiaryAddPage(context);
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
                    var _article = _diaryList[index]["article"].toString().split('\n')[0];

                    if(_article.length >= 15){
                      _article = _article.substring(0,15) + "...";
                    }
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Slidable(
                        actionPane: SlidableScrollActionPane(),
                        actionExtentRatio: 0.175,
                        controller: slidableController,
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _diaryList[index]["date"],
                                style: TextStyle(fontSize: 15.0),
                              ),
                            ],
                          ),
                          title: Text(
                              _article,
                              style: TextStyle(fontSize: 17.0),
                          ),
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                              return DiaryDetailPage(diaryData:_diaryList[index]);
                            }));
                          },
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: '編集',
                            icon: Icons.edit,
                            color: Colors.grey,
                            onTap: (){
                              _moveDiaryEditPage(context, _diaryList[index]);
                            },
                          ),
                          IconSlideAction(
                            caption: '削除',
                            icon: Icons.delete_forever,
                            color: Colors.red,
                            onTap: (){ _deleteDiaryItem(_diaryList[index]["id"]); },
                          )
                        ],
                      ),
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

  void _returnValueFromDiaryAddPage(BuildContext context) async{
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryAddPage(),
        )
    );

    setState(() {
      _rebuildFlag = true;
    });
  }

  _deleteDiaryItem(int diaryId) async{
    var result = await Network().getData("diary/delete/$diaryId");
    setState(() {
      _rebuildFlag = true;
    });
  }

  _moveDiaryEditPage(BuildContext context,item) async{
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryEditPage(diaryItem: item,),
        )
    );

    setState(() {
      _rebuildFlag = true;
    });
  }
}

