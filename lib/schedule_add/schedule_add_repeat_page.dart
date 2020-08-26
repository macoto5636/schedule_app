import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubRepeatPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("繰り返し"),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(context.watch<RepeatChecker>().listText[index]),
              trailing: RepeatChecking(i:index),
              onTap: () => context.read<RepeatChecker>().set(index),
            );
          },
          itemCount: context.watch<RepeatChecker>().listChecked.length,
        )
    );
  }
}

class RepeatChecker with ChangeNotifier{
  bool _flg = false;
  int _checked = 0;
  List<bool> _listChecked = [true,false,false,false,false];
  List<String> _listText = ["しない","毎日","毎週","毎月","毎年"];

  bool get flg => _flg;
  int get checked => _checked;
  List<bool> get listChecked => _listChecked;
  List<String> get listText => _listText;

  void set(int i){
    if(!_listChecked[i]){
      if(i == 0){
        _flg = false;
      }else{
        _flg = true;
      }
      _listChecked[_checked] = false;
      _checked = i;
//      _text = _listText[i];
      _listChecked[i] = true;
    }
    notifyListeners();
  }
}

class RepeatChecking extends StatelessWidget {
  int i;
  RepeatChecking({this.i});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    if(context.watch<RepeatChecker>().listChecked[i]){
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

class RepeatText extends StatelessWidget {
  const RepeatText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(context.watch<RepeatChecker>().listText[context.watch<RepeatChecker>().checked]);
  }
}

