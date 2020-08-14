import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryAddPage extends StatefulWidget {
  @override
  _DiaryAddPageState createState() => _DiaryAddPageState();
}

class _DiaryAddPageState extends State<DiaryAddPage> {
  DateTime date = DateTime.now();
  final formatView = DateFormat("yyyy年MM月dd日");
  final formatPost = DateFormat("yyyyMMdd");

  var _contextController = TextEditingController();

  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => _closeDialog(),
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
      body:
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          formatView.format(date),
                          style: TextStyle(fontSize: 25.0),
                        )
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 30,
                      onPressed: (){},
                    )
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
                Container(
                  padding: EdgeInsets.all(16),
                  child: _image == null
                      ? null
                      : Image.file(_image),
                ),
              ],

            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_photo_alternate),
      ),
    );
  }

  void saveData() async{
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

    //以下、送信処理
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    var fullUrl = Network().getUrl('diary/store');
    var header = Network().getMultiHeaders;

    var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
    request.fields['date'] = formatPost.format((date));
    request.fields['article'] = _contextController.text;
    request.fields['calendar_id'] = calendarId.toString();

    //画像を選択しているかチェック
    if(_image != null){
      var pic = await http.MultipartFile.fromPath("image", _image.path);
      request.files.add(pic);
    }

    request.headers.addAll(header);

    var response = await request.send();
    if (response.statusCode == 200) print('Uploaded!');

    Navigator.pop(context,true);
  }

  void _closeDialog(){
    if(_contextController.text != ""){
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("入力した内容が破棄されますが、よろしいですか？"),
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
