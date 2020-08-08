import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduleapp/extension_diary/diary_main_page.dart';
import 'package:scheduleapp/network_utils/api.dart';

class DiaryEditPage extends StatefulWidget {
  final diaryItem;
  Function(bool) callback;
  DiaryEditPage({ Key key,this.diaryItem,this.callback }) : super(key : key);

  @override
  _DiaryEditPageState createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {

  DateTime _date;
  final formatView = DateFormat("yyyy年MM月dd日");
  final formatPost = DateFormat("yyyyMMdd");

  var _contextController;
  String _changeBeforeArticle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _contextController = TextEditingController(text: widget.diaryItem["article"]);
    _changeBeforeArticle = widget.diaryItem["article"];
    _date = DateTime.parse(widget.diaryItem["date"]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _contextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => _closeDialog(),
        ),
        centerTitle: true,
        title: Text("編集"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){
              _updateDiaryItem();
            },
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
                        formatView.format(_date),
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

  _updateDiaryItem() async{
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
    final data = {
      "date" : formatPost.format((_date)),
      "article" : _contextController.text,
      "calendar_id" : widget.diaryItem["calendar_id"]
    };

    var result = await Network().postData(data, "diary/update/${widget.diaryItem["id"]}");

    widget.callback(true);
    Navigator.pop(context);
  }

  _closeDialog() {
    if(_contextController.text != _changeBeforeArticle){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("編集の破棄"),
              content: Text("変更した内容が破棄されますが、よろしいですか？"),
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
