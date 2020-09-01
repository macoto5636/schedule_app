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
    Tab(icon: Icon(Icons.check_box)),
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
            TodoMain(0),
            TodoMain(1),
            TodoMain(2),
          ]
        ),
      )
    );
  }
}

class TodoMain extends StatefulWidget {
  int todayFlag;  //0:全てのタスク表示 / 1:今日のタスク表示
  TodoMain(this.todayFlag);

  @override
  _TodoMainState createState() => _TodoMainState();
}

//ポップアップメニュー
enum Menu{deleteTodo, changeDate, changeState}

class _TodoMainState extends State<TodoMain> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final GlobalKey<AnimatedListState> _listTrueKey = GlobalKey();

  Future<List> _tasks;

  bool _flg = false;
  bool showTodo = false;
  List _trueTasks = [];   //statusがtrueのタスク
  List _falseTasks = [];  //statusがfalseのタスク
  List _trueStatus = [];
  var calendarId;
  DateTime currentDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final formatPost = DateFormat("yyyy-MM-dd HH:mm");

  var _taskNameController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _getTask() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    calendarId = jsonDecode(localStorage.getString('calendar'))["id"];

    var url = "todo/get/" + calendarId.toString();
    print(url);

    _trueTasks.clear();
    _falseTasks.clear();

    http.Response res = await Network().getData(url);
    List tasks = jsonDecode(res.body);

    //ゴリ押しゴリラ
    if(res.body != "[]"){
      tasks.forEach((element){
        if(widget.todayFlag == 2 && element["status"] == 1){
          _falseTasks.add(element);
          _flg = true;
        }else if(element["status"] == 1){
          if(widget.todayFlag == 0){
            _trueTasks.add(element);
            _trueStatus.add(true);
          }else if(element["date"] == null ? false : getDateShaping(DateTime.parse(element["date"])) == currentDate){
            _trueTasks.add(element);
            _trueStatus.add(true);
          }
        }else{
          if(widget.todayFlag == 0){
            _falseTasks.add(element);
            _flg = true;
          }else if(element["date"] == null ? false : getDateShaping(DateTime.parse(element["date"])) == currentDate && widget.todayFlag != 2){
            _falseTasks.add(element);
            _flg = true;
          }
        }
      });
    }

    if(widget.todayFlag == 2){
      _falseTasks.sort((a,b) => b['id'].compareTo(a['id']));
    }
    return _flg;
  }

  void _addTodo(String taskName, DateTime date) async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));

    final data = {
      "task_name" : taskName,
      "status" : 0,
      "date" : widget.todayFlag == 0 ? null : formatPost.format(currentDate),
      "user_id" : user["id"],
      "calendar_id" : calendarId,
    };

    http.Response res = await Network().postData(data, "todo/store");
    print("result" + res.body.toString());

    _falseTasks.add({
      "id" : int.parse(res.body),
      "task_name" : taskName,
      "date" : widget.todayFlag == 0 ? null : formatPost.format(currentDate),
      "calendar_id" :calendarId,
      "created_at" : DateTime.now(),
      "updated_at" : DateTime.now(),
    });

    _listKey.currentState.insertItem(_falseTasks.length -1);
  }

  void _changeState(int id, String taskName, bool status, DateTime date) async{

    final data = {
      "task_name" : taskName,
      "status" : status ? 1 : 0,
      "date" : date == null ? null : formatPost.format(date),
    };

    var result = await Network().postData(data, "todo/update/" + id.toString());
  }

  void _deleteTodo(int id) async{
    var result = await Network().getData("todo/delete/" + id.toString());
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
      child: FutureBuilder(
        future: _getTask(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            if(snapshot.data){
              return _falseTasks == null ? Container() : GestureDetector(
                onTap: (){
                  if(widget.todayFlag != 2){
                    FocusScope.of(context).requestFocus(new FocusNode());
                    _addDialog();
                  }
                  },
                child:_falseTasks.length!=0 ?SingleChildScrollView(
                  child: Column(
                    children: [

                      Row(
                        children: [
                          widget.todayFlag == 2 ? Container() :
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: _buildAddText()
                          ),
//                          Padding(
//                            padding: EdgeInsets.only(left: 10.0),
//                            child: _buildTrueTaskText(),
//                          )
                        ],
                      ),
                      AnimatedList(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        key: _listKey,
                        initialItemCount: _falseTasks.length,
                        itemBuilder: (BuildContext context, int index, Animation animation){
                          return _buildTodoItem(index, _falseTasks[index]["id"], _falseTasks[index]["task_name"], _falseTasks[index]["date"], _falseTasks[index]["status"], animation);
                          },
                      ),
//                      if(showTodo && _trueTasks != null)
//                        Expanded(
//                          child: AnimatedList(
//                            shrinkWrap: true,
//                            physics: NeverScrollableScrollPhysics(),
//                            key: _listTrueKey,
//                            initialItemCount: _trueTasks.length,
//                            itemBuilder: (BuildContext context, int index, Animation animation){
//                              return _buildTrueTodoItem(index, _trueTasks[index]["id"], _trueTasks[index]["task_name"], _trueTasks[index]["date"], animation);
//                            },
//                          ),
//                        )

                    ],
                  ),
                //)
                ):
                Column(
                  children: [
                    Expanded(
                      child: Center(
                        child:RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                          children: [
                            TextSpan(
                              text: widget.todayFlag == 0 ? "タスクはありません\n" : "今日のタスクはありません\n",
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            WidgetSpan(
                              child: _buildAddText(),
                            ),
//                            TextSpan(
//                                text: "\n"
//                            ),
//                            WidgetSpan(
//                              child: _buildTrueTaskText(),
//                            )
                          ]
                         ),
                        ),
                      ),
                    ),
                  ],
                  )
              );
            }else{
              //タスクが0のとき
              return GestureDetector(
                  onTap: (){_addDialog();},
                  child:Column(
                  children: [
                    Expanded(
                      child: Center(
                        child:RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.todayFlag == 0 ? "タスクはありません\n" : "今日のタスクはありません\n",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              WidgetSpan(
                                child: _buildAddText(),
                              ),
//                              TextSpan(
//                                text: "\n"
//                              ),
//                              WidgetSpan(
//                                child: _buildTrueTaskText(),
//                              )
                            ]
                          ),
                        ),
                      ),
                    ),
//                    SingleChildScrollView(
//                      child: Column(
//                        children: [
//                          if(showTodo && _trueTasks != null)
//                            for(int j=0; j<_trueTasks.length; j++)
//                              _buildTrueTodoItem(j),
//                        ],
//                      ),
//                    )
//                    if(showTodo && _trueTasks != null)
//                      Flexible(
//                        child: AnimatedList(
//                          shrinkWrap: true,
//                          key: _listTrueKey,
//                          initialItemCount: _trueTasks.length,
//                          itemBuilder: (BuildContext context, int index, Animation animation){
//                            return _buildTrueTodoItem(index, _trueTasks[index]["id"], _trueTasks[index]["task_name"], _trueTasks[index]["date"], animation);
//                          },
//                        ),
//                      )
                  ],
                )
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
  void _popupMenuSelected(Menu selectedMenu,int index, int id, String taskName, bool status, DateTime date) {
    switch(selectedMenu){
      case Menu.deleteTodo:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("確認"),
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
                      _falseTasks.remove(index);
                      AnimatedListRemovedItemBuilder builder = (context, animation){
                        return _buildTodoItem(index, id, taskName, date.toString(), status==false?0:1, animation);
                      };
                      _listKey.currentState.removeItem(index, builder);

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
          locale: LocaleType.jp,
          onConfirm: (value){
            setState(() {
              _changeState(id, taskName, status, value);
            });
            Fluttertoast.showToast(
              msg: "日時を変更しました",
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
            );
          },
        );
        break;
      case Menu.changeState:
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("確認"),
                content: Text("選択したタスクを未実行に変更します。よろしいですか？"),
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
                        _changeState(id, taskName, status, date);
                      });
                      _falseTasks.remove(index);
                      AnimatedListRemovedItemBuilder builder = (context, animation){
                        return _buildTodoItem(index, id, taskName, date.toString(), status==false?0:1, animation);
                      };
                      _listKey.currentState.removeItem(index, builder);

                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
        break;
      default : break;
    }
  }

  Widget _buildTodoItem(int index, int id,String taskName, String date, int flg, Animation animation){
    return SizeTransition(
      sizeFactor: animation,
      child: Container(
        padding: EdgeInsets.all(5.0),
        height: date == null ? 50.0 : 70.0,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              child: flg == 0 ? Icon(Icons.check_box_outline_blank, size:30.0 ,color: Colors.grey):
                      Icon(Icons.check_box, size:30.0, color: Colors.grey,),
              onTap: (){
                if(flg == 0){
                  setState(() {
                    _changeState(id, taskName, true, date==null?null:DateTime.parse(date));
                  });
                  _falseTasks.remove(index);
                  AnimatedListRemovedItemBuilder builder = (context, animation){
                    return _buildTodoItem(index, id, taskName, date, flg, animation);
                  };
                  _listKey.currentState.removeItem(index, builder);
                }
              },
            ),
            Expanded(
              child:Container(
                padding: EdgeInsets.only(left: 5.0),
                child: date == null ?
                Text(taskName, style: flg == 1 ? TextStyle(color: Colors.grey):null,):
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: taskName + "\n",
                            style: flg == 1 ? TextStyle(color: Colors.grey) : Theme.of(context).textTheme.bodyText1,
                          ),
                          TextSpan(
                            text: date.toString(),
                            style: TextStyle(fontSize: 15.0, color: Colors.grey),
                          )
                        ]
                      ),
                    )
              ),
            ),
            PopupMenuButton(
              onSelected: (menu){_popupMenuSelected(menu, index, id, taskName, false, date==null?null:DateTime.parse(date));},
              itemBuilder: (BuildContext context)=>
              <PopupMenuEntry<Menu>>[
                const PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("削除"),
                  ),
                  value: Menu.deleteTodo,
                ),
                flg == 0 ?
                const PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("日時の編集"),
                  ),
                  value: Menu.changeDate,
                ):
                const PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.check_box_outline_blank),
                    title: Text("タスクを未実行にする"),
                  ),
                  value: Menu.changeState,
                ),
              ],
            ),
          ],
        ),
      )
    );
//    return SizeTransition(
//      sizeFactor: animation,
//      child: Container(
//        decoration: BoxDecoration(
//          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
//        ),
//        child: CheckboxListTile(
//          activeColor: Theme.of(context).primaryColor,
////
////          title: TextFormField(
////            decoration: InputDecoration(
////              enabledBorder: InputBorder.none,
////            ),
////            initialValue: taskName,
////            onChanged: (text){
////              if(text != ""){
////                _changeState(id, taskName, false, date==null ? null : DateTime.parse(date));
////              }
////            },
////          ),
//          //title: Text(taskName),
//          title: GestureDetector(
//            child: Text(taskName),
//            onTap: (){},
//          ),
//          subtitle: date == null ? null : Text(date),
//          secondary: PopupMenuButton(
//            onSelected: (menu){_popupMenuSelected(menu,index, id, taskName, false, date==null?null:DateTime.parse(date));},
//            itemBuilder: (BuildContext context)=>
//            <PopupMenuEntry<Menu>>[
//              const PopupMenuItem(
//                child: ListTile(
//                  leading: Icon(Icons.delete),
//                  title: Text("削除"),
//                ),
//                value: Menu.deleteTodo,
//              ),
//              flg == 0 ?
//              const PopupMenuItem(
//                child: ListTile(
//                  leading: Icon(Icons.access_time),
//                  title: Text("日時の編集"),
//                ),
//                value: Menu.changeDate,
//              ):
//              const PopupMenuItem(
//                child: ListTile(
//                  leading: Icon(Icons.check_box_outline_blank),
//                  title: Text("タスクを未実行にする"),
//                ),
//                value: Menu.changeState,
//              ),
//            ],
//          ),
//          controlAffinity: ListTileControlAffinity.leading,
//          value: flg == 0 ? false : true,
//          onChanged: (bool value){
//            setState(() {
//              _changeState(id, taskName, true, date==null?null:DateTime.parse(date));
//            });
//            _falseTasks.remove(index);
//            AnimatedListRemovedItemBuilder builder = (context, animation){
//              return _buildTodoItem(index, id, taskName, date, flg, animation);
//            };
//            _listKey.currentState.removeItem(index, builder);
//            _trueTasks.add(_falseTasks[index]);
//
//          },
//        ),
//      )
//    );
  }

//  Widget _buildTrueTodoItem(int index, int id,String taskName, String date, Animation animation){
//    return SizeTransition(
//        sizeFactor: animation,
//        child: Container(
//          decoration: BoxDecoration(
//            border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
//          ),
//          child: CheckboxListTile(
//            activeColor: Theme.of(context).primaryColor,
//            title: Text(taskName),
//            subtitle: date == null ? null : Text(date),
//            secondary: PopupMenuButton(
//              onSelected: (menu){_popupMenuSelected(menu,index, id, taskName, true, date==null?null:DateTime.parse(date));},
//              itemBuilder: (BuildContext context)=>
//              <PopupMenuEntry<Menu>>[
//                const PopupMenuItem(
//                  child: ListTile(
//                    leading: Icon(Icons.delete),
//                    title: Text("削除"),
//                  ),
//                  value: Menu.deleteTodo,
//                ),
//                const PopupMenuItem(
//                  child: ListTile(
//                    leading: Icon(Icons.check_box_outline_blank),
//                    title: Text("タスクを未実行にする"),
//                  ),
//                  value: Menu.changeState,
//                ),
//              ],
//            ),
//            controlAffinity: ListTileControlAffinity.leading,
//            value: true,
//          ),
//        )
//    );
//  }

  Widget _buildAddText(){
    return GestureDetector(
      child:RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: EdgeInsets.only(left: 3.0),
                  child: Icon(Icons.add, color: Theme.of(context).accentColor, size: 15.0,),
                ),
              ),
              TextSpan(
                text: "タスクを追加",
                style: TextStyle(color: Theme.of(context).accentColor),
              )
            ]
        ),
      ),
      onTap: _addDialog,
    );
  }

//  Widget _buildTrueTaskText(){
////    return GestureDetector(
////      child:RichText(
////        textAlign: TextAlign.left,
////        text: TextSpan(
////            children: [
////              WidgetSpan(
////                child: Padding(
////                  padding: EdgeInsets.only(left: 3.0),
////                  child: Icon(Icons.check, color: Colors.grey, size: 15.0,),
////                ),
////              ),
////              TextSpan(
////                text: showTodo ? "完了したタスクを非表示にする" :"完了したタスクを表示する",
////                style: TextStyle(color: Colors.grey),
////              )
////            ]
////        ),
////      ),
////      onTap: (){
////        setState(() {
////          showTodo = showTodo ? false : true;
////        });
////      },
////    );
////  }

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
//                  onChanged: (value){
//                    hasInputError = value.length <= 20;
//                    setState(() {
//                      _taskNameController.text = value;
//                    });
//                  },
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
                _addTodo(_taskNameController.text, null);
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }
}

