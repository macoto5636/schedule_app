import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'schedule_add_repeat_page.dart';
import 'schedule_add_notice_page.dart';
import 'schedule_add_color_page.dart';

enum Answers{
  YES,
  NO
}

class ScheduleAddPage extends  StatefulWidget{
  @override
  ScheduleAddPageState createState() => ScheduleAddPageState();
}
class ScheduleAddPageState extends State<ScheduleAddPage>{
  var _titleController = TextEditingController(text: "");
  var _placeController = TextEditingController(text: "place");
  var _urlController = TextEditingController(text: "url");
  var _memoController = TextEditingController(text: "memo");

  DateTime now = DateTime.now();
  bool _active = false;
  var iconSIze = 25.0;
  DateTime i;
  DateTime st = DateTime.now();
  DateTime st1 = DateTime.now().add(new Duration(hours: 1));
  String stText = DateFormat('yyyy/MM/dd HH:mm')
      .format(DateTime.now())
      .toString();
  DateTime ed = DateTime.now().add(new Duration(hours: 1));
  String edText = DateFormat('yyyy/MM/dd HH:mm')
      .format(DateTime.now().add(new Duration(hours: 1)))
      .toString();

  @override
  void initState() {
    super.initState();
    _clear();
  }

  //
  void _onChanged(bool value) {
    setState(() {
      if (_active) {
        _active = false;
        stText = DateFormat('yyyy/MM/dd HH:mm').format(st).toString();
        edText = DateFormat('yyyy/MM/dd HH:mm').format(ed).toString();
      } else {
        _active = true;
        stText = DateFormat('yyyy/MM/dd').format(st).toString();
        edText = DateFormat('yyyy/MM/dd').format(ed).toString();
      }
    });
  }
  String _value = '';

  void _setValue(String value) => setState(() => _value = value);

  Future _showDialog() async {
    var value = await showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        content: new Text('入力した内容は削除されます。キャンセルしてもよろしいですか？'),
        actions: <Widget>[
          new SimpleDialogOption(child: new Text('OK'),onPressed: (){Navigator.pop(context, Answers.YES);},),
          new SimpleDialogOption(child: new Text('キャンセル'),onPressed: (){Navigator.pop(context, Answers.NO);},),
        ],
      ),
    );
    switch(value) {
      case Answers.YES:
        _setValue('Yes');
        _clear();
        Navigator.of(context).pop();
        break;
      case Answers.NO:
        _setValue('NO');
        break;
    }
  }
  //providerで保持している新しい予定の値を初期化
  void _clear(){
    context.read<ColorChecker>().set(6);
    context.read<RepeatChecker>().set(0);
    context.read<NoticeChecker>().set(0);
  }

  //新しい予定画面
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: (){
            _showDialog();
            },
        ),
        title: Text("新しい予定"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (){
              if(_titleController.text == ""){
                showDialog(
                  context: context,
                  builder: (BuildContext context) => new AlertDialog(
                    content: new Text('タイトルを入力してください'),
                    actions: <Widget>[
                      new SimpleDialogOption(child: new Text('OK'),onPressed: (){Navigator.pop(context);},),
                    ],
                  ),
                );
              }else{
                saveData();
                //_clear();
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      body: _ScheduleAddListView(),
    );
  }

  Widget _ScheduleAddListView(){
    return ListView(
      children: <Widget>[
        ListTile(
          title: TextField(
            controller: _titleController,
            decoration: InputDecoration.collapsed(
              hintText: "タイトル",
            ),
          ),
        ),
        Divider(color: Colors.black,),
        SwitchListTile(
          value: _active,
          activeColor: Colors.blue,
          activeTrackColor: Colors.lightBlueAccent,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.black26,
          secondary: new Icon(
            Icons.refresh,
            size: iconSIze,
          ),
          title: Text('終日'),
          onChanged: _onChanged,
        ),
        ListTile(
          leading: Icon(
            Icons.arrow_forward,
            size: iconSIze,
          ),
          title: Text("開始"),
          trailing: Text(stText),
          onTap: () {
            st = showDateTime(_active,st,true);
          },
        ),
        ListTile(
            leading: Icon(
              Icons.arrow_back,
              size: iconSIze,
            ),
            title: Text("終了"),
            trailing: Text(edText),
            onTap: () {
              ed = showDateTime(_active,ed,false);
            }
        ),
        ListTile(
          leading: Icon(
            Icons.autorenew,
            size: iconSIze,
          ),
          title: Text("繰り返し"),
          trailing: RepeatText(),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubRepeatPage())
          ),
        ), ListTile(
          leading: Icon(
            Icons.timer,
            size: iconSIze,
          ),
          title: Text("通知"),
          trailing: NoticeText(),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubNoticePage())
          ),
//          onTap: () => Navigator.of(context).pushNamed("/notice"),
        ),Divider(color: Colors.black,
        ),ListTile(
          leading: Icon(
            Icons.palette,
            size: iconSIze,
          ),
          title: Text("色"),
          trailing: ColorText(),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubColorPage())
          ),
//          onTap: () => Navigator.of(context).pushNamed("/color"),
        ), ListTile(
          leading: Icon(
            Icons.location_on,
            size: iconSIze,
          ),
          title: TextField(
            controller: _placeController,
            decoration: InputDecoration.collapsed(
              hintText: "場所",
            ),
          ),
        ), ListTile(
          leading: Icon(
            Icons.link,
            size: iconSIze,
          ),
          title: TextField(
            controller: _urlController,
            decoration: InputDecoration.collapsed(
              hintText: "URL",
            ),
          ),
        ), ListTile(
          leading: Icon(
            Icons.subject,
            size: iconSIze,
          ),
          title: TextField(
            controller: _memoController,
            decoration: InputDecoration.collapsed(
              hintText: "メモ",
            ),
          ),
        ), /*ListTile(
                leading: Icon(
                  Icons.,
                  size: iconSIze,
                ),
                title: Text(""),
              ),*/
      ],
    );
  }

  //開始、終了時刻のdatetimepickerを表示する関数
  DateTime showDateTime(bool allDayActive, DateTime dateTime, bool stFlag) {
    if(allDayActive){
      DatePicker.showDatePicker(context,
          showTitleActions: true,
          minTime: DateTime(dateTime.year - 3, dateTime.month, dateTime.day),
          maxTime: DateTime(dateTime.year + 3, dateTime.month, dateTime.day),
          theme: DatePickerTheme(
              headerColor: Colors.white,
              backgroundColor: Colors.white,
              itemStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
              doneStyle: TextStyle(
                  color: Colors.black, fontSize: 16
              )
          ),
          onChanged: (date) {},
          onConfirm: (date) {
            print(st);
            print(date);
            if(stFlag){
              st = date;
              setState(() {
                stText = DateFormat('yyyy/MM/dd').format(st).toString();
                if (date.compareTo(ed) > 0) {
                  ed = st.add(new Duration(hours: 1));
                  edText = DateFormat('yyyy/MM/dd')
                      .format(ed)
                      .toString();
                }
              });
            } else {
              if (st.compareTo(date) > 0) {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text("終了が開始以前の時刻になっています"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      );
                    }
                );
              } else {
                setState(() {
                  ed = date;
                  edText = DateFormat('yyyy/MM/dd')
                      .format(ed)
                      .toString();
                });
              }
            }
          },
          currentTime: dateTime,
          locale: LocaleType.jp
      );
    }else{
      DatePicker.showDateTimePicker(context,
          showTitleActions: true,
          minTime: DateTime(dateTime.year - 3, dateTime.month, dateTime.day),
          maxTime: DateTime(dateTime.year + 3, dateTime.month, dateTime.day),
          theme: DatePickerTheme(
              headerColor: Colors.white,
              backgroundColor: Colors.white,
              itemStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
              ),
              doneStyle: TextStyle(
                  color: Colors.black, fontSize: 16
              )
          ),
          onChanged: (date) {},
          onConfirm: (date) {
            if(stFlag){
              setState(() {
                st = date;
                stText = DateFormat('yyyy/MM/dd HH:mm')
                    .format(st)
                    .toString();
                if (date.compareTo(ed) > 0) {
                  ed = st.add(new Duration(hours: 1));
                  edText = DateFormat('yyyy/MM/dd HH:mm')
                      .format(ed)
                      .toString();
                }
              });
            }else{
              if (st.compareTo(date) > 0) {
                showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        content: Text("終了が開始以前の時刻になっています"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      );
                    }
                );
              } else {
                setState(() {
                  ed = date;
                  edText = DateFormat('yyyy/MM/dd HH:mm')
                      .format(ed)
                      .toString();
                });
              }
            }
          },
          currentTime: dateTime,
          locale: LocaleType.jp
      );
    }
    return dateTime;
  }

  //入力された新しい予定をデータベースに登録する
  void saveData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var selectedCalendarId = jsonDecode(localStorage.getString('calendar'))["id"];

    final data = {
      "title":_titleController.text,
      "all_day":_active,
      "start_date":DateFormat('yyyy-MM-dd HH:mm')
          .format(st)
          .toString(),
      "end_date":DateFormat('yyyy-MM-dd HH:mm')
          .format(ed)
          .toString(),
      "repetition_flag":context.read<RepeatChecker>().flg,
      "repetition":context.read<RepeatChecker>().checked,
      "notification_flag":context.read<NoticeChecker>().flg,
      "notification":context.read<NoticeChecker>().checked,
      "color":context.read<ColorChecker>().listColor[context.read<ColorChecker>().checked].toString(),
      "place":_placeController.text,
      "url":_urlController.text,
      "memo":_memoController.text,
      "calendar_id":selectedCalendarId.toString(),
    };
    print(data);
    var result = await Network().postData(data, "schedules/store");
  }
}
