import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class _TimeTableViewState extends State<TimeTableView> {

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

  //日付変更時
  void _changeCurrentDate(int n){
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day - n);
      widget.setCurrentDate(_currentDate.year.toString() + "年" + _currentDate.month.toString() + "月");
    });
  }

  Widget _buildCorner(){
    return Positioned(
      left: 0,
      top: 0,
      child: SizedBox(
        width: 300,
        height: 300,
        child: DecoratedBox(
          decoration: BoxDecoration(color: Colors.blueAccent),
        ),
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

  Widget _buildTimeline(){
    return Container(
      child: ListView(
          children: [
            for(var i = 0; i < 24; i++)
              i
          ].map((hour){
            return Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 0,
                  ),
                ),
              ),
              child: Text(
                hour.toString() + ":00",
              ),
            );
          }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _buildTitle(),
          Expanded(
            child: Stack(
              children: [
                _buildTimeline()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
