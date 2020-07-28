import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';

import 'schedule_add_repeat_page.dart';
import 'schedule_add_notice_page.dart';
import 'schedule_add_color_page.dart';

class ScheduleAdd extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute: '/',
        routes: <String,WidgetBuilder>{
          '/':(BuildContext context) => new ScheduleAddPage(),
          '/repeat':(BuildContext context) => new SubRepeatPage(),
          '/notice':(BuildContext context) => new SubNoticePage(),
          '/color':(BuildContext context) => new SubColorPage(),
        }
    );
//    return MultiProvider(
//        providers: [
//          ChangeNotifierProvider(create: (_) => RepeatChecker()),
//          ChangeNotifierProvider(create: (_) => NoticeChecker()),
//          ChangeNotifierProvider(create: (_) => ColorChecker()),
//        ],
//        child: MaterialApp(
//            initialRoute: '/',
//            routes: <String,WidgetBuilder>{
//              '/':(BuildContext context) => new ScheduleAddPage(),
//              '/repeat':(BuildContext context) => new SubRepeatPage(),
//              '/notice':(BuildContext context) => new SubNoticePage(),
//              '/color':(BuildContext context) => new SubColorPage(),
//            }
//        )
//    );
  }
}
class ScheduleAddPage extends  StatefulWidget{
  @override
  ScheduleAddPageState createState() => ScheduleAddPageState();
}
enum Answers{
  YES,
  NO
}
class ScheduleAddPageState extends State<ScheduleAddPage>{
  var _titleController = TextEditingController();
  var _placeController = TextEditingController();
  var _urlController = TextEditingController();
  var _memoController = TextEditingController();

  DateTime now = DateTime.now();
  bool _active = false;
  var iconSIze = 25.0;
  DateTime i;
  DateTime st;
  String stText = DateFormat('yyyy/MM/dd HH:mm')
      .format(DateTime.now())
      .toString();
  DateTime ed;
  String edText = DateFormat('yyyy/MM/dd HH:mm')
      .format(DateTime.now())
      .toString();

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
//        title: new Text('AlertDialog'),
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
  void _clear(){
    _titleController = TextEditingController(text: '');
    _placeController = TextEditingController(text: '');
    _urlController = TextEditingController(text: '');
    _memoController = TextEditingController(text: '');
    context.read<ColorChecker>().set(0);
    context.read<RepeatChecker>().set(0);
    context.read<NoticeChecker>().set(0);
  }
  @override
  Widget build(BuildContext context) {
    st = now;
    ed = now;
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
              var dataList = {
                "title":_titleController.text,
                "allDay":_active,
                "stTime":st,
                "edTime":ed,
                "repeat":context.read<RepeatChecker>().checked,
                "notice":context.read<NoticeChecker>().listChecked,
                "color":context.read<ColorChecker>().listColor[context.read<ColorChecker>().checked],
                "place":_placeController.text,
                "url":_urlController.text,
                "memo":_memoController.text,
              };
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
          activeColor: Colors.orange,
          activeTrackColor: Colors.red,
          inactiveThumbColor: Colors.blue,
          inactiveTrackColor: Colors.grey,
          secondary: new Icon(
            Icons.refresh,
            size: iconSIze,
          ),
          title: Text('終日'),
          //subtitle: Text('サブタイトル'),
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
            if (_active) {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(now.year - 3, now.month, now.day),
                  maxTime: DateTime(now.year + 3, now.month, now.day),
                  theme: DatePickerTheme(
                      headerColor: Colors.white,
                      backgroundColor: Colors.white,
                      itemStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      doneStyle: TextStyle(
                          color: Colors.black, fontSize: 16)),
                  onChanged: (date) {},
                  onConfirm: (date) {
                    setState(() {
                      st = date;
                      stText = DateFormat('yyyy/MM/dd').format(st).toString();
                      if (st.year >= ed.year && st.month >= ed.month &&
                          st.day >= ed.day) {
                        ed = st;
                        edText = DateFormat('yyyy/MM/dd')
                            .format(st)
                            .toString();
                      }
                    });
                  },
                  currentTime: st,
                  locale: LocaleType.jp);
            } else {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(now.year - 3, now.month, now.day),
                  maxTime: DateTime(now.year + 3, now.month, now.day),
                  theme: DatePickerTheme(
                      headerColor: Colors.white,
                      backgroundColor: Colors.white,
                      itemStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      doneStyle: TextStyle(
                          color: Colors.black, fontSize: 16)),
                  onChanged: (date) {},
                  onConfirm: (date) {
                    setState(() {
                      st = date;
                      stText = DateFormat('yyyy/MM/dd HH:mm')
                          .format(st)
                          .toString();
                      if (st.year >= ed.year && st.month >= ed.month &&
                          st.day >= ed.day && st.hour >= ed.hour &&
                          st.minute >= ed.minute) {
                        ed = st;
                        edText = DateFormat('yyyy/MM/dd HH:mm')
                            .format(st)
                            .toString();
                      }
                    });
                  },
                  currentTime: st,
                  locale: LocaleType.jp);
            }
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
              if (_active) {
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(now.year - 3, now.month, now.day),
                    maxTime: DateTime(now.year + 3, now.month, now.day),
                    theme: DatePickerTheme(
                        headerColor: Colors.white,
                        backgroundColor: Colors.white,
                        itemStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        doneStyle: TextStyle(
                            color: Colors.black, fontSize: 16)),
                    onChanged: (date) {},
                    onConfirm: (date) {
                      if (st.year >= date.year && date.month >= date.month &&
                          st.day >= date.day && st.hour >= date.hour &&
                          st.minute >= date.minute) {
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
                    },
                    currentTime: ed,
                    locale: LocaleType.jp);
              } else {
                DatePicker.showDateTimePicker(context,
                    showTitleActions: true,
                    minTime: DateTime(now.year - 3, now.month, now.day),
                    maxTime: DateTime(now.year + 3, now.month, now.day),
                    theme: DatePickerTheme(
                        headerColor: Colors.white,
                        backgroundColor: Colors.white,
                        itemStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        doneStyle: TextStyle(
                            color: Colors.black, fontSize: 16)),
                    onChanged: (date) {},
                    onConfirm: (date) {
                      if (st.year >= date.year && date.month >= date.month &&
                          st.day >= date.day && st.hour >= date.hour &&
                          st.minute >= date.minute) {
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
                      //});
                    },
                    currentTime: ed,
                    locale: LocaleType.jp);
              }
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
}
