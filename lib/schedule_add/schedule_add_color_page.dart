import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubColorPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("色"),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Icon(
                Icons.palette,
                color: context.watch<ColorChecker>().listColor[index],
              ),
              title: Text(context.watch<ColorChecker>().listText[index]),
              trailing: ColorChecking(i:index),
              onTap: () => context.read<ColorChecker>().set(index),
            );
          },
          itemCount: context.watch<ColorChecker>().listChecked.length,
        )
    );
  }
}

class ColorChecker with ChangeNotifier{
  int _checked = 0;
  List<bool> _listChecked = [true,false,false,false,false,false,false,false,false,false];
  List<String> _listText = ["レッド","オレンジ","イエロー","ライトグリーン","グリーン","ライトブルー"
    ,"ブルー","インディゴ","パープル","ピンク"
  ];
  List<Color> _listColor = [Colors.redAccent,Colors.deepOrangeAccent, Colors.yellowAccent
    , Colors.lightGreenAccent,Colors.greenAccent,Colors.lightBlueAccent
    ,Colors.blueAccent,Colors.indigoAccent,Colors.deepPurpleAccent,Colors.pinkAccent
  ];

  int get checked => _checked;
  List<bool> get listChecked => _listChecked;
  List<String> get listText => _listText;
  List<Color> get listColor => _listColor;

  void set(int i){
    if(_listChecked[i]){

    }else{
      _listChecked[_checked] = false;
      _checked = i;
      _listChecked[i] = true;
    }
    notifyListeners();
  }
}

class ColorChecking extends StatelessWidget {
  int i;
  ColorChecking({this.i});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    if(context.watch<ColorChecker>().listChecked[i]){
      icon = Icon(
        Icons.check,
        color: Colors.red,
        //size: ,
      );
    }else{
      icon = Icon(null);
    }
    return icon;
  }
}

//
//class SubColorPage extends StatefulWidget{
//  @override
//  SubColorPageState createState() => SubColorPageState();
//}
//
//class SubColorPageState extends  State<SubColorPage>{
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        leading: IconButton(
//          icon: Icon(Icons.arrow_back_ios),
//          onPressed: () => Navigator.of(context).pop(),
//        ),
//        title: Text("色"),
//        centerTitle: true,
//      ),
//      body: ListView.builder(
//        itemBuilder: (BuildContext context, int index) {
//          return ListTile(
//            leading: Icon(
//              Icons.palette,
//              color: context.watch<ColorChecker>().listColor[index],
//            ),
//            title: Text(context.watch<ColorChecker>().listText[index]),
//            trailing: ColorChecking(i:index),
//            onTap: () => context.read<ColorChecker>().set(index),
//          );
//        },
//        itemCount: context.watch<ColorChecker>().listChecked.length,
//      )
//    );
//  }
//}