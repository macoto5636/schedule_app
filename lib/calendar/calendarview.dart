import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'default_style.dart';

class DayOfWeek{
  int id;
  String name;
  DayOfWeek(this.id, this.name);
}
class CalendarView extends StatefulWidget{

  @override
  _CalendarState createState() => new _CalendarState();
}

class _CalendarState extends State<CalendarView>{

  int _currentYear;  //現在の年
  int _currentMonth;  //現在の月
  int _currentDay;   //現在の日
  int _currentDays;  //現在の月の日数
  int _firstWeek;   //当月の最初の曜日
  int _lastWeek;    //当月の最終日の曜日
  int _previousDays; //前月の日数
  int _nextDays;     //次月の日数

  int tempDay = 1; //test

  int maxYear; //
  int minYear;

  //最初の曜日(初期値は月曜日)
  int weekStart = 1;

  var titleText;  //タイトル文字

  PageController pageController = PageController(initialPage: 0);

  //最初
  @override
  initState(){
    super.initState();
    getTime();
  }

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


  Widget getPageWidget(){
    return Container(
      child: Table(
        border: TableBorder.all(),
        children: _calendarBodyWidgets(),
      ) ,
    );
  }

  //曜日によって色を変える
  Widget _changeText(int id, String name){
    Widget text;
    if(id == 6){
      text = Text(name , style: TextStyle(color: Colors.blue));
    }else if(id == 7){
      text = Text(name , style: TextStyle(color: Colors.red));
    }else{
      text = Text(name);
    }
    return text;
  }

  //日付取得
  void getTime(){
    //今日の日付取得
    final now = DateTime.now();

    _currentYear = now.year;
    _currentMonth = now.month;
    _currentDay = now.day;

    //当月の日数取得
    _currentDays = DateTime(_currentYear, _currentMonth + 1, 0).day;
    //当月の最初の曜日取得
    _firstWeek = DateTime(_currentYear, _currentMonth, 1).weekday;
    //当月の最後の曜日取得
    _lastWeek = DateTime(_currentYear, _currentMonth, _currentDays).weekday;

    //前月の日付の取得
    _previousDays = DateTime(_currentYear, _currentMonth, 0).day;
    //次月の日付の取得
    _nextDays = DateTime(_currentYear, _currentMonth + 2, 0).day;
  }

  //PageView



  //header部分(< 2020年3月 >　の部分)
  // 前の月へ
  Widget _leftButton() => IconButton(
    onPressed: (){},
    icon: const Icon(Icons.chevron_left),
  );

  //次の月へ
  Widget _rightButton() => IconButton(
    onPressed: (){},
    icon: const Icon(Icons.chevron_right),
  );

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
      Widget text = _changeText(element.id, element.name);
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
  Widget _dayWidget(int day, int youbi){
    Widget text = _changeText(youbi, day.toString());
    Widget dayWidget;
    dayWidget =
        Column(children: <Widget>[
          Container(
            height: 90,
            child: text,
          )
        ]);
    return dayWidget;
  }

  //週
  List<Widget> _weekWidget(int startDay){
    //getTime();
    int day = startDay;
    int youbi = 1;

    var weekWidget = List<Widget>();
    var weekRowWidget = List<TableRow>();
    //最初の週の場合
    if (day == 1) {
      youbi = _firstWeek;
      for (int i = 1; i <= 7; i++) {
        if (i < youbi) {
          weekWidget.add(
            Column(children: <Widget>[
              Text((_previousDays - youbi + i + 1).toString(),
                  style: TextStyle(color: Colors.grey)),
            ]),
          );
        } else {
          weekWidget.add(
              _dayWidget(day, youbi)
          );
          day++;
          youbi++;
        }
      }
      tempDay = day;
    } else if (day + 7 > _currentDays) { //最後の週の場合
      int nextDay = 1;
      for (int i = 1; i <= 7; i++) {
        if (i <= _lastWeek && day <= _currentDays) {
          weekWidget.add(
              _dayWidget(day, youbi)
          );
          day++;
          youbi++;
        } else {
          weekWidget.add(
            Column(children: <Widget>[
              Text(nextDay.toString(),
                  style: TextStyle(color: Colors.grey))
              ,
            ]),
          );
          nextDay++;
        }
      }
      tempDay = day;
    } else { //その他の週
      for (int i = 1; i <= 7; i++) {
        weekWidget.add(
            _dayWidget(day, youbi)
        );
        day++;
        youbi++;
      }
      tempDay = day;
    }
    weekRowWidget.add(
      TableRow(
        children: weekWidget,
      ),
    );
    return weekWidget;
  }

  //1週間分返している
  List<TableRow> _calendarBodyWidgets(){
    //getTime();
    try {
      var weekRowWidget = List<TableRow>();
      var weekWidget = List<Widget>();
      while (tempDay < _currentDays) {
        print(tempDay.toString() + "a");
        weekWidget = _weekWidget(tempDay);
        weekRowWidget.add(
          TableRow(
            children: weekWidget,
          ),
        );
      }
      return weekRowWidget;
    }catch(e){
      print(e);
    }
  }

  //1か月分表示
  Column _calendarMonthWidgets(){
    return Column(
        children: <Widget>[
          Container(
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: _calendarHeaderWidgets(),
                )
              ],
            ),
          ),
          Expanded(
            child: Table(
              border: TableBorder.all(),
              children: _calendarBodyWidgets(),
            ),
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _leftButton(),
                Text("2020年7月", style: defaultHeaderTextStyle),
                _rightButton(),
              ],
            ),
          ),

          Expanded(
            child:PageView(
              controller: pageController,
              children: <Widget>[
                _calendarMonthWidgets(),
                _calendarMonthWidgets(),
                _calendarMonthWidgets(),
              ]
            ),
          ),
        ],
      )
    );
  }
}

