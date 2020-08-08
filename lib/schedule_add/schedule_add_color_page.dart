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
                color: Color(context.watch<ColorChecker>().listColor[index]),
//                color: "0xFF40C4FF",
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
  int _checked = 6;
  List<bool> _listChecked = [false,false,false,false,false,false,true,false,false,false];
  List<String> _listText = [
    "ピンク","レッド","オレンジ","イエロー","ライトグリーン",
    "グリーン","ライトブルー","ブルー","インディゴ","パープル"
  ];
  List<int> _listColor = [
    0xFFFF4081,0xFFFF5252,0xFFFF6E40, 0xFFFFFF00
    ,0xFFB2FF59,0xFF69F0AE,0xFF40C4FF
    ,0xFF448AFF,0xFF536DFE,0xFFE040FB
  ];

  int get checked => _checked;
  List<bool> get listChecked => _listChecked;
  List<String> get listText => _listText;
  List<int> get listColor => _listColor;

  void set(int i){
    if(_listChecked[i]){

    }else{
      _listChecked[_checked] = false;
      _checked = i;
      _listChecked[i] = true;
    }
    notifyListeners();
  }

  void clear() {
    set(0);
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

class ColorText extends StatelessWidget {
  const ColorText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<ColorChecker>().listText[context.watch<ColorChecker>().checked]);
  }
}