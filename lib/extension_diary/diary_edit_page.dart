import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scheduleapp/network_utils/api.dart';

class DiaryEditPage extends StatefulWidget {
  final diaryItem;
  DiaryEditPage({ Key key,this.diaryItem }) : super(key : key);

  @override
  _DiaryEditPageState createState() => _DiaryEditPageState();
}

class _DiaryEditPageState extends State<DiaryEditPage> {

  DateTime date;
  final formatView = DateFormat("yyyy年MM月dd日");
  final formatPost = DateFormat("yyyyMMdd");

  var _contextController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _contextController = TextEditingController(text: widget.diaryItem["article"]);
    date = DateTime.parse(widget.diaryItem["date"]);
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

  _updateDiaryItem() async{
    final data = {
      "date" : formatPost.format((date)),
      "article" : _contextController.text,
      "calendar_id" : widget.diaryItem["calendar_id"]
    };

    print(data);

    var result = await Network().postData(data, "diary/update/${widget.diaryItem["id"]}");

    Navigator.pop(context);
  }
}
