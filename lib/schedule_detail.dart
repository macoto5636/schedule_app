import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class DayOfWeek{
  int id;
  String name;
  DayOfWeek(this.id, this.name);
}

class ScheduleDetailPage extends StatelessWidget {
  int id = 1;

  ScheduleDetailPage(int id){
    this.id = id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("詳細"),
      ),
      body: Container(
        child: Center(
          child: ScheduleDetail(id),
        ),
      ),
    );
  }
}


class ScheduleDetail extends StatefulWidget {
  int id;
  ScheduleDetail(int id){
    this.id = id;
  }
  @override
  _ScheduleDetailState createState() => _ScheduleDetailState();
}

class _ScheduleDetailState extends State<ScheduleDetail> {

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



  ///
  /// 値を取得
  ///


  ///
  ///日付部分
  ///
  Widget _buildDate(DateTime date){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(date.year.toString() + "年", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(date.month.toString() + "月" + date.day.toString() + "日"  + "(" + dayOfWeek[date.weekday -1].name + ")",
            style:TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          Text(date.hour.toString() + ":" + date.minute.toString(), style: TextStyle(fontSize:30, fontWeight: FontWeight.bold),)
        ],
      ),
    );
  }

  ///
  /// リストビュー部分
  ///
  List<Widget> _buildListView(){

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDate(DateTime.now()),
                Padding(
                    padding: EdgeInsets.all(10.0),
                  child:Text("〜", style: TextStyle(fontSize: 30))
                ),
                _buildDate(DateTime.now()),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Divider(
              color: Colors.black,
              height:  20,
            ),
          ),
        ],
      ),
    );
  }
}
