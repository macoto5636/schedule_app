
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:scheduleapp/schedule_detail.dart';


class DayOfWeek{
  int id;
  String name;
  DayOfWeek(this.id, this.name);
}

class Schedules{
  int id;
  String title;
  DateTime startDate;
  DateTime endDate;
  Color color;

  Schedules(this.id, this.title, this.startDate, this.endDate, this.color);
}

class TimeTableView extends StatefulWidget {
  Function(String) setCurrentDate;
  TimeTableView(this.setCurrentDate);

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

  //今日の日付
  DateTime _todayDate = DateTime.now();

  String _headerText = "";

  //その日の予定
//  List<int> _schedulesId = [];
//  List<String> _schedulesTitle = [];
//  List<DateTime> _schedulesStartDate = [];
//  List<DateTime> _schedulesEndDate = [];
//  List<Color> _schedulesColor = [];

  ScrollController _scrollController;
  PageController _pageController = PageController(initialPage: 1);
  int _currentMonthPage = 1; //今月のページ

  @override
  void initState() {
    super.initState();
    //_getSchedules(_currentDate);

    _dates.add(DateTime(_currentDate.year, _currentDate.month, _currentDate.day - 1));
    _dates.add(_currentDate);
    _dates.add(DateTime(_currentDate.year, _currentDate.month, _currentDate.day + 1));

    _headerText = _currentDate.day.toString() + "日" + "(" + dayOfWeek[_currentDate.weekday -1].name + ")";

    _scrollController = ScrollController();

  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }


  //現在の日付の予定取得
  Future<List<Schedules>> _getSchedules(DateTime date) async{
    var url = "http://10.0.2.2:8000/api/schedules/start_date/" +
        date.year.toString() + "-" + date.month.toString().padLeft(2, '0') + "-" + date.day.toString().padLeft(2,'0');
    print(url);

    List<int> schedulesId = [];
    List<String> schedulesTitle = [];
    List<DateTime> schedulesStartDate = [];
    List<DateTime> schedulesEndDate = [];
    List<Color> schedulesColor = [];

    List<Schedules> list = await http.get(url).then((response){
      print("Response status: ${response.statusCode}");
      List<Schedules> schedules = [];
      if(response.statusCode == 200) {
        List list = json.decode(response.body);

        //setState(() {
        //id取得
        schedulesId = list.map<int>((value) {
          return value['id'];
        }).toList();


        //タイトル取得
        schedulesTitle = list.map<String>((value) {
          return value['title'];
        }).toList();

        //開始日時取得
        schedulesStartDate = list.map<DateTime>((value) {
          return DateTime.parse(value['start_date']);
        }).toList();

        //終了日時取得
        schedulesEndDate = list.map<DateTime>((value) {
          return DateTime.parse(value['end_date']);
        }).toList();

        //色の取得
        schedulesColor = list.map<Color>((value) {
          return Color(int.parse(value['color']));
        }).toList();

        for (int i = 0; i < schedulesId.length; i++) {
          schedules.add(Schedules(
              schedulesId[i], schedulesTitle[i], schedulesStartDate[i],
              schedulesEndDate[i], schedulesColor[i]));
        }
      }

        return schedules;
      //});
    }).catchError((e){
      print(e);
      List<Schedules> list = [];
      return list;
    }
    );

    return list;
  }

  //日が切り替わったときの処理
  void onPageChanged(pageId){
    print("pageId:" + pageId.toString());
    for(int i=0; i < _dates.length; i++){
      //print(i.toString() + ":" + _dates[i].toString());
    }

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

//  //日付変更時
//  void _changeCurrentDate(int n){
//    setState(() {
//      _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day - n);
//      widget.setCurrentDate(_currentDate.year.toString() + "年" + _currentDate.month.toString() + "月");
//      _getSchedules(_currentDate);
//    });
//  }

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
                        style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
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

  //終日
  Widget _buildAllDay(){
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0,
          ),
          bottom: BorderSide(
            color: Colors.grey,
            width: 0,
          )
        )
      ),
      child: Row(
        children: [
          Container(
            width: 60.0,
            child: Text("終日", textAlign: TextAlign.center,),
          ),
        ],
      )
    );
  }

  //ここからしたのやつ合体してる
  Widget _buildSingleChildScrollView(DateTime date){

    //List<Schedules> schedulesList = [];
    //schedulesList = _getSchedules(date).toList;
    return FutureBuilder(
      future: _getSchedules(date),
      builder: (BuildContext context, AsyncSnapshot<List<Schedules>> scheduleList){
        return Container(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildHourContainer(60.0),
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackMainContent(60.0),
                      if(scheduleList.hasData)
                        for(int i = 0; i < scheduleList.data.length; i++)
                          _buildSchedule(i, 350, scheduleList.data),
                      if(DateTime(_currentDate.year, _currentDate.month,
                          _currentDate.day) == DateTime(
                          date.year, date.month, date.day))
                        _buildCurrentLine(),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
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
              top: BorderSide(
                color: Colors.grey,
                width: 0,
              )
            )
          ),
          child: Text(
            hour.toString().padLeft(2,'0') + ":00", textAlign: TextAlign.center,
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
              top: BorderSide(
                color: Colors.grey,
                width: 0,
              )
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
    print("height:" + scheduleHeight.toString());

    return Positioned(
        top: (scheduleList[num].startDate.hour * 60).toDouble(),
        left: (cnt2 * (width/cnt)).toDouble(),
        height: scheduleHeight.toDouble(),
        width: width/cnt,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){moveScheduleDetailPage(context, scheduleList[num].id);},
            child:Container(
              decoration: BoxDecoration(
                border: Border.all(color: scheduleList[num].color),
                borderRadius: BorderRadius.circular(8),
                color: scheduleList[num].color,
              ),
              //color: scheduleList[num].color,
              child: Column(
                children: [
                  Text(scheduleList[num].title, style: TextStyle(color: Colors.white),),
                  Text(scheduleList[num].startDate.hour.toString().padLeft(2,'0') + ":" + scheduleList[num].startDate.minute.toString().padLeft(2,'0') + "〜" +
                      scheduleList[num].endDate.hour.toString().padLeft(2,'0') + ":" + scheduleList[num].endDate.minute.toString().padLeft(2, '0'),style: TextStyle(color: Colors.white),),
                ],
              ),
            )
        )
    );
  }

  //現在の時間帯に線を引く
  Widget _buildCurrentLine(){
    return Positioned(
      top: (_todayDate.hour * 60 + _todayDate.minute - 5).toDouble(),
      left: 0.0,
      child: Container(
        width: 1000,
        child: Divider(
          color: Colors.red,
          thickness: 3,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    //初期位置
    if(DateTime(_currentDate.year,_currentDate.month,_currentDate.day) == DateTime(_todayDate.year, _todayDate.month, _todayDate.day)){
      Timer(Duration(microseconds: 100), () => _scrollController.jumpTo((_todayDate.hour * 60).toDouble()));
    }else{
      Timer(Duration(microseconds: 100), () => _scrollController.jumpTo((_currentDate.hour * 60).toDouble()));
    }

    return Container(
      child: Column(
        children: [
          _buildTitle(),
          _buildAllDay(),
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
