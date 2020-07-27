import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:scheduleapp/network_utils/api.dart';

class DiaryAddPage extends StatefulWidget {
  @override
  _DiaryAddPageState createState() => _DiaryAddPageState();
}

class _DiaryAddPageState extends State<DiaryAddPage> {
  DateTime date = DateTime.now();
  final formatView = DateFormat("yyyy年MM月dd日");
  final formatPost = DateFormat("yyyyMMdd");

  var _contextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text("日記を書く"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){  saveData(); },
          )
        ],
      ),
      body: Column(
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
    );
  }

  void saveData() async{
    final data = {
      "date" : formatPost.format((date)),
      "article" : _contextController.text,
      "calendar_id" : 1
    };

    var result = await Network().postData(data, "diary/store");

    Navigator.pop(context);
  }
}
