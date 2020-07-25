
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  String _title = "";           //予定のタイトル
  int _allDayFlag = 0;         //オールデイか否かのフラグ
  DateTime _startDate = DateTime.now();     //開始日時
  DateTime _endDate = DateTime.now();       //終了日時
  int _notificationFlag = 0;   //通知のフラグ
  int _notification = 0;       //通知
  int _repetitionFlag = 0;     //繰り返しのフラグ
  int _repetition = 0;         //繰り返し
  String _memo = "";            //予定のメモ
  String _place = "";           //予定の場所
  String _urlSchedule = "";             //予定のURL

  var iconSIze = 25.0;
  
  @override
  void initState() {
    super.initState();
    getScheduleDetail(widget.id);

  }

  ///
  /// 値を取得
  ///
  void getScheduleDetail(int id) async{
    var url = "http://10.0.2.2:8000/api/schedules/" + id.toString();
    print(url);
    await http.get(url).then((response) {
      print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      Map<String, dynamic> scheduleDetail = json.decode(response.body);

      setState(() {
        _title = scheduleDetail['title'];
        _allDayFlag = scheduleDetail['all_day'];
        _startDate = DateTime.parse(scheduleDetail['start_date']);
        _endDate = DateTime.parse(scheduleDetail['end_date']);
        _notificationFlag = scheduleDetail['notification_flag'];
        _notification = scheduleDetail['notification'];
        _repetitionFlag = scheduleDetail['repetition_flag'];
        _repetition = scheduleDetail['repetition'];
        _memo = scheduleDetail['memo'];
        _place = scheduleDetail['place'];
        _urlSchedule = scheduleDetail['url'];
      });
    });
   }


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

  Widget _buildListItem(IconData icon, String text){
    return ListTile(
      leading: Icon(
        icon,
        size: iconSIze,
      ),
      title: Text(text)
    );
  }

  List<Widget> _buildListColumn(){
    List<Widget> list = [];

    if(_place != ""){
      list.add(
        _buildListItem(Icons.location_on, _place)
      );
    }
    if(_urlSchedule != ""){
      list.add(
        _buildListItem(Icons.link, _urlSchedule)
      );
    }
    if(_memo != ""){
      list.add(
        _buildListItem(Icons.subject, _memo)
      );
    }
    //場所、URL、メモのいずれかがあるときだけ線を引く
    if(list.length > 0){
      list.add(
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Divider(
            color: Colors.black,
            height:  20,
          ),
        ),
      );
    }

    if(_notificationFlag == 0){
      list.add(
          _buildListItem(Icons.timer, "なし")
      );
    }else{
      list.add(
          _buildListItem(Icons.timer, _notification.toString())
      );
    }

    if(_repetitionFlag == 0){
      list.add(
        _buildListItem(Icons.autorenew, "なし")
      );
    }else{
      list.add(
        _buildListItem(Icons.autorenew, _repetition.toString())
      );
    }

    return list;
  }

  Widget _buildListView(){
    return ListView(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: _buildListColumn()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(6.0),
            child:
              Text(_title, style: TextStyle(fontSize:30, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDate(_startDate),
                Padding(
                    padding: EdgeInsets.all(10.0),
                  child:Text("〜", style: TextStyle(fontSize: 30))
                ),
                _buildDate(_endDate),
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
          Column(
            children: [
              _buildListView(),
              Container(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("編集", style: TextStyle(color: Colors.blue), textAlign: TextAlign.right,),
                ),
              )
            ],
          ),

        ],
      ),
    );
  }
}
