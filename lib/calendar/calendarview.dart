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

  DateTime _currentDate; //今日の日付
  int _currentMonth; //今月

  DateTime _selectDate; //選択された日付

  List<List<DateTime>> _dates = []; //_currentDaysのあつまり

  //最初の曜日(初期値は月曜日)
  int weekStart = 1;

  String headerText;  //タイトル文字

  PageController pageController = PageController(initialPage: 1);
  int currentMonthPage = 1; //今月のページ

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

  //曜日によって色を変える
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

    //1か月 + 前月、先月分のリスト
    for(int i=1; i <= lastDay.day; i++){
      //最初の日
      if(i == 1){
        for(int j=1; j <= firstDay.weekday-1; j++){
          if(month == 1){
            days.add(DateTime(year-1, 12, _previousDays-firstDay.weekday + j + 1));
          }else{
            days.add(DateTime(year, month-1, _previousDays-firstDay.weekday + j + 1));
          }
          print(days[days.length-1]);
        }
      }
      days.add(DateTime(year, month, i));
      print(days[days.length-1]);

      //最後の日
      if(i == lastDay.day){
        for(int j=1; j <= 7 - lastDay.weekday; j++){
          if(month == 12){
            days.add(DateTime(year+1, 1, j));
          }else{
            days.add(DateTime(year, month+1 , j));
          }
          print(days[days.length-1]);
        }
      }
      print((days.length-1 % 7).toString());
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

    print(_selectDate.toString());
  }

  //日付の詳細表示
  Future showSelectDateDialog() async{
    final Size size = MediaQuery.of(context).size;

    var value = await showDialog(
    context: context,
    builder: (BuildContext context) => new AlertDialog(
      title: new Text(_selectDate.year.toString() + "年" + _selectDate.month.toString() + "月" + _selectDate.day.toString() + "日"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Container(
              height: size.height / 2,
              child:
              Column(
                children: <Widget>[
                  Divider(
                      color: Colors.black
                  ),
                  _buildEvent("予定1"),
                  _buildEvent("予定2"),
                  _buildEvent("予定3"),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}

  //予定
  Widget _buildEvent(String title){
    return Container(
      width: 400,
      child:Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text("10:00"),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 5,
                  color: Colors.amber,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title),
                ],
              )
            ),
          ),
        ],
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
    for(int i=0; i < _dates.length; i++){
      print(i.toString() + ":" + _dates[i].toString());
    }

    if(pageId == _dates.length -1){
      DateTime tempDate = getDateTime(_dates.length-1, 10);
      setState((){
        _dates.add(_getTime(tempDate.year, tempDate.month+1));
      });
    }

    setState(() {
      DateTime tempDate = getDateTime(pageId, 10);
      headerText = tempDate.year.toString() + "年" + tempDate.month.toString() + "月";
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

  //header部分(< 2020年3月 >　の部分)
  // 前の月へ
  Widget _leftButton() => IconButton(
    onPressed: (){pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.linear);},
    icon: const Icon(Icons.chevron_left),
  );

  //次の月へ
  Widget _rightButton() => IconButton(
    onPressed: (){pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.linear);},
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
          height: (size.height - 230) / row,
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

    //テスト
    if(date == _currentDate){
      text = Text(date.day.toString() , style: TextStyle(fontWeight: FontWeight.bold));
      return Column(children: <Widget>[
        text,
      ],
      );
    }
    return Column(children: <Widget>[
      text,
    ],
    );
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
                GestureDetector(
                  onTap: onTapCurrentMonth,
                  child: Text(headerText, style: defaultHeaderTextStyle)),
                _rightButton(),
              ],
            ),
          ),
          Expanded(
            child:PageView(
              onPageChanged: onPageChanged,
              controller: pageController,
              children: List<Widget>.generate(_dates.length,(index){
                return _buildTable(_dates[index]);
              })
            ),
          ),
        ],
      )
    );
  }
}

