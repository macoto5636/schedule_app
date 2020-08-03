import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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

//  日記テーブルの内容の変更を検知するフラグ
  var _rebuildFlag;

//  現在のカレンダーの日記一覧を取得する
  Future<List<dynamic>> _getData() async{
    // 現在のカレンダーを取得
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    http.Response res = await Network().getData("diary/get/$calendarId");

    return jsonDecode(res.body);
  }

//  データベースを更新したときに呼び出すことで日記のメインページをビルドする
  callback(bool status){
    setState(() {
      _rebuildFlag = status;
    });
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
              if(_diaryList.length == 0){
                return Center(child: Text("日記が存在しません"));
              }
              return ListView.builder(
                  itemCount: _diaryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    //改行している場合に１行目を取得している
                    var _article = _diaryList[index]["article"].toString().split('\n')[0];

                    //記事が長い場合は先頭15文字を表示するようにしている
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
                        key: Key(index.toString()),
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.175,
                        controller: slidableController,
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                _diaryList[index]["date"],
                                style: TextStyle(fontSize: 17.0,fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          title: Text(
                              _article,
                              style: TextStyle(fontSize: 17.0),
                          ),
                          onTap: (){
                            _moveDiaryDetailPage(context,_diaryList[index]);
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
              return Text("データが存在しません");
            }
          },
        )
      ),
    );
  }

//  日記の追加画面に移動する
//  追加後、日記のメインページをビルドする
  void _returnValueFromDiaryAddPage(BuildContext context) async{
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryAddPage(),
        )
    );
    callback(true);
  }

//  日記の内容ページへ移動する
//  削除処理後、日記のメインページをビルドする
  void _moveDiaryDetailPage(BuildContext context,data){
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryDetailPage(diaryData: data,callback: callback),
        )
    );
  }

//　スライドアクション[削除]で日記の削除する（確認ダイアログなし）
//  削除処理後に、日記のメインページをビルドする
  _deleteDiaryItem(int diaryId) async{
    var result = await Network().getData("diary/delete/$diaryId");
    callback(true);
  }

//  スライドアクション[編集]で日記の編集画面へ移動する
//  更新処理後に、日記のメインページをビルドする
  _moveDiaryEditPage(BuildContext context,item){
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryEditPage(diaryItem: item,callback: callback),
        )
    );
  }
}