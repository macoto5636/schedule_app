import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduleapp/app_theme.dart';
import 'package:scheduleapp/calendar/calendar_change_page.dart';

import 'package:scheduleapp/extention_drawer.dart';
import 'package:scheduleapp/first_boot_page.dart';

import 'package:scheduleapp/calendar/calendarview.dart';
import 'package:scheduleapp/settings/setting_page.dart';
import 'package:scheduleapp/timetable/timetable_view.dart';

import 'package:scheduleapp/schedule_add/schedule_add_page.dart';
import 'package:scheduleapp/schedule_add/schedule_add_repeat_page.dart';
import 'package:scheduleapp/schedule_add/schedule_add_notice_page.dart';
import 'package:scheduleapp/schedule_add/schedule_add_color_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((prefs) {
    var themeKey = prefs.getString("theme_key") ?? "themeLightBlue";
    runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeNotifier(themeKey)),
            ChangeNotifierProvider(create: (_) => RepeatChecker()),
            ChangeNotifierProvider(create: (_) => NoticeChecker()),
            ChangeNotifierProvider(create: (_) => ColorChecker()),
          ],
          child:MyApp(),
        )
    );
  });
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      title: 'schedule_app',
      theme: themeNotifier.getTheme(),
//      theme: ThemeData(
//        primaryColor: Colors.blue,
//        primarySwatch: Colors.blue,
//        visualDensity: VisualDensity.adaptivePlatformDensity,
//      ),
//      home: MyHomePage(title: '2020年'),
        home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

_MyHomePageState myHomePageState = _MyHomePageState();

class _MyHomePageState extends State<MyHomePage> {
  int _currentTabIndex = 2; //BottomNavigationBarItem現在選択しているやつ

  String currentDate = DateTime.now().year.toString() + "年" + DateTime.now().month.toString() + "月";  //現在表示されてるカレンダーの年月

  int _page = 1;


  callback(bool status){
    setState(() {
      if(_page == 1){
        _page = 2;
      }else{
        _page = 1;
      }
      _change();
    });
  }

  void _change() async{
    await Future.delayed(Duration(milliseconds: 100),);
    setState((){
      if(_page == 1){
        _page = 2;
      }else{
      _page = 1;
      }
    });
  }

  @override

  void setCurrentDate(String date){
    setState(() {
      currentDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        //拡張機能一覧
          child: ExtensionDrawer()
      ),
      appBar: AppBar(
//        backgroundColor: getPrimaryColor(context),
        centerTitle: true,
        title: Text(currentDate),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.view_carousel),
            iconSize: 35,
            tooltip: 'change calendar',
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarChangePage())
              )
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            if(_currentTabIndex == 0)Expanded(
              child: SettingPage(),
            ),
            if(_currentTabIndex == 2 && _page==1) Expanded(
              child: CalendarView(setCurrentDate),
            ),
            if(_currentTabIndex == 2 && _page==2) Expanded(
              child: TimeTableView(setCurrentDate),
            ),
          ],
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
      Container(
          margin: EdgeInsets.only(top: 50.0),
          child:FloatingActionButton(
            child: Icon(Icons.add, size: 40.0,),
                onPressed: () async {
                  await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return ScheduleAddPage();
                        }
                      )
                  );
                  callback(true);
                  print("aaaaa");
                }
            )
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const<BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,size: 35,),
            title: Text('設定'),
          ),
          BottomNavigationBarItem(
            icon: Icon(null),
            title: Text(''),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today,size: 35,),
            title: Text('切替')
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTabIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  //BottomNavigationBarタップ時
  //真ん中の追加だけタップしても何も起きないようにしている（必要かはわからん
  void _onItemTapped(int index){
    if(index != 1){
      setState((){
        _currentTabIndex = index;
      });
    }
    if(index == 0){
      setState(() {
        setCurrentDate("設定");
      });
//      Navigator.push(
//          context,
//          MaterialPageRoute(builder: (context) => SettingPage())
//      );
    }
    if(index == 2){
      if(_page == 1){
        _page = 2;
      }else{
        _page = 1;
      }
      setState(() {
        currentDate = DateTime.now().year.toString() + "年" + DateTime.now().month.toString() + "月";
      });
    }

  }

}
