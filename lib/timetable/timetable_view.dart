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

  //今日の日付
  DateTime _todayDate = DateTime.now();

  //その日の予定
  List<int> _schedulesId = [];
  List<String> _schedulesTitle = [];
  List<DateTime> _schedulesStartDate = [];
  List<DateTime> _schedulesEndDate = [];
  List<Color> _schedulesColor = [];

  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _getSchedules();
    _scrollController = ScrollController();

  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  //現在の日付の予定取得
  void _getSchedules() async{
    var url = "http://10.0.2.2:8000/api/schedules/start_date/" +
        _currentDate.year.toString() + "-" + _currentDate.month.toString().padLeft(2, '0') + "-" + _currentDate.day.toString().padLeft(2,'0');
    print(url);

    await http.get(url).then((response){
      print("Response status: ${response.statusCode}");
      List list = json.decode(response.body);

      setState(() {
        //id取得
        _schedulesId = list.map<int>((value){
          return value['id'];
        }).toList();

        //タイトル取得
        _schedulesTitle = list.map<String>((value){
          return value['title'];
        }).toList();

        //開始日時取得
        _schedulesStartDate = list.map<DateTime>((value){
          return DateTime.parse(value['start_date']);
        }).toList();

        //終了日時取得
        _schedulesEndDate = list.map<DateTime>((value){
          return DateTime.parse(value['end_date']);
        }).toList();

        //色の取得
        _schedulesColor = list.map<Color>((value){
          return Color(int.parse(value['color']));
        }).toList();
      });
    });
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

  //日付変更時
  void _changeCurrentDate(int n){
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day - n);
      widget.setCurrentDate(_currentDate.year.toString() + "年" + _currentDate.month.toString() + "月");
      _getSchedules();
    });
  }

  //予定詳細ページへ移動
  moveScheduleDetailPage(BuildContext context, int id){
    //Navigator.of(context).pop();
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
                    child: Text(_currentDate.day.toString() + "日" + "(" + dayOfWeek[_currentDate.weekday -1].name + ")",
                      style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
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
      _changeCurrentDate(1);
    },
    icon: const Icon(Icons.chevron_left),
  );

  //次へ
  Widget _rightButton() => IconButton(
    onPressed: (){
      _changeCurrentDate(-1);
    },
    icon: const Icon(Icons.chevron_right),
  );

  //ここからしたのやつ合体してる
  Widget _buildSingleChildScrollView(){
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
                  for(int i=0;i<_schedulesId.length;i++)
                    _buildSchedule(i, 350),
                  if(DateTime(_currentDate.year,_currentDate.month,_currentDate.day) == DateTime(_todayDate.year, _todayDate.month, _todayDate.day))
                    _buildCurrentLine(),
                ],
              ),
            )
          ],
        ),
      ),
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
  Widget _buildSchedule(int num, double width){
    int scheduleHeight;
    double scheduleWidth;

    int cnt = 1;
    int cnt2 = 0;
    for(int i=0; i < _schedulesId.length; i++){
      int flg = 0;
      //時間帯被っているかチェック
      if(_schedulesId[num] != _schedulesId[i]){
        int startHourA = _schedulesStartDate[num].hour;
        int endHourA = _schedulesEndDate[num].hour;
        if(startHourA > endHourA){
          endHourA = 12;
        }

        int startHourB = _schedulesStartDate[i].hour;
        int endHourB = _schedulesEndDate[i].hour;
        if(startHourB > endHourB){
          endHourB = 12;
        }
        for(int hourB=startHourB; hourB<=endHourB; hourB++){
          for(int hourA=startHourA; hourA<=endHourA; hourA++){
            if(hourA == hourB && flg==0){
              cnt++;
              flg = 1;
              if(_schedulesId[num] > _schedulesId[i]){
                cnt2++;
              }
            }
          }
        }
      }
    }

    scheduleHeight = _getDateTimeDiff(_schedulesStartDate[num], _schedulesEndDate[num]);
    scheduleWidth = width;
    print("height:" + scheduleHeight.toString());

    return Positioned(
        top: (_schedulesStartDate[num].hour * 60).toDouble(),
        left: (cnt2 * (width/cnt)).toDouble(),
        height: scheduleHeight.toDouble(),
        width: width/cnt,
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: (){moveScheduleDetailPage(context, _schedulesId[num]);},
            child:Container(
              color: _schedulesColor[num],
              //height: scheduleHeight.toDouble(),
              //width: scheduleWidth,
              child: Column(
                children: [
                  Text(_schedulesTitle[num], style: TextStyle(color: Colors.white),),
                  Text(_schedulesStartDate[num].hour.toString().padLeft(2,'0') + ":" + _schedulesStartDate[num].minute.toString().padLeft(2,'0') + "〜" +
                    _schedulesEndDate[num].hour.toString().padLeft(2,'0') + ":" + _schedulesEndDate[num].minute.toString().padLeft(2, '0'),style: TextStyle(color: Colors.white),),
                ],
              ),
            )
        )
    );
  }

  //現在の時間帯に線を引く
  Widget _buildCurrentLine(){
    return Positioned(
      top: (_todayDate.hour * 60 + _todayDate.minute).toDouble(),
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
          Expanded(
            child: _buildSingleChildScrollView(),
          )
        ],
      ),
    );
  }
}
