import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.Dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:scheduleapp/extension_diary/diary_edit_page.dart';

import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryAddPage extends StatefulWidget {
  DiaryAddPage({ Key key,this.diaryData,this.callback }) : super(key : key);
  Function(bool) callback;
  final List diaryData;
  @override
  _DiaryAddPageState createState() => _DiaryAddPageState();
}

class _DiaryAddPageState extends State<DiaryAddPage> {
  DateTime date = DateTime.now();
  DateFormat formatView;
  DateFormat formatPost;

  List<String> days = [
    "月曜日",
    "火曜日",
    "水曜日",
    "木曜日",
    "金曜日",
    "土曜日",
    "日曜日"
  ];

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
  void initState() {
    // TODO: implement initState
    super.initState();
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting('ja_JP');

    formatView = DateFormat("yyyy年MM月dd日(E)");
    formatPost = DateFormat("yyyy-MM-dd");
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
      body:SingleChildScrollView(
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
                      onPressed: (){
                        selectDate();
                      },
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

  selectDate(){
    DatePicker.showDatePicker(
        context,
        showTitleActions: true,
        minTime: DateTime(2020, 1, 1),
        maxTime: DateTime(2025, 12, 31),
        onChanged: (date) {
          print('change $date');
        },
        onConfirm: (date) {
          setState(() {
            this.date = date;
          });
          alreadyItem();
        },
        currentTime: DateTime.now(),
        locale: LocaleType.jp
    );
  }

  //既に登録されているページなら編集画面と入れ替える
  alreadyItem(){
    judge(diary,callback){
      if(diary["date"] == formatPost.format((date))){
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => DiaryEditPage(diaryItem: diary,callback: callback,)
        ));
      }
    }
    widget.diaryData.forEach(
        (diary) => judge(diary,widget.callback)
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

    widget.callback(true);
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
