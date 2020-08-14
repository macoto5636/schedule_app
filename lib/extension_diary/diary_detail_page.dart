import 'package:flutter/material.dart';
import 'package:scheduleapp/network_utils/api.dart';

import 'diary_edit_page.dart';

class DiaryDetailPage extends StatelessWidget {
  Function(bool) callback;
  DiaryDetailPage({ this.diaryData,this.callback });
  final diaryData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(diaryData["date"]),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: (){
              deleteDiaryItem(context,diaryData["id"]);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryEditPage(diaryItem: diaryData,callback: callback,),
                  )
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      diaryData["article"],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                padding: EdgeInsets.all(15),
                child: diaryData["image_path"] != null
                        ? Image.network(Network().imagesDirectory('diary_images') + diaryData["image_path"])
                        : Container(),
            )
          ],
        ),
      ),
    );
  }
// 編集の確認ダイアログを表示の上、更新する
  void updateDiaryItem(){

  }

// 削除確認ダイアログを表示の上、削除する
  void deleteDiaryItem(BuildContext context,int diaryId){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("日記の削除"),
            content: Text("元には戻せませんが、本当に削除してよろしいですか？"),
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
                  _deleteDiaryItem(diaryId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  callback(true);
                },
              )
            ],
          );
        }
    );
  }

  _deleteDiaryItem(int diaryId) async{
    var result = await Network().getData("diary/delete/$diaryId");
  }
}
