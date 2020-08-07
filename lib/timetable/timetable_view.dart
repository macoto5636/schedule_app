
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:scheduleapp/timetable/timetable_view_default_style.dart';

import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:scheduleapp/extension_diary/diary_detail_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:scheduleapp/schedule_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';


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

class TimeTableView extends StatefulWidget {
  bool flag;
  Function(String) setCurrentDate;
  TimeTableView(this.flag, this.setCurrentDate);

  @override
  _TimeTableViewState createState() => _TimeTableViewState();
}

class _TimeTableViewState extends State<TimeTableView>{

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

  //現在の日付
  DateTime _currentDate = DateTime.now();
  //_currentDateの集まり
  List<DateTime> _dates = [];


  String _headerText = "";

  //その日の予定
  List<int> _schedulesId = [];
  List<String> _schedulesTitle = [];
  List<bool> _schedulesAllDay = [];
  List<DateTime> _schedulesStartDate = [];
  List<DateTime> _schedulesEndDate = [];
  List<Color> _schedulesColor = [];

  List<Schedules> _schedules = [];

  ScrollController _scrollController;
  PageController _pageController = PageController(initialPage: 1);
  int _currentMonthPage = 1; //今月のページ

  //  日記テーブルの内容の変更を検知するフラグ
  var _rebuildFlag = true;

  @override
  void initState() {
    super.initState();
    //_getSchedules(_currentDate);

    _dates.add(DateTime(_currentDate.year, _currentDate.month, _currentDate.day - 1));
    _dates.add(_currentDate);
    _dates.add(DateTime(_currentDate.year, _currentDate.month, _currentDate.day + 1));

    if(mounted) {
      _getSchedules();
    }
    _headerText = _currentDate.day.toString() + "日" + "(" + dayOfWeek[_currentDate.weekday -1].name + ")";

    _scrollController = ScrollController();


  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  callback(bool status){
    setState(() {
      _rebuildFlag = status;
    });
  }

  //現在の日付の予定取得
  void _getSchedules() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var selectedCalendarId = jsonDecode(localStorage.getString('calendar'))["id"];

    var url = "http://10.0.2.2:8000/api/calendar/" + selectedCalendarId.toString();
    print(url);
    await http.get(url).then((response) {
      print("Response status: ${response.statusCode}");
      List list = json.decode(response.body);
      if(mounted) {
        setState(() {
          //id取得
          _schedulesId = list.map<int>((value) {
            return value['id'];
          }).toList();

          //タイトル取得
          _schedulesTitle = list.map<String>((value) {
            return value['title'];
          }).toList();

          //all dayか否か
          _schedulesAllDay = list.map<bool>((value) {
            if (value['all_day'] == 0) {
              return false;
            } else {
              return true;
            }
          }).toList();

          //開始日時取得
          _schedulesStartDate = list.map<DateTime>((value) {
            return DateTime.parse(value['start_date']);
          }).toList();

          //終了日時取得
          _schedulesEndDate = list.map<DateTime>((value) {
            return DateTime.parse(value['end_date']);
          }).toList();

          //色の取得
          _schedulesColor = list.map<Color>((value) {
            return Color(int.parse(value['color']));
          }).toList();

          for (int i = 0; i < _schedulesId.length; i++) {
            _schedules.add(Schedules(
                _schedulesId[i],
                _schedulesTitle[i],
                _schedulesAllDay[i],
                _schedulesStartDate[i],
                _schedulesEndDate[i],
                _schedulesColor[i],
                0));
          }
          getPlugin();
        });
      }
      });
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

    if(this.mounted) {
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

  //日が切り替わったときの処理
  void onPageChanged(pageId){
    print("pageId:" + pageId.toString());

    if(pageId == _dates.length -1){
      DateTime tempDate = _dates[_dates.length-1];
      setState((){
        _dates.add(DateTime(tempDate.year, tempDate.month, tempDate.day+1));
      });
    }

    setState(() {
      DateTime tempDate = _dates[pageId];
      _headerText = tempDate.day.toString() + "日" + "(" + dayOfWeek[tempDate.weekday-1].name + ")";
      widget.setCurrentDate(tempDate.year.toString() + "年" + tempDate.month.toString() + "月");
    });

    if(pageId == 0){
      DateTime tempDate = _dates[0];
      setState(() {
        _dates.insert(0, DateTime(tempDate.year, tempDate.month, tempDate.day-1));
      });
      _currentMonthPage++;
      _pageController.jumpToPage(1);
    }
  }

  //今月の位置に戻るボタン押したとき
  void onTapCurrentDate(){
    _pageController.animateToPage(_currentMonthPage,duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  //DateTimeの時間の差異
  int _getDateTimeDiff(DateTime startDate, DateTime endDate){
    int minute = 0;
    int startHour = startDate.hour;
    int endHour = endDate.hour;

    if(startDate.day != endDate.day){
      endHour = 24;
    }

    if(startDate.minute < endDate.minute){
      minute += (endDate.minute + 60) - startDate.minute;
      endHour++;
    }else{
      minute += endDate.minute - startDate.minute;
    }

    minute = (endHour - startHour) * 60;

    return minute;
  }

  //DateTimeのhour以降を0にする
  DateTime getDateShaping(DateTime datetime){
    int year = datetime.year;
    int month = datetime.month;
    int day = datetime.day;

    return DateTime(year,month,day);
  }

  //予定詳細ページへ移動
  moveScheduleDetailPage(BuildContext context, int id){
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
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DiaryDetailPage(diaryData: data,callback: callback),
        )
    );
  }

  Widget _buildTitle(){
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              child: Row(
                children: [
                  _leftButton(),
                  Expanded(
                    child:GestureDetector(
                      onTap: onTapCurrentDate,
                      child: Text( _headerText,
                        style: defaultHeaderTextStyle,textAlign: TextAlign.center,),
                    ),
                  ),
                  _rightButton(),
                ],
              )
            ),
          )
        ],
      ),
    );
  }

  //前へ
  Widget _leftButton() => IconButton(
    onPressed: (){
      _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
    },
    icon: const Icon(Icons.chevron_left),
  );

  //次へ
  Widget _rightButton() => IconButton(
    onPressed: (){
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);
    },
    icon: const Icon(Icons.chevron_right),
  );

  //ここからしたのやつ合体してる
  Widget _buildSingleChildScrollView(DateTime date){
    List<Schedules> scheduleListNotAllDay = [];
    List<Schedules> scheduleListAllDay = [];
    for(int i=0; i < _schedules.length; i++){
      if(getDateShaping(_schedules[i].startDate) == getDateShaping(date)){
        if(_schedules[i].allDay){
          scheduleListAllDay.add(_schedules[i]);
        }else{
          scheduleListNotAllDay.add(_schedules[i]);
        }
      }
    }

    return Container(
      child:Column(
          children:[
            _buildAllDay(scheduleListAllDay),
            Expanded(child:SingleChildScrollView(
              controller: _scrollController,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildHourContainer(60.0),
                  Expanded(
                    child: Stack(
                    children: [
                      _buildBackMainContent(60.0),
                      for(int i = 0; i < scheduleListNotAllDay.length; i++)
                        _buildSchedule(i, 350, scheduleListNotAllDay),
                      if(DateTime(_currentDate.year, _currentDate.month,
                          _currentDate.day) == DateTime(
                          date.year, date.month, date.day))
                        _buildCurrentLine(),
                    ],
                  ),
                )
              ],
            ),
          )
              )]),
        );
  }

  //終日
  Widget _buildAllDay(List<Schedules> scheduleList){
    return Container(
        height: 60,
        decoration: BoxDecoration(
            border: Border(
                top: defaultBorderSide,
                bottom: defaultBorderSide,
            )
        ),
        child: Row(
          children: [
            Container(
              width: 60.0,
              child: Text("終日", style: defaultPlaneTextStyle, textAlign: TextAlign.center,),
            ),
            Expanded(
              child:SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child:Row(
                  children: [
                    for(int i=0;i<scheduleList.length; i++)
                      i
                  ].map((num){
                  return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: (){
                          if(scheduleList[num].typeId == 0) {
                            moveScheduleDetailPage(
                                context, scheduleList[num].id);
                          }else if(scheduleList[num].typeId == 1){
                            String date = scheduleList[num].startDate.year.toString() + "-" + scheduleList[num].startDate.month.toString().padLeft(2, '0') + "-" + scheduleList[num].startDate.day.toString().padLeft(2, '0');
                            final diaryData = {
                              "id" : scheduleList[num].id,
                              "article" : scheduleList[num].title,
                              "date" : date,
                            };
                            moveDiaryDetailPage(context, diaryData);
                          }
                        },
                      child:Container(
                        margin: EdgeInsets.all(2.0),
                        height: 30,
                        decoration: defaultScheduleBox(scheduleList[num].color),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: RichText(
                            text: TextSpan(
                              style: defaultScheduleTextStyle,
                              children:[
                                if(scheduleList[num].typeId == 0)
                                  TextSpan(
                                    text: scheduleList[num].title,
                                  )
                                else if(scheduleList[num].typeId == 1)
                                  TextSpan(
                                    children:[
                                      WidgetSpan(
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 5.0),
                                          child: Icon(Icons.import_contacts, size: 15.0, color: Colors.white,),
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
                      )
                    );
                }).toList(),
              )
              )
            )
          ],
        )
    );
  }

  //時間のところ
  Widget _buildHourContainer(double height){
    return Column(
      children: [
        for(int i=0; i<24; i++)
          i
      ].map((hour){
        return Container(
          height: height,
          width: 60.0,
          decoration: BoxDecoration(
            border: Border(
              top: defaultBorderSide,
            )
          ),
          child: Text(
            hour.toString().padLeft(2,'0') + ":00", style: defaultPlaneTextStyle, textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  //後ろの線
  Widget _buildBackMainContent(double height){
    return Column(
      children: [
        for(int i=0; i<24; i++)
          i
      ].map((i){
        return Container(
          height: height,
          decoration: BoxDecoration(
            border: Border(
              top: defaultBorderSide,
            )
          ),
        );
      }).toList(),
    );
  }

  //スケジュールのContainer
  Widget _buildSchedule(int num, double width, List<Schedules> scheduleList){
    int scheduleHeight;
    double scheduleWidth;

    int cnt = 1;
    int cnt2 = 0;
    for(int i=0; i < scheduleList.length; i++){
      int flg = 0;
      //時間帯被っているかチェック
      if(scheduleList[num].id != scheduleList[i].id){
        int startHourA = scheduleList[num].startDate.hour;
        int endHourA = scheduleList[num].endDate.hour;
        if(startHourA > endHourA){
          endHourA = 12;
        }

        int startHourB = scheduleList[i].startDate.hour;
        int endHourB = scheduleList[i].endDate.hour;
        if(startHourB > endHourB){
          endHourB = 12;
        }
        for(int hourB=startHourB; hourB<=endHourB; hourB++){
          for(int hourA=startHourA; hourA<=endHourA; hourA++){
            if(hourA == hourB && flg==0){
              cnt++;
              flg = 1;
              if(scheduleList[num].id > scheduleList[i].id){
                cnt2++;
              }
            }
          }
        }
      }
    }

    scheduleHeight = _getDateTimeDiff(scheduleList[num].startDate, scheduleList[num].endDate);
    scheduleWidth = width;
    //print("height:" + scheduleHeight.toString());

    return Positioned(
        top: (scheduleList[num].startDate.hour * 60 + scheduleList[num].startDate.minute).toDouble(),
        left: (cnt2 * (width/cnt)).toDouble(),
        height: scheduleHeight.toDouble(),
        width: width/cnt,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){
                if(scheduleList[num].typeId == 0){
                  moveScheduleDetailPage(context, scheduleList[num].id);
                }
              },
            child:Container(
              decoration: defaultScheduleBox(scheduleList[num].color),
              child: Column(
                children: [
                  Text(scheduleList[num].title, style: defaultScheduleTextStyle, overflow: TextOverflow.ellipsis,),
                  Text(scheduleList[num].startDate.hour.toString().padLeft(2,'0') + ":" + scheduleList[num].startDate.minute.toString().padLeft(2,'0') + "〜" +
                      scheduleList[num].endDate.hour.toString().padLeft(2,'0') + ":" + scheduleList[num].endDate.minute.toString().padLeft(2, '0'),style: defaultScheduleTextStyle, overflow: TextOverflow.ellipsis),
                ],
              ),
            )
        )
    );
  }

  //現在の時間帯に線を引く
  Widget _buildCurrentLine(){
    return Positioned(
      top: (_currentDate.hour * 60 + _currentDate.minute - 5).toDouble(),
      left: 0.0,
      child: Container(
        width: 1000,
        child: Divider(
          color: defaultCurrentDateTimeDividerColor,
          thickness: 3,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    //初期位置
    Timer(Duration(microseconds: 100), () => _scrollController.jumpTo((_currentDate.hour * 60).toDouble()));

    return Container(
      child: Column(
        children: [
          _buildTitle(),
          Expanded(
            child: PageView(
              onPageChanged: onPageChanged,
              controller: _pageController,
              children: List<Widget>.generate(_dates.length,(index){
                return _buildSingleChildScrollView(_dates[index]);
              })
            ),
          ),
        ],
      ),
    );
  }
}
