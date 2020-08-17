import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.Dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scheduleapp/main.dart';

import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryAddEditPage extends StatefulWidget {
  Function(bool) callback; //再ビルド用コールバック関数
  final diaryData; //カレンダーの日記の一覧
  final bool mode; //true:追加,false:編集
  var editIndex; //編集するアイテムのインデックス

  DiaryAddEditPage({
    Key key,
    this.diaryData,
    this.editIndex,
    this.mode,
    this.callback
  }) : super(key : key);

  @override
  _DiaryAddEditPageState createState() => _DiaryAddEditPageState();
}

class _DiaryAddEditPageState extends State<DiaryAddEditPage> {
  DateTime _date = DateTime.now();
  DateFormat formatView;
  DateFormat formatPost;

  var diaryItem;
  var mode;
  var diaryData;
  var editIndex;

  var _contextController = TextEditingController();
  String _changeBeforeArticle;//変更する前のテキスト

  File _image;
  String _savedImagePath;
  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("initState");
    //初期化
    mode = widget.mode;
    diaryData = widget.diaryData;
    editIndex = widget.editIndex;

    //日付のフォーマッターを設定
    Intl.defaultLocale = 'ja_JP';
    initializeDateFormatting('ja_JP');

    formatView = DateFormat("yyyy年MM月dd日(E)");
    formatPost = DateFormat("yyyy-MM-dd");

    //編集モードの時の処理
    if(!mode){
      diaryItem = diaryData[editIndex];
      _contextController.text = diaryItem["article"];
      _changeBeforeArticle = diaryItem["article"];
      _date = DateTime.parse(diaryItem["date"]);
      _savedImagePath = diaryItem["image_path"];
    }
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
        title: Text(mode ? "日記を書く" : "日記を編集する"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){
              if(mode){
                saveData();
              }else{
                _updateDiaryItem();
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      formatView.format(_date),
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
              child: imageArea()
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

  //画像取得
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if(pickedFile != null){
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget imageArea(){
    if(_image != null){
      return Container(
          padding: EdgeInsets.all(16),
          child: Image.file(_image)
      );
    }

    //保存されている画像がある場合
    if(_savedImagePath != null){
      return Container(
        padding: EdgeInsets.all(16),
        child: Image.network(Network().imagesDirectory('diary_images') + diaryItem["image_path"]),
      );
    }

    if(_image == null){
      return null;
    }
  }

  void saveData() async{
    if(_contextController.text == ""){
      contentEmptyDialog();
      return;
    }

    //日記の新規追加
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    var fullUrl = Network().getUrl('diary/store');
    var header = Network().getMultiHeaders;

    var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
    request.fields['date'] = formatPost.format((_date));
    request.fields['article'] = _contextController.text;
    request.fields['calendar_id'] = calendarId.toString();

    //画像を選択しているかチェック
    if(_image != null){
      var pic = await http.MultipartFile.fromPath("image", _image.path);
      request.files.add(pic);
    }

    request.headers.addAll(header);

    var response = await request.send();

    widget.callback(true);
    Navigator.pop(context,true);
  }

  _updateDiaryItem() async{
    if(_contextController.text == ""){
      contentEmptyDialog();
      return;
    }

    //更新処理
    var fullUrl = Network().getUrl('diary/update/${diaryItem["id"]}');
    var header = Network().getMultiHeaders;

    var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
    request.fields['date'] = formatPost.format((_date));
    request.fields['article'] = _contextController.text;
    request.fields['calendar_id'] = diaryItem["calendar_id"].toString();

    //画像を選択しているかチェック
    if(_image != null){
      var pic = await http.MultipartFile.fromPath("image", _image.path);
      request.files.add(pic);
    }

    request.headers.addAll(header);

    var response = await request.send();

    widget.callback(true);
    Navigator.pop(context);
  }

  //日記のテキストが空ではないかチェック
  void contentEmptyDialog(){
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
  }

  _closeDialog() {
    if(mode){
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
    }else{
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
            this._date = date;
          });
          alreadyItem();
        },
        currentTime: _date,
        locale: LocaleType.jp
    );
  }

  //既に登録されているページなら編集画面と入れ替える
  alreadyItem(){
    var judgeResult;
    judge(diary,callback){
      if(diary["date"] == formatPost.format((_date))){
          mode = false;
          diaryItem = diary;
          _contextController.text = diaryItem["article"];
          _changeBeforeArticle = diaryItem["article"];
          _date = DateTime.parse(diaryItem["date"]);
          _savedImagePath = diaryItem["image_path"];

        return false;
      }
      return true;
    }
    for(int i = 0;i < diaryData.length;i++){
      judgeResult = judge(diaryData[i],widget.callback);
      //選んだ日の日記が見つかればループを抜ける
      if(!judgeResult){
        editIndex = i;
        break;
      }
    }

    //追加ページに変更のため初期化
    if(judgeResult){
      mode = true;
      _contextController.text = "";
      _savedImagePath = null;
      _changeBeforeArticle = "";
      _image = null;
    }
  }

}
