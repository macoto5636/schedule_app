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

class ScheduleAddPageState extends State<ScheduleAddPage>{
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("新しい予定"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: (){},
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
//          onTap: () => Navigator.of(context).pushNamed("/repeat"),
        ), ListTile(
          leading: Icon(
            Icons.timer,
            size: iconSIze,
          ),
          title: Text("通知"),
//            trailing: ColorText(),
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

class RepeatText extends StatelessWidget {
  const RepeatText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<RepeatChecker>().listText[context.watch<RepeatChecker>().checked]);
  }
}

class NoticeText extends StatelessWidget {
  const NoticeText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> listText = context.watch<NoticeChecker>().listText;
    List<bool> listCheck = context.watch<NoticeChecker>().listChecked;
    String text = "";
    for(int i = 0; i < listText.length; i++){
      if(listCheck[i]){
        text += listText[i];
      }
    }
    return Container(
      width: 200,
//      padding: new EdgeInsets.all(5.0),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.black),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        child: Text(
          text,
          textAlign: TextAlign.right,
        ),
      ),
//        child: Text(
//          text,
//          maxLines: 1,
//          textAlign: TextAlign.right,
//        )
    );
  }
}

class ColorText extends StatelessWidget {
  const ColorText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<ColorChecker>().listText[context.watch<ColorChecker>().checked]);
  }
}
