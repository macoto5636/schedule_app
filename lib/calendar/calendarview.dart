import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_view_default_style.dart';

import 'package:scheduleapp/schedule_detail.dart';

import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scheduleapp/extension_diary/diary_detail_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class DayOfWeek{
  int id;
  String name;
  DayOfWeek(this.id, this.name);
}

class Schedules{
  int id;
  String title;
  bool allDay;
  DateTime startDate;
  DateTime endDate;
  Color color;
  //スケジュールか拡張機能か識別するためのID
  //(0:Schedule, 1:diary)
  int typeId;

  Schedules(this.id, this.title, this.allDay, this.startDate, this.endDate, this.color, this.typeId);
}

class CalendarView extends StatefulWidget{
  //String currentDate = DateTime.now().year.toString() + "年" + DateTime.now().month.toString() + "月";
  Function(String) setCurrentDate;
  CalendarView(this.setCurrentDate);

  @override
  _CalendarState createState() => new _CalendarState();
}

class _CalendarState extends State<CalendarView>{
  Future<bool> _futures;
  static const String _startDayKey = 'start_day';

  DateTime _currentDate; //今日の日付
  int _currentMonth; //今月

  DateTime _selectDate; //選択された日付

  List<List<DateTime>> _dates = []; //_currentDaysのあつまり

  //最初の曜日(初期値は月曜日)
  int weekStart = 1;

  String headerText;  //タイトル文字

  PageController pageController = PageController(initialPage: 1);
  int currentMonthPage = 1; //今月のページ

  List<Schedules> _schedules = [];

  //  日記テーブルの内容の変更を検知するフラグ
  var _rebuildFlag;

  //曜日定義
  final dayOfWeek = [
    DayOfWeek(1, "月"),
    DayOfWeek(2, "火"),
    DayOfWeek(3, "水"),
    DayOfWeek(4, "木"),
    DayOfWeek(5, "金"),
    DayOfWeek(6, "土"),
    DayOfWeek(7, "日"),
  ];

  //最初
  @override
  initState(){
    super.initState();
    getSchedules();
    _futures = initExecution();

//    _currentDate = DateTime.now();
//    _selectDate = _currentDate;
//    _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
//    _currentMonth = _currentDate.month;
//
//    headerText = _currentDate.year.toString() + "年" + _currentDate.month.toString() + "月";
//
//    DateTime previousMonth = DateTime(_currentDate.year, _currentDate.month, 0);
//    DateTime nextMonth = DateTime(_currentDate.year, _currentDate.month+2, 0);
//
//    _dates.add(_getTime(previousMonth.year,previousMonth.month));
//    _dates.add(_getTime(_currentDate.year, _currentDate.month));
//    _dates.add(_getTime(nextMonth.year, nextMonth.month));
  }


  callback(bool status){
    setState(() {
      _rebuildFlag = status;
    });
  }

  //予定を取得する
  void getSchedules() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var selectedCalendarId = jsonDecode(localStorage.getString('calendar'))["id"];

    var url = "http://10.0.2.2:8000/api/calendar/" + selectedCalendarId.toString();
    print(url);
    await http.get(url).then((response){
      print("Response status: ${response.statusCode}");
//      print("Response body: ${response.body}");
      List list = json.decode(response.body);

      if(mounted) {
        setState(() {
          //id取得
          List<int> schedulesId = list.map<int>((value) {
            return value['id'];
          }).toList();

          //タイトル取得
          List<String> schedulesTitle = list.map<String>((value) {
            return value['title'];
          }).toList();

          //all dayか否か
          List<bool> schedulesAllDay = list.map<bool>((value) {
            if (value['all_day'] == 0) {
              return false;
            } else {
              return true;
            }
          }).toList();

          //開始日時取得
          List<DateTime> schedulesStartDate = list.map<DateTime>((value) {
            return DateTime.parse(value['start_date']);
          }).toList();

          //終了日時取得
          List<DateTime> schedulesEndDate = list.map<DateTime>((value) {
            return DateTime.parse(value['end_date']);
          }).toList();

          //色の取得
          List<Color> schedulesColor = list.map<Color>((value) {
            return Color(int.parse(value['color']));
          }).toList();

          for (int i = 0; i < schedulesId.length; i++) {
            _schedules.add(Schedules(
                schedulesId[i],
                schedulesTitle[i],
                schedulesAllDay[i],
                schedulesStartDate[i],
                schedulesEndDate[i],
                schedulesColor[i],
                0));
          }

          getPlugin();
        });
      }
    });
    print("schedule end");
  }

  //拡張機能持っているか否か
  void getPlugin() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    http.Response response = await Network().getData("extension/addlist/$calendarId");
    List list = json.decode(response.body);

    print("Response status: ${response.statusCode}");

    List<int> extensionId = list.map<int>((value){
      return value['id'];
    }).toList();

    for(int i=0; i<extensionId.length; i++){
      //diaryがある時
      if(extensionId[i] == 1){
        getDiary();
      }
    }
  }

  //日記取得
  void getDiary() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    http.Response response = await Network().getData("diary/get/$calendarId");
    List list = json.decode(response.body);

    List<int> diaryId = list.map<int>((value){
      return value['id'];
    }).toList();

    List<String> diaryArticle = list.map<String>((value){
      return value['article'];
    }).toList();

    List<DateTime> diaryDate = list.map<DateTime>((value){
      return DateTime.parse(value['date']);
    }).toList();

    if(mounted) {
      setState(() {
        for (int i = 0; i < diaryId.length; i++) {
          _schedules.add(Schedules(
              diaryId[i],
              diaryArticle[i],
              true,
              diaryDate[i],
              diaryDate[i],
              diaryColor,
              1));
        }
      });
    }
  }

  //曜日に合わせてテキストの色を変更する
  //土曜日なら青、日曜日なら赤、月が違うなら灰
  Widget _changeText(int id, String name, int flg){
    Widget text;
    if(id == 6){
      text = Text(name , style: defaultSaturdayTextStyle);
    }else if(id == 7){
      text = Text(name , style: defaultSundayTextStyle);
    }else{
      text = Text(name, style: defaultDaysTextStyle);
    }

    if(flg == 1){
      text = Text(name, style: defaultElseMonthDaysTextStyle,);
    }

    return text;
  }

  //日付取得
  List<DateTime> _getTime(int year, int month){
    print("_getTime : $weekStart");

    List<DateTime> days = [];

    DateTime firstDay = DateTime(year, month, 1);
    DateTime lastDay = DateTime(year, month+1, 0);

    //前月の日付の取得
    int _previousDays = DateTime(year, month, 0).day;

    //print((month-1).toString() + "月："+ _previousDays.toString());

    //仮１
    int test = 0;
    switch(weekStart){
      case 1: test = 0; break;
      case 2: test = -2; break;
      case 3: test = -4; break;
      case 4: test = 1; break;
      case 5: test = -1; break;
      case 6: test = 4; break;
      case 7: test = 2; break;
    }

    //print("test = " + test.toString());
    print(weekStart);

    int firstWeekday = firstDay.weekday + (weekStart - 1) + test;
    int lastWeekday = lastDay.weekday + (weekStart - 1) + test;

    //くそ
    if(firstWeekday > 7){
      firstWeekday = firstWeekday -7;
    }
    if(firstWeekday > 7){
      firstWeekday = firstWeekday -7;
    }
    if(firstWeekday < 1){
      firstWeekday = firstWeekday + 7;
    }
    if(lastWeekday > 7) {
      lastWeekday = lastWeekday - 7;
    }
    if(lastWeekday > 7) {
      lastWeekday = lastWeekday - 7;
    }
    if(lastWeekday < 1){
      lastWeekday = lastWeekday + 7;
    }

    //print("firstWeekday : " + firstWeekday.toString());
    //print("lastWeekday : " + lastWeekday.toString() );


    //1か月 + 前月、先月分のリスト
    for(int i=1; i <= lastDay.day; i++){
      //最初の日
      if(i == 1){
        for(int j=1; j < firstWeekday; j++){
          if(month == 1){
            days.add(DateTime(year-1, 12, _previousDays - firstWeekday + j + 1));
          }else{
            days.add(DateTime(year, month-1, _previousDays - firstWeekday + j + 1));
          }
          //print(days[days.length-1]);
        }
      }
      days.add(DateTime(year, month, i));
      //print(days[days.length-1]);

      //最後の日
      if(i == lastDay.day){
        for(int j=1; j <= 7 - lastWeekday; j++){
          if(month == 12){
            days.add(DateTime(year+1, 1, j));
          }else{
            days.add(DateTime(year, month+1 , j));
          }
          //print(days[days.length-1]);
        }
      }
      //print((days.length-1 % 7).toString());
    }
    return days;
  }

  //日付選択したとき
  void onTapSelectDate(DateTime date){
    if(_selectDate == date){
      showSelectDateDialog();
    }

    setState(() {
      _selectDate = date;
    });

    //print(_selectDate.toString());
  }

  //日付の詳細表示
  Future showSelectDateDialog() async{
    final Size size = MediaQuery.of(context).size;

    await showDialog(
    context: context,
    builder: (BuildContext context) => new AlertDialog(
      title: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child:Container(
                      margin: EdgeInsets.only(bottom: 5.0),
                      child: Text(_selectDate.year.toString() + "年" + _selectDate.month.toString() + "月" + _selectDate.day.toString() + "日" + "(" + dayOfWeek[_selectDate.weekday -1].name + ")",
                        style: defaultDialogTitleTextStyle,),
                    )
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: (){
                        print("on tapped add icon!!!");
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 67.0),
                        child: Icon(Icons.add, size: 40, color: Colors.grey,),
                      ),
                    )
                  )
                ]
              ),
            ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Divider(
              color: defaultDividerColor,
            ),
            Container(
              //height: size.height ,
              child:
                SingleChildScrollView(
                child:Column(
                  children: _buildEvent()
                )
                ),
            )
          ],
        ),
      ),
    ),
  );
}

  //予定
  List<Widget> _buildEvent(){
    List<Widget> widgets = [];
    for(int i=0; i<_schedules.length; i++){
      if(_selectDate == getDateShaping(_schedules[i].startDate)){
        Widget widget =
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap:(){
              if(_schedules[i].typeId == 0) {
                moveScheduleDetailPage(context, _schedules[i].id);
              }else if(_schedules[i].typeId == 1){
                String date = _schedules[i].startDate.year.toString() + "-" + _schedules[i].startDate.month.toString().padLeft(2, '0') + "-" + _schedules[i].startDate.day.toString().padLeft(2, '0');
                final diaryData = {
                  "id" : _schedules[i].id,
                  "article" : _schedules[i].title,
                  "date" : date,
                };
                moveDiaryDetailPage(context, diaryData);
              }
              },
          child:Padding(
            padding: EdgeInsets.all(1.0),
          child:Container(
            width: 500,
            child:Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      children: [
                        if(_schedules[i].allDay)
                          Text("\n 終日 \n", style: defaultDialogTextStyle,),
                        if(!_schedules[i].allDay)
                          Text(_schedules[i].startDate.hour.toString().padLeft(2, '0') + ":" + _schedules[i].startDate.minute.toString().padLeft(2, '0') + "\n ｜"
                              + "\n" + _schedules[i].endDate.hour.toString().padLeft(2, '0') + ":" + _schedules[i].endDate.minute.toString().padLeft(2, '0'), style: defaultDialogTextStyle,),
                      ],
                    )
                ),
                Container(
                  height: 50,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        width: 5,
                        color: _schedules[i].color,
                      ),
                    ),
                  ),
                ),
                if(_schedules[i].typeId == 0)
                  Expanded(
                    child: Container(
                      child: Text(_schedules[i].title, style:defaultDialogTextStyle, overflow: TextOverflow.ellipsis,maxLines: 1,textAlign: TextAlign.left,),
                    ),
                  ),
                if(_schedules[i].typeId == 1)
                  Expanded(
                    child: Container(
                        child: Row(
                          children: [
                            //なぜかRichTextだと思う通りにいかず、ネスト地獄になった
                            Padding(
                              padding: EdgeInsets.only(right : 5.0),
                              child: Icon(Icons.import_contacts, size: 20.0,),
                            ),
                            Expanded(
                              child:Container(
                                  child:Text(_schedules[i].title, style: defaultDialogTextStyle, overflow: TextOverflow.ellipsis,maxLines: 1,)
                              ),
                            ),
                          ],
                        )
                    ),
                  )
              ],
            )
          ),
          ),
    );

        widgets.add(widget);
      }
    }

    //ダイアログの高さ調整
    if(widgets.length < 8){
      for(int i=0; i< 8 - widgets.length; i++){
        widgets.add(
          Container(
            height: 120,
            width: 300,
          )
        );
      }
    }

    return widgets;
  }

  //予定詳細ページへ移動
  moveScheduleDetailPage(BuildContext context, int id){
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ScheduleDetailPage(id);
        },
      ),
    );
  }

  //日記詳細
  moveDiaryDetailPage(BuildContext context, data){
    Navigator.of(context).pop();
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiaryDetailPage(diaryData: data,callback: callback),
        )
    );
  }

  //今月の位置に戻るボタン押したとき
  void onTapCurrentMonth(){
    pageController.animateToPage(currentMonthPage,duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  //月切り替わったときの処理
  void onPageChanged(pageId){
    print("pageId:" + pageId.toString());

    if(pageId == _dates.length -1){
      DateTime tempDate = getDateTime(_dates.length-1, 10);
      setState((){
        _dates.add(_getTime(tempDate.year, tempDate.month+1));
      });
    }

    setState(() {
      DateTime tempDate = getDateTime(pageId, 10);
      headerText = tempDate.year.toString() + "年" + tempDate.month.toString() + "月";
      widget.setCurrentDate(headerText);
    });

    if(pageId == 0){
      DateTime tempDate = getDateTime(0, 10);
      setState(() {
        _dates.insert(0, _getTime(tempDate.year, tempDate.month-1));
      });
      currentMonthPage++;
      pageController.jumpToPage(1);
    }
  }

  //body部分(カレンダー)
  //曜日
  //カレンダーの曜日部分作成
  List<Widget> _calendarHeaderWidgets() {
    var weekWidget = List<Widget>();

    //曜日リスト並び替え
    var weekList = List();
    weekList.add(dayOfWeek[weekStart - 1]);

    //上で入れた曜日以外を追加
    //くそみそアルゴリズム
    for(int i=weekStart; i<7; i++){
      weekList.add(dayOfWeek[i]);
    }
    for(int i=0; i<weekStart-1; i++){
      weekList.add(dayOfWeek[i]);
    }

    weekList.forEach((element) {
      //曜日によって文字色を変える
      Widget text = _changeText(element.id, element.name, 0);
      //要素追加
      weekWidget.add(
          Column(children: <Widget>[
            text,
          ],
          ));
    });
    return weekWidget;
  }

  //１日
  Widget _buildTableCell(DateTime date, row) {
    final Size size = MediaQuery
        .of(context)
        .size;

    if (date == _selectDate) {
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onTapSelectDate(date);
          },
          child: Container(
            height: (size.height - 170) / row,
            child: _buildCell(date),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: defaultBorderColor),
              color: date == _currentDate ? defaultTodayBackgroundColor : defaultBackgroundColor,
            ),
          )
      );
    }else{
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap:(){onTapSelectDate(date);},
        child: Container(
          height: (size.height - 170) / row,
          child: _buildCell(date),
          color: date==_currentDate ? defaultTodayBackgroundColor : defaultBackgroundColor,
        ),
      );
    }
  }

  //日にち
  Widget _buildCell(DateTime date){
    int flg = 0;
    if(date.month != _currentMonth){
      flg = 1;
    }

    Widget text = _changeText(date.weekday, date.day.toString(), flg);

    return SingleChildScrollView(
        child:Column(
          children: <Widget>[
            date==_currentDate ?
              Container(
                height: 16,
                width: 16,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: defaultBorderColor,
                ),
                child: Text(date.day.toString() , style: defaultTodayTextStyle, textAlign: TextAlign.center,),
              ):
            text,
            Column(children: _buildSchedule(date),)
          ],
        )
      );
    }

  //その日の予定
  List<Widget> _buildSchedule(DateTime date){
    List<Widget> widgets = [];
    for(int i=0; i<_schedules.length; i++){
      if(date == getDateShaping(_schedules[i].startDate)){
        Widget widget =
          Padding(
              padding: EdgeInsets.all(1.0),
            child:
            Container(
              width: 300,
              color: _schedules[i].color,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: defaultScheduleTextStyle,
                  children: [
                    if(_schedules[i].typeId == 0)
                      TextSpan(
                        text: _schedules[i].title,
                      ),
                    if(_schedules[i].typeId == 1)
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(right: 5.0),
                              child: Icon(Icons.import_contacts, size: 11.0, color: Colors.white,),
                            )
                          ),
                          TextSpan(
                            text: "日記",
                          )
                        ]
                      )
                  ]
                ),
              ),
            )
          );
        widgets.add(widget);
      }
    }
    return widgets;
  }

  //週
  TableRow _buildTableRow(List<DateTime> days, int row){
    return TableRow(
      children: days.map((date) => _buildTableCell(date,row)).toList(),
    );
  }

  //月
  Widget _buildTable(List<DateTime> days){
    try {
      final daysInWeek = 7;
      final children = <TableRow>[];
      int row = (days.length / 7).toInt();

      //その月取得
      _currentMonth = days[10].month;

      int x = 0;
      while (x < days.length) {
        children.add(
            _buildTableRow(days.skip(x).take(daysInWeek).toList(), row));
        x += daysInWeek;
      }

      return Column(
        children: <Widget>[
          Container(
            child: Table(
              border: TableBorder(bottom: BorderSide(color: Colors.grey, width: 1.0)),
              children: [
                TableRow(
                  children: _calendarHeaderWidgets(),
                )
              ],
            ),
          ),
          Expanded(
            child: Table(
              border: TableBorder(horizontalInside: BorderSide(color: Colors.grey, width: 1.0)),
              children: children,
            ),
          )
        ],
      );
    }catch(e){
      print(e);
      return Container();
    }
  }

  //List<List<DateTime>>からDateTimeを取り出す
  DateTime getDateTime(int getList, int getDate){
    List<DateTime> tempList = _dates[getList];
    DateTime tempDate = tempList[getDate];
    return tempDate;
  }

  //DateTimeのhour以降を0にする
  DateTime getDateShaping(DateTime datetime){
    int year = datetime.year;
    int month = datetime.month;
    int day = datetime.day;

    return DateTime(year,month,day);
  }

  Future<bool> initExecution() async{
    //設定値（週の開始曜日）を取得
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      weekStart = pref.getInt(_startDayKey);
    });
    print("weekStart : $weekStart");
    _currentDate = DateTime.now();
    _selectDate = _currentDate;
    _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    _currentMonth = _currentDate.month;

    headerText = _currentDate.year.toString() + "年" + _currentDate.month.toString() + "月";

    DateTime previousMonth = DateTime(_currentDate.year, _currentDate.month, 0);
    DateTime nextMonth = DateTime(_currentDate.year, _currentDate.month+2, 0);

    _dates.add(_getTime(previousMonth.year,previousMonth.month));
    _dates.add(_getTime(_currentDate.year, _currentDate.month));
    _dates.add(_getTime(nextMonth.year, nextMonth.month));

    return true;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: _futures,
              builder: (BuildContext context,AsyncSnapshot<bool> snapshot){
                if(snapshot.hasData){
                  return Container(
                    child:Expanded(
                      child:PageView(
                          onPageChanged: onPageChanged,
                          controller: pageController,
                          children: List<Widget>.generate(_dates.length,(index){
                            return _buildTable(_dates[index]);
                          })
                      ),
                    ),
                  );
                }else{
                  return Center(
                      child: CircularProgressIndicator()
                  );
                }
              },
            )

          ],
        )
    );
  }
}

