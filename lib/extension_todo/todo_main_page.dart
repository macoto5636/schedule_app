import 'package:flutter/material.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';


class TodoMainPage extends StatelessWidget {

  final _tabs = <Tab>[
    Tab(icon: Icon(Icons.dehaze)),
    Tab(icon: Icon(Icons.today)),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child:Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("ToDo"),
          bottom: TabBar(
            tabs: _tabs,
          ),
        ),
        body: TabBarView(
          children: [
            TodoMain(),
            Center(child: Icon(Icons.today),),
          ]
        ),
      )
    );
  }
}

class TodoMain extends StatefulWidget {
  @override
  _TodoMainState createState() => _TodoMainState();
}

//ポップアップメニュー
enum Menu{deleteTodo, changeDate}

class _TodoMainState extends State<TodoMain> {

  var _tasks; //タスク
  List _trueTasks = [];   //statusがtrueのタスク
  List _falseTasks = [];  //statusがfalseのタスク
  List _status = [];
  var calendarId;
  final formatPost = DateFormat("yyyy-MM-dd HH:mm");

  var _taskNameController = TextEditingController(text: "");

  @override
  void initState() {
    //_getTask();
    super.initState();
  }

  Future<bool> _getTask() async{
    bool flg = false;
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    calendarId = jsonDecode(localStorage.getString('calendar'))["id"];

    var url = "todo/get/" + calendarId.toString();
    print(url);

    _trueTasks.clear();
    _falseTasks.clear();

    http.Response res = await Network().getData(url);
    _tasks = jsonDecode(res.body);

    //ゴリ押しゴリラ
    if(res.body != "[]"){
      flg = true;

      _tasks.forEach((element){
        if(element["status"] == 1){
          _trueTasks.add(element);
        }else{
          _falseTasks.add(element);
          _status.add(false);
        }
      });
    }
    return flg;
  }

  void _addTodo(String taskName, DateTime date) async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));

    final data = {
      "task_name" : taskName,
      "status" : 0,
      "date" : null,
      "user_id" : user["id"],
      "calendar_id" : calendarId,
    };

    var result = await Network().postData(data, "todo/store");
  }

  void _changeState(int id, String taskName, bool status, DateTime date) async{
    final data = {
      "task_name" : taskName,
      "status" : status ? 1 : 0,
      "date" : date == null ? null : formatPost.format(date),
    };

    var result = await Network().postData(data, "todo/update/" + id.toString());
    print(result);
  }

  void _deleteTodo(int id) async{
    var result = await Network().getData("todo/delete/" + id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getTask(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            if(snapshot.data){
              return _falseTasks == null ? Container() : Column(
                children:[
                  ListView.builder(
                      itemCount: _falseTasks.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index){
                        return Column(
                          children:[
                            Container(
                              child: CheckboxListTile(
                                activeColor: Theme.of(context).primaryColor,
                                title: TextFormField(
                                  decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                  ),
                                  initialValue: _falseTasks[index]["task_name"],
                                  onChanged: (text){_changeState(_falseTasks[index]["id"], text, false, _falseTasks[index]["date"]);},
                                ),
                                subtitle: _falseTasks[index]["date"] == null ? null : Text(_falseTasks[index]["date"]),
                                secondary: PopupMenuButton(
                                  onSelected: (menu){_popupMenuSelected(menu, _falseTasks[index]["id"], _falseTasks[index]["task_name"], false);},
                                  itemBuilder: (BuildContext context)=>
                                  <PopupMenuEntry<Menu>>[
                                    const PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text("削除"),
                                      ),
                                      value: Menu.deleteTodo,
                                    ),
                                    const PopupMenuItem(
                                      child: ListTile(
                                        leading: Icon(Icons.access_time),
                                        title: Text("日時の編集"),
                                      ),
                                      value: Menu.changeDate,
                                    ),
                                  ],
                                ),
                                controlAffinity: ListTileControlAffinity.leading,
                                value: _status[index],
                                onChanged: (bool value){
                                  setState(() {
                                    _status[index] = value;
                                    _changeState(_falseTasks[index]["id"], _falseTasks[index]["task_name"], true, DateTime.parse(_falseTasks[index]["date"]));
                                  });
                                }
                              ),
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                          ]
                        );
                      }
                    ),
                  Expanded(
                    child:Container(
                      width: 400,
                      child: GestureDetector(
                        child:RichText(
                          textAlign: TextAlign.left,
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 3.0),
                                  child: Icon(Icons.add, color: Theme.of(context).primaryColor),
                                ),
                              ),
                              TextSpan(
                                text: "タスクを追加",
                                style: TextStyle(color: Theme.of(context).primaryColor),
                              )
                            ]
                          ),
                        ),
                        onTap: _addDialog,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: GestureDetector(
                        onTap: (){
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  )
                ]
              );
            }else{
              //タスクが0のとき
              return Center(
                child: Text("タスクがありません"),
              );
            }
          }else{
            //処理待ち
            return Center(
                child: CircularProgressIndicator()
            );
          }
        }
      ),
    );
  }

  //タスクの隣の・・・をタップしたとき
  void _popupMenuSelected(Menu selectedMenu, int id, String taskName, bool status) {
    switch(selectedMenu){
      case Menu.deleteTodo:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("タスクの削除"),
                content: Text("選択したタスクを削除します。よろしいですか？"),
                actions: [
                  FlatButton(
                    child: Text("キャンセル"),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      setState(() {
                        _deleteTodo(id);
                      });
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
        break;
      case Menu.changeDate:
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onConfirm: (date){
            setState(() {
              _changeState(id, taskName, status, date);
            });
            Fluttertoast.showToast(
              msg: "日時を変更しました",
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            );
          },
        );
        break;
      default : break;
    }
  }

  void _addDialog(){
    showDialog(
      context: context,
      builder: (context) {
        bool hasInputError = false;
        _taskNameController.text = "";
        String dateString = "選択されていません";
        return AlertDialog(
          title: Text("タスクの追加"),
          content:
              ListTile(
                title: TextField(
                  controller: _taskNameController,
                  maxLength: 20,
                  decoration: InputDecoration(
                    hintText: "タスク名を入力してください",
                    labelText: "タスク名",
                    errorText: hasInputError ? "文字数が超えています" : null,
                  ),
                  onChanged: (value){
                    hasInputError = value.length <= 20;
                    setState(() {
                      _taskNameController.text = value;
                    });
                  },
                ),
              ),
//              ListTile(
//                title: Text("日時"),
//                trailing: FlatButton(
//                  child: Container(
//                    decoration: BoxDecoration(
//                      border: Border.all(color: Colors.grey),
//                      borderRadius: BorderRadius.circular(8),
//                      color: Colors.grey,
//                    ),
//                    child: Padding(
//                      padding: EdgeInsets.all(5),
//                      child: Text(dateString, style: TextStyle(color: Colors.white),),
//                    ),
//                  ),
//                  onPressed: (){
//                    DatePicker.showDateTimePicker(
//                      context,
//                      showTitleActions: true,
//                      onConfirm: (date){
//                        setState(() {
//                          dateString = date.toString();
//                        });
//                      },
//                    );
//                  },
//                ),
//              ),
          actions: [
            FlatButton(
              child: Text("キャンセル"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("OK"),
              onPressed: (){
                setState(() {
                  _addTodo(_taskNameController.text, null);
                });
                Navigator.pop(context);

              },
            )
          ],
        );
      }
    );
  }
}

