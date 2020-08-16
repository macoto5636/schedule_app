import 'package:flutter/material.dart';
import 'package:scheduleapp/extension_diary/diary_add_edit_page.dart';
import 'package:scheduleapp/network_utils/api.dart';

class DiaryDetailPage extends StatelessWidget {
  Function(bool) callback;
  DiaryDetailPage({ this.diaryData,this.callback,this.editIndex });
  final diaryData;
  final editIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(diaryData[editIndex]["date"]),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: (){
              deleteDiaryItem(context,diaryData[editIndex]["id"]);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DiaryAddEditPage(
                        diaryData: diaryData,
                        mode: false,
                        editIndex: editIndex,
                        callback: callback,
                      )
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
                      diaryData[editIndex]["article"],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
                padding: EdgeInsets.all(15),
                child: diaryData[editIndex]["image_path"] != null
                        ? Image.network(Network().imagesDirectory('diary_images') + diaryData[editIndex]["image_path"])
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
    await Network().getData("diary/delete/$diaryId");
  }
}
