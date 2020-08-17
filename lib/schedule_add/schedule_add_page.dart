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

class ScheduleEditPage extends  StatefulWidget{
  Map data;
  DateTime dateTime;

  ScheduleEditPage({this.data,this.dateTime}){
    if(data == null){
      data = {
        "id":null,
        "title" : "title",
        "all_day" : false,
        "start_date" : DateTime.now(),
        "end_date" : DateTime.now().add(new Duration(hours: 1)),
        "repetition_flag" : false,
        "repetition" : 0,
        "notification_flag" : false,
        "notification" : "1000000",
        "color" : "4282434815",
        "memo" : "",
        "place" : "",
        "url" : "",
        "calendar_id": 1,
      };
      if(dateTime != null){
        data["start_date"] = dateTime.add(new Duration(hours: 12));
        data["end_date"] = data["start_date"].add(new Duration(hours: 1));
      }
    }else{
      data["start_date"] = DateTime.parse(data["start_date"].toString());
      data["end_date"] = DateTime.parse(data["end_date"].toString());

      if(data["all_day"] == 0){
        data["all_day"] = false;
      }else{
        data["all_day"] = true;
      }
      if(data["repetition_flag"] == 0){
        data["repetition_flag"] = false;
      }else{
        data["repetition_flag"] = true;
      }
      if(data["notification_flag"] == 0){
        data["notification_flag"] = false;
      }else{
        data["notification_flag"] = true;
      }
      if(data["memo"] == null){
        data["memo"] = "";
      }
      if(data["place"] == null){
        data["place"] = "";
      }
      if(data["url"] == null) {
        data["url"] = "";
      }
    }
  }
  @override
  ScheduleEditPageState createState() => ScheduleEditPageState(data);
}

class ScheduleEditPageState extends State<ScheduleEditPage>{
  final Map originalData;
  Map scheduleData;

  var _titleController;
  var _placeController;
  var _urlController;
  var _memoController;

  DateTime now = DateTime.now();
  String sTimeText;
  String eTimeText;

  var iconSIze = 25.0;

  ScheduleEditPageState(this.originalData);

  @override
  void initState(){
    super.initState();
    scheduleData = {...widget.data};

    if (!scheduleData['all_day']) {
      sTimeText = DateFormat('yyyy/MM/dd HH:mm').format(scheduleData['start_date']).toString();
      eTimeText = DateFormat('yyyy/MM/dd HH:mm').format(scheduleData['end_date']).toString();
    } else {
      sTimeText = DateFormat('yyyy/MM/dd').format(scheduleData['start_date']).toString();
      eTimeText = DateFormat('yyyy/MM/dd').format(scheduleData['end_date']).toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      List colorList = context.read<ColorChecker>().listColor;
      for(int i = 0; i < colorList.length; i++){
        if(scheduleData["color"] == colorList[i].toString()){
          context.read<ColorChecker>().set(i);
          break;
        }
      }
      context.read<RepeatChecker>().set(scheduleData["repetition"]);
      context.read<NoticeChecker>().setString(scheduleData["notification"]);
    });

    _titleController = TextEditingController(text: scheduleData["title"]);
    _placeController = TextEditingController(text: scheduleData["place"]);
    _urlController = TextEditingController(text: scheduleData["url"]);
    _memoController = TextEditingController(text: scheduleData["memo"]);
  }

  //予定画面
  @override
  Widget build(BuildContext context) {
//    print (scheduleData);
    return Scaffold(
      appBar: _appBar(),
      body: _ScheduleAddListView(),
    );
  }
  //表示するAppBarを選択
  //scrrenCheckが0なら予定追加画面用のAppBar
  //scrrenCheckが1なら予定編集画面用のAppBar
  Widget _appBar(){
    Widget _appBar;
    if(scheduleData["id"] == null){
      _appBar = _scheduleAddAppBar();
    }else{
      _appBar = _scheduleChangeAppBar();
    }
    return _appBar;
  }
  //予定追加画面用のAppBar
  Widget _scheduleAddAppBar(){
    print(scheduleData["all_day"]);
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: (){
          if(_inputChangeCheck()){              //予定のデータが初期値と違うとき、削除確認ダイアログを表示
            _inputDeleteCheckDialog();
          }else{                          //初期値のままならpop
            Navigator.of(context).pop();
          }
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
              Navigator.of(context).pop();
            }
          },
        )
      ],
    );
  }

  //予定編集画面用のAppBar
  Widget _scheduleChangeAppBar(){
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.close),
        onPressed: (){
          if(_inputChangeCheck()){
            _inputDeleteCheckDialog();
          }else{
            Navigator.of(context).pop();
          }
        },
      ),
      title: Text("予定の変更"),
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
              Navigator.of(context).pop();
            }
          },
        )
      ],
    );
  }

  //bodyに表示するListView
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
          value: scheduleData['all_day'],
          activeColor: Colors.blue,
          activeTrackColor: Colors.lightBlueAccent,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.black26,
          secondary: new Icon(
            Icons.refresh,
            size: iconSIze,
          ),
          title: Text('終日'),
          onChanged: _allDayChanged,
        ),
        ListTile(
          leading: Icon(
            Icons.arrow_forward,
            size: iconSIze,
          ),
          title: Text("開始"),
          trailing: Text(sTimeText),
          onTap: () {scheduleData["start_date"] = showDateTime(scheduleData["start_date"],true);},
        ),
        ListTile(
            leading: Icon(
              Icons.arrow_back,
              size: iconSIze,
            ),
            title: Text("終了"),
            trailing: Text(eTimeText),
            onTap: () {scheduleData["end_date"] = showDateTime(scheduleData["end_date"],false);}
        ),
        ListTile(
          leading: Icon(
            Icons.autorenew,
            size: iconSIze,
          ),
          title: Text("繰り返し"),
          trailing: RepeatText(),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubRepeatPage())),
        ), ListTile(
          leading: Icon(
            Icons.timer,
            size: iconSIze,
          ),
          title: Text("通知"),
          trailing: NoticeText(),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubNoticePage())),
        ),Divider(color: Colors.black,
        ),ListTile(
          leading: Icon(
            Icons.palette,
            size: iconSIze,
          ),
          title: Text("色"),
          trailing: ColorText(),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SubColorPage())),
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
        ),
      ],
    );
  }

  //入力したデータの削除確認ダイアログ
  Future _inputDeleteCheckDialog() async {
    var value = await showDialog(
      context: context,
      builder: (BuildContext context) => new AlertDialog(
        content: new Text('入力した内容は削除されます。キャンセルしてもよろしいですか？'),
        actions: <Widget>[
          new SimpleDialogOption(child: new Text('OK'),onPressed: (){Navigator.pop(context);Navigator.pop(context);},),
          new SimpleDialogOption(child: new Text('キャンセル'),onPressed: (){Navigator.pop(context);},),
        ],
      ),
    );
  }

  //初期値か編集済みかをチェック
  bool _inputChangeCheck(){
    bool value;
    //予定情報をMap:scheduleDataにセットする
    set();
    if(
        originalData["title"] != scheduleData["title"] ||
        originalData["all_day"] != scheduleData["all_day"] ||
        originalData["start_date"] != scheduleData["start_date"] ||
        originalData["end_date"] != scheduleData["end_date"] ||
        originalData["repetition"] != scheduleData["repetition"] ||
        originalData["notification"] != scheduleData["notification"] ||
        originalData["color"] != scheduleData["color"] ||
        originalData["memo"] != scheduleData["memo"] ||
        originalData["place"] != scheduleData["place"] ||
        originalData["url"] != scheduleData["url"]
    ){
      value = true;
    }else{
      value = false;
    }
    return value;
  }

  //終日の radioButton が切り替わるときの処理
  void _allDayChanged(bool value) {
    //終日フラグを逆値にし、開始・終了の表示を変更する
    setState(() {
      scheduleData['all_day'] = value;
      if (!scheduleData['all_day']) {
        sTimeText = DateFormat('yyyy/MM/dd HH:mm').format(scheduleData['start_date']).toString();
        eTimeText = DateFormat('yyyy/MM/dd HH:mm').format(scheduleData['end_date']).toString();
      } else {
        sTimeText = DateFormat('yyyy/MM/dd').format(scheduleData['start_date']).toString();
        eTimeText = DateFormat('yyyy/MM/dd').format(scheduleData['end_date']).toString();
      }
    });
  }

  //開始・終了時刻のdatetimepicker
  DateTime showDateTime(DateTime dateTime, bool stFlag) {
    if(scheduleData["all_day"]){
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
            if(stFlag){
              scheduleData['start_date'] = date;
              setState(() {
                sTimeText = DateFormat('yyyy/MM/dd').format(scheduleData['start_date']).toString();
                if (date.compareTo(scheduleData['end_date']) > 0) {
                  scheduleData['end_date'] = scheduleData['start_date'].add(new Duration(hours: 1));
                  eTimeText = DateFormat('yyyy/MM/dd')
                      .format(scheduleData['end_date'])
                      .toString();
                }
              });
            } else {
              if (scheduleData['start_date'].compareTo(date) > 0) {
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
                  scheduleData['end_date'] = date;
                  eTimeText = DateFormat('yyyy/MM/dd')
                      .format(scheduleData['end_date'])
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
                scheduleData['start_date'] = date;
                sTimeText = DateFormat('yyyy/MM/dd HH:mm')
                    .format(scheduleData['start_date'])
                    .toString();
                if (date.compareTo(scheduleData['end_date']) > 0) {
                  scheduleData['end_date'] = scheduleData['start_date'].add(new Duration(hours: 1));
                  eTimeText = DateFormat('yyyy/MM/dd HH:mm')
                      .format(scheduleData['end_date'])
                      .toString();
                }
              });
            }else{
              if (scheduleData['start_date'].compareTo(date) > 0) {
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
                  scheduleData['end_date'] = date;
                  eTimeText = DateFormat('yyyy/MM/dd HH:mm')
                      .format(scheduleData['end_date'])
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

  //入力された予定をデータベースに登録,更新する
  void saveData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var selectedCalendarId = jsonDecode(localStorage.getString('calendar'))["id"];
    scheduleData["calendar_id"] = selectedCalendarId.toString();

    //開始・終了時刻をデータベースと合わせるためにフォーマットする
    scheduleData["start_date"] = DateFormat('yy-MM-dd HH:mm').format(scheduleData["start_date"]);
    scheduleData["end_date"] = DateFormat('yy-MM-dd HH:mm').format(scheduleData["end_date"]);
    //予定情報をMapにセットする
    set();

    print(scheduleData);

    //引数がnullなら新しい予定を登録し
    //nullでないなら更新処理を行う
    if(scheduleData["id"] == null){
      print("debug");
      var result = await Network().postData(scheduleData, "schedules/store");
    } else {
      var result = await Network().postData(
          scheduleData, "schedules/update/" + scheduleData["id"].toString());
    }
  }
  void set(){
    String notification = "";
    List notificationList = context.read<NoticeChecker>().listChecked;
    for(int i = 0; i < notificationList.length; i++){
      if(notificationList[i]){
        notification = notification + "1";
      }else{
        notification = notification + "0";
      }
    }
    //プロバイダーで保持している予定情報を代入する
    scheduleData["repetition_flag"] = context.read<RepeatChecker>().flg;
    scheduleData["repetition"] = context.read<RepeatChecker>().checked;
    scheduleData["notification_flag"] = context.read<NoticeChecker>().flg;
    scheduleData["notification"] = notification;
    scheduleData["color"] = context.read<ColorChecker>().listColor[context.read<ColorChecker>().checked].toString();

    //TextFieldの値を代入する
    scheduleData["title"] = _titleController.text;
    scheduleData["memo"] = _memoController.text;
    scheduleData["place"] = _placeController.text;
    scheduleData["url"] = _urlController.text;
  }
}

//class CustomPickerModel extends CommonPickerModel {
//  DateTime maxTime = null;
//  DateTime minTime = null;
//  int _currentLeftIndex;
//  int _currentMiddleIndex;
//  int _currentRightIndex;
//  String digits(int value, int length) {
//    return '$value'.padLeft(length, "0");
//  }
//
//  String dateDigits(){
//    return '';
//  }
//
//  CustomPickerModel({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
//    if (currentTime != null) {
//      this.currentTime = currentTime;
//      if (maxTime != null &&
//          (currentTime.isBefore(maxTime) || currentTime.isAtSameMomentAs(maxTime))) {
//        this.maxTime = maxTime;
//      }
//      if (minTime != null &&
//          (currentTime.isAfter(minTime) || currentTime.isAtSameMomentAs(minTime))) {
//        this.minTime = minTime;
//      }
//    } else {
//      this.maxTime = maxTime;
//      this.minTime = minTime;
//      var now = DateTime.now();
//      if (this.minTime != null && this.minTime.isAfter(now)) {
//        this.currentTime = this.minTime;
//      } else if (this.maxTime != null && this.maxTime.isBefore(now)) {
//        this.currentTime = this.maxTime;
//      } else {
//        this.currentTime = now;
//      }
//    }
//
//    if (this.minTime != null && this.maxTime != null && this.maxTime.isBefore(this.minTime)) {
//      // invalid
//      this.minTime = null;
//      this.maxTime = null;
//    }
//
////    this.setLeftIndex(0);
////    this.setMiddleIndex(this.currentTime.hour);
////    this.setRightIndex(this.currentTime.minute);
//    _currentLeftIndex = 0;
//    _currentMiddleIndex = this.currentTime.hour;
//    _currentRightIndex = this.currentTime.minute;
//    if (this.minTime != null && isAtSameDay(this.minTime, this.currentTime)) {
//      _currentMiddleIndex = this.currentTime.hour - this.minTime.hour;
//      if (_currentMiddleIndex == 0) {
//        _currentRightIndex = this.currentTime.minute - this.minTime.minute;
//      }
//    }
//    this.currentTime = currentTime ?? DateTime.now();
//
//  }
//
//  bool isAtSameDay(DateTime day1, DateTime day2) {
//    return day1 != null &&
//        day2 != null &&
//        day1.difference(day2).inDays == 0 &&
//        day1.day == day2.day;
//  }
//
//  @override
//  String leftStringAtIndex(int index) {
//    DateTime time = currentTime.add(Duration(days: index));
//    if (minTime != null && time.isBefore(minTime) && !isAtSameDay(minTime, time)) {
//      return null;
//    } else if (maxTime != null && time.isAfter(maxTime) && !isAtSameDay(maxTime, time)) {
//      return null;
//    }
//    return formatDate(time, [ymdw], locale);
//  }
//
//  @override
//  String middleStringAtIndex(int index) {
//    DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
//    if (isAtSameDay(minTime, time)) {
//      if (index >= 0 && index < 24 - minTime.hour) {
//        return digits(minTime.hour + index, 2);
//      } else {
//        return null;
//      }
//    } else if (isAtSameDay(maxTime, time)) {
//      if (index >= 0 && index <= maxTime.hour) {
//        return digits(index, 2);
//      } else {
//        return null;
//      }
//    }
//    return digits(index % 24, 2);
//  }
//
//  @override
//  String rightStringAtIndex(int index) {
//    DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
//    if (isAtSameDay(minTime, time) && _currentMiddleIndex == 0) {
//      if (index >= 0 && index < 60 - minTime.minute) {
//        return digits(minTime.minute + index, 2);
//      } else {
//        return null;
//      }
//    } else if (isAtSameDay(maxTime, time) && _currentMiddleIndex >= maxTime.hour) {
//      if (index >= 0 && index <= maxTime.minute) {
//        return digits(index, 2);
//      } else {
//        return null;
//      }
//    }
//    return digits(index % 12 * 5, 2);
//  }
//
//  @override
//  DateTime finalTime() {
//    DateTime time = currentTime.add(Duration(days: _currentLeftIndex));
//    var hour = _currentMiddleIndex;
//    var minute = _currentRightIndex;
//    if (isAtSameDay(minTime, time)) {
//      hour += minTime.hour;
//      if (minTime.hour == hour) {
//        minute += minTime.minute;
//      }
//    }
//
//    return currentTime.isUtc
//        ? DateTime.utc(time.year, time.month, time.day, hour, minute)
//        : DateTime(time.year, time.month, time.day, hour, minute);
//  }
//
//  @override
//  List<int> layoutProportions() {
//    return [4, 1, 1];
//  }
//
//  @override
//  String rightDivider() {
//    return ':';
//  }
//}
