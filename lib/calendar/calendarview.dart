import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'default_style.dart';

import 'package:scheduleapp/schedule_detail.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class DayOfWeek{
  int id;
  String name;
  DayOfWeek(this.id, this.name);
}

class CalendarView extends StatefulWidget{
  String currentDate = DateTime.now().year.toString() + "年" + DateTime.now().month.toString() + "月";
  Function(String) setCurrentDate;
  CalendarView(this.currentDate, this.setCurrentDate);

  @override
  _CalendarState createState() => new _CalendarState();
}

class _CalendarState extends State<CalendarView>{

  DateTime _currentDate; //今日の日付
  int _currentMonth; //今月

  DateTime _selectDate; //選択された日付

  List<List<DateTime>> _dates = []; //_currentDaysのあつまり

  //最初の曜日(初期値は月曜日)
  int weekStart = 1;

  String headerText;  //タイトル文字

  PageController pageController = PageController(initialPage: 1);
  int currentMonthPage = 1; //今月のページ

  //カレンダーの予定
  List<int> _schedulesId = [];
  List<String> _schedulesTitle = [];
  List<bool> _schedulesAllDay = [];
  List<DateTime> _schedulesStartDate = [];
  List<DateTime> _schedulesEndDate = [];
  List<Color> _schedulesColor = [];

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

    getSchedules(1);
    _currentDate = DateTime.now();
    _selectDate = _currentDate;
    _currentDate = DateTime(_currentDate.year, _currentDate.month, _currentDate.day);
    _currentMonth = _currentDate.month;

    headerText = _currentDate.year.toString() + "年" + _currentDate.month.toString() + "月";

    DateTime previousMonth = DateTime(_currentDate.year, _currentDate.month, 0);
    DateTime nextMonth = DateTime(_currentDate.year, _currentDate.month+2, 0);

    //3か月分だけ取得
    print("前月" +previousMonth.toString());
    print("次月" + nextMonth.toString());
    _dates.add(_getTime(previousMonth.year,previousMonth.month));
    _dates.add(_getTime(_currentDate.year, _currentDate.month));
    _dates.add(_getTime(nextMonth.year, nextMonth.month));


  }

  ///
  ///予定を取得する
  ///@param calendar_id
  ///@return List
  ///
  void getSchedules(int id) async{
    var url = "http://10.0.2.2:8000/api/calendar/" + id.toString();
    print(url);
    await http.get(url).then((response){
      print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
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

      //all dayか否か
      _schedulesAllDay = list.map<bool>((value){
        if(value['all_day']==0){
          return false;
        }else{
          return true;
        }
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

  ///
  ///曜日に合わせてテキストの色を変更する
  ///土曜日なら青、日曜日なら赤、月が違うなら灰
  ///@param id(曜日のID）
  ///@param name(日にち)
  ///@param flg(月が違うかどうかのフラグ)
  ///@return widget text
  ///
  Widget _changeText(int id, String name, int flg){
    Widget text;
    if(id == 6){
      text = Text(name , style: TextStyle(color: Colors.blue));
    }else if(id == 7){
      text = Text(name , style: TextStyle(color: Colors.red));
    }else{
      text = Text(name);
    }

    if(flg == 1){
      text = Text(name, style: TextStyle(color: Colors.grey));
    }

    return text;
  }

  //日付取得
  List<DateTime> _getTime(int year, int month){

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
      title: new Text(_selectDate.year.toString() + "年" + _selectDate.month.toString() + "月" + _selectDate.day.toString() + "日" + "(" + dayOfWeek[_selectDate.weekday -1].name + ")"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Divider(
                color: Colors.black,
            ),
            Container(
              height: size.height ,
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
    for(int i=0; i<_schedulesId.length; i++){
      if(_selectDate == getDateShaping(_schedulesStartDate[i])){

        Widget widget =
        GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap:(){moveScheduleDetailPage(context, _schedulesId[i]);},
          child:Padding(
            padding: EdgeInsets.all(1.0),
          child:Container(
            width: 500,
            child:Row(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      children: [
                        if(_schedulesAllDay[i])
                          Text(" 終日 "),
                        if(!_schedulesAllDay[i])
                          Text(_schedulesStartDate[i].hour.toString().padLeft(2, '0') + ":" + _schedulesStartDate[i].minute.toString().padLeft(2, '0') + "\n ｜"
                              + "\n" + _schedulesEndDate[i].hour.toString().padLeft(2, '0') + ":" + _schedulesEndDate[i].minute.toString().padLeft(2, '0')),
                      ],
                    )
                ),
                Expanded(
                  child:Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          width: 5,
                          color: _schedulesColor[i],
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child:Text(_schedulesTitle[i], overflow: TextOverflow.ellipsis,maxLines: 1,),
                    )
                  ),
                )
              ],
              ),
            )
          )
        );

        widgets.add(widget);
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
  Widget _buildTableCell(DateTime date, row){
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap:(){onTapSelectDate(date);},
      child: Container(
          height: (size.height - 170) / row,
          child: _buildCell(date),
          color: date==_selectDate ? Colors.lightBlueAccent: Colors.white,
      ),
    );
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
                height: 23,
                width: 23,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: Text(date.day.toString() , style: TextStyle(fontWeight: FontWeight.bold, color:Colors.white), textAlign: TextAlign.center,),
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
    for(int i=0; i<_schedulesStartDate.length; i++){
      if(date == getDateShaping(_schedulesStartDate[i])){
        Widget widget =
          Padding(
              padding: EdgeInsets.all(1.0),
            child:
            Container(
              width: 300,
              child: Text(_schedulesTitle[i], style: TextStyle(color: Colors.white, fontSize: 12),textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,maxLines: 1),
              color: _schedulesColor[i]
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
//          Container(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                _leftButton(),
//                GestureDetector(
//                  onTap: onTapCurrentMonth,
//                  child: Text(headerText, style: defaultHeaderTextStyle)),
//                _rightButton(),
//              ],
//            ),
//          ),
          Container(
            child:Expanded(
              child:PageView(
                onPageChanged: onPageChanged,
                controller: pageController,
                children: List<Widget>.generate(_dates.length,(index){
                  return _buildTable(_dates[index]);
                })
              ),
            ),
          ),
        ],
      )
    );
  }
}

