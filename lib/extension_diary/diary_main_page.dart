import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scheduleapp/extension_diary/diary_add_edit_page.dart';
import 'package:scheduleapp/extension_diary/diary_detail_page.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryMainPage extends StatefulWidget {
  @override
  _DiaryMainPageState createState() => _DiaryMainPageState();
}

class _DiaryMainPageState extends State<DiaryMainPage> {
  final SlidableController slidableController = SlidableController();
  List resultList;
  var diaryList;

//  日記テーブルの内容の変更を検知するフラグ
  var _rebuildFlag;

//  現在のカレンダーの日記一覧を取得する
  Future<List<dynamic>> _getData() async{
    // 現在のカレンダーを取得
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    http.Response res = await Network().getData("diary/get/$calendarId");
    diaryList = jsonDecode(res.body);

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
//              _returnValueFromDiaryAddPage(context);
              branchToEditAdd();
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
              var temp = _diaryList[0]["date"].toString().substring(0,7);//yyyy-MM
              var flag = true;
              return ListView.builder(
                  itemCount: _diaryList.length,
                  itemBuilder: (BuildContext context, int index) {

                    //改行している場合に１行目を取得している
                    var _article = _diaryList[index]["article"].toString().split('\n')[0];

                    //記事が長い場合は先頭15文字を表示するようにしている
                    if(_article.length >= 15){
                      _article = _article.substring(0,15) + "...";
                    }
                    if(index != 0){
                      if(temp != _diaryList[index]["date"].toString().substring(0,7)){
                        flag = true;
                        temp = _diaryList[index]["date"].toString().substring(0,7);
                      }else{
                        flag = false;
                      }
                    }
                    print(temp);
                    print("flag : $flag");
                    return Column(
                      children: <Widget>[
                        flag ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                color: Colors.grey.withOpacity(0.5),
//                                decoration: BoxDecoration(
//                                  border: Border(
//                                    bottom: BorderSide(color: Colors.grey),
//                                  ),
//                                ),
                                padding: EdgeInsets.only(left: 16,top: 4,bottom: 4),
                                child: Text(temp),
                              ),
                            )
                          ],
                        ) : Container(),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.withOpacity(0.5)),
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
                                _moveDiaryDetailPage(context,index);
                              },
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                              caption: '編集',
                              icon: Icons.edit,
                              color: Colors.grey,
                              onTap: (){
                                _moveDiaryEditPage(context, index);
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
                        ),
                      ],
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


//  現在日の日記を追加する
//  すでに存在する場合は編集ページに飛ぶ
  void branchToEditAdd(){
    var today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    bool mode = true; ////true:追加,false:編集
    var editIndex;

    bool judge(diary){
      if(diary["date"] == today){
        mode = false;
        return true;
      }
      return false;
    }

    for(int i = 0;i < diaryList.length;i++){
      if(judge(diaryList[i])){
        editIndex = i;
        break;
      }
    }

    print("branch add edit");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DiaryAddEditPage(
              diaryData: diaryList,
              mode: mode,
              editIndex: editIndex,
              callback: callback,
            )
        )
    );
  }
//  日記の内容ページへ移動する
//  削除処理後、日記のメインページをビルドする
  void _moveDiaryDetailPage(BuildContext context,index){
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryDetailPage(diaryData: diaryList,callback: callback,editIndex: index,),
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
  _moveDiaryEditPage(BuildContext context,index){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DiaryAddEditPage(
              diaryData: diaryList,
              mode: false,
              editIndex: index,
              callback: callback,
            )
        )
    );
  }
}