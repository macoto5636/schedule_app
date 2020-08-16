import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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
  var formatView;
  var formatPost;

  var _contextController;
  String _changeBeforeArticle;

  String _savedImagePath;
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

    _contextController = TextEditingController(text: widget.diaryItem["article"]);
    _changeBeforeArticle = widget.diaryItem["article"];
    _date = DateTime.parse(widget.diaryItem["date"]);
    _savedImagePath = widget.diaryItem["image_path"];
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
            Center(
              child:imageWidget()
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

  Widget imageWidget(){
    //現在選んでいる画像がある場合
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
        child: Image.network(Network().imagesDirectory('diary_images') + widget.diaryItem["image_path"]),
      );
    }
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

    //更新処理
    var fullUrl = Network().getUrl('diary/update/${widget.diaryItem["id"]}');
    var header = Network().getMultiHeaders;

    var request = http.MultipartRequest('POST', Uri.parse(fullUrl));
    request.fields['date'] = formatPost.format((_date));
    request.fields['article'] = _contextController.text;
    request.fields['calendar_id'] = widget.diaryItem["calendar_id"].toString();

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
        currentTime: DateTime.now(),
        locale: LocaleType.jp
    );
  }

  //既に登録されているページなら編集画面と入れ替える
  alreadyItem(){
    judge(diary,callback){
      if(diary["date"] == formatPost.format((_date))){
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => DiaryEditPage(diaryItem: diary,callback: callback,)
        ));
      }
    }
  }
}
