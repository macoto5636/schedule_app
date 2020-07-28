import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubNoticePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("通知"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(context.watch<NoticeChecker>().listText[index]),
            trailing: NoticeChecking(i:index),
            onTap: () => context.read<NoticeChecker>().set(index),
          );
        },
        itemCount: context.watch<NoticeChecker>().listChecked.length,
      ),
    );
  }
}

class NoticeChecker with ChangeNotifier{
  int _checked = 0;
  List<bool> _listChecked = [true, false, false, false, false, false, false];
  List<String> _listText = ["なし", "予定の時刻", "５分前", "１５分前",
    "３０分前", "１時間前", "１日前"];

  int get checked => _checked;
  List<bool> get listChecked => _listChecked;
  List<String> get listText => _listText;

  void set(int i) {
    if(_listChecked[i]){
      _listChecked[i] = false;
      if(_listChecked.every((element) => element == false)){
        _listChecked[0] = true;
      }
    }else{
      if(i != 0 && _listChecked[0]){
        _listChecked[0] = false;
      }else if(i == 0){
        for(int i = 1; i < listText.length; i++){
          _listChecked[i] = false;
        }
      }
      _listChecked[i] = true;
    }
    notifyListeners();
  }
}

class NoticeChecking extends StatelessWidget {
  int i;
  NoticeChecking({this.i});

  @override
  Widget build(BuildContext context) {
    Icon icon;
    if(context.watch<NoticeChecker>().listChecked[i]){
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

class NoticeText extends StatelessWidget {
  const NoticeText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> listText = context.watch<NoticeChecker>().listText;
    List<bool> listCheck = context.watch<NoticeChecker>().listChecked;
    String text = "";
    for(int i = 0; i < listText.length; i++){
      if(listCheck[i]){
        text += listText[i];
      }
    }
    return Container(
      width: 200,
//      padding: new EdgeInsets.all(5.0),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.black),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        child: Text(
          text,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }
}
