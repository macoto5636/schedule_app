import 'package:flutter/material.dart';
import 'package:scheduleapp/expantion_drawer.dart';

//Git Test

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'schedule_app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Calendar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentTabIndex = 1; //BottomNavigationBarItem現在選択しているやつ

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        //拡張機能一覧
      ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.view_carousel),
            iconSize: 35,
            tooltip: 'change calendar',
            onPressed: (){},
          )
        ],
      ),
      drawer: Drawer(child: ExpantionDrawer()),
      body: Center(
        child: Column(

        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton:
      Container(
          margin: EdgeInsets.only(top: 50.0),
          child:FloatingActionButton(
          child: Icon(Icons.add, size: 40.0,), onPressed: () {})),

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
      ),// This trailing comma makes auto-formatting nicer for build methods.
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
  }

}
