import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scheduleapp/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'extension_todo/todo_main_page.dart';
import 'app_theme.dart';
import 'extension_add_page.dart';
import 'extension_diary/diary_main_page.dart';
import 'network_utils/api.dart';

class ExtensionDrawer extends StatefulWidget {
  Function callback;
  ExtensionDrawer({ this.callback });
  @override
  _ExtensionDrawerState createState() => _ExtensionDrawerState();
}

class _ExtensionDrawerState extends State<ExtensionDrawer> {
  String name;

  @override
  void initState(){
    super.initState();
    _loadUserData();
  }

  _loadUserData() async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));
    print(user);
    if(user != null) {
      setState(() {
        name = user['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          height: 80.0,
          color: getPrimaryColor(context),
          child: DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '拡張機能',
                    style: TextStyle(
                        fontSize: 25.0,
                        color:Colors.white
                    ),
                ),
                IconButton(
                    icon: Icon(Icons.add,color: Colors.white,),
                    iconSize: 35.0,
                    onPressed: (){ moveExtentionAddPage(context); },
                  ),
              ],
            ),
            decoration: BoxDecoration(
//              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10,top: 5,bottom: 5),
          child: Text('$name  さん',style: TextStyle(fontSize: 20),),
        ),
        Divider(
          color: Colors.grey[500],
        ),
        ExtensionListView(callback: widget.callback,),
        authButton(),
      ],
    );
  }

//  認証済判定
//  未認証なら「ログイン会員登録」ボタン表示
//  ログインしていないとアプリは使えないので不必要
  Widget authButton(){
    var _token = _getPrefItems();

    if(_token == ""){
      return ListTile(
        leading: Icon(Icons.group),
        title: Text('ログイン / 会員登録'),
        onTap: (){
          moveLoginForm((context));
        },
      );
    }else{
      return Container();
    }
  }
}

_getPrefItems() async {
  var _token = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _token = jsonDecode(prefs.getString('token'))['token'] ?? "";
  return _token;
}

//drawerの中身
class ExtensionListView extends StatefulWidget {
  Function callback;
  ExtensionListView({ this.callback });
  @override
  _ExtensionListViewState createState() => _ExtensionListViewState();
}

class _ExtensionListViewState extends State<ExtensionListView> {
  List extensions;
  List haveExtensions = [];
  var token;
  var calendarId;
  //bool extensionFlag = true;
  bool extensionFlag = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<bool> _getData() async {
//    ローカルストレージに保存している認証トークンを取り出している
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
    calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    http.Response res = await Network().getData("extension/addlist/$calendarId");

    extensions = jsonDecode(res.body);

//    extensions.forEach((element) {
//      if(!element["flag"]){
//        extensionFlag = false;
//      }
//    });
    haveExtensions.clear();

    extensions.forEach((element) {
      if(element["flag"]){
        extensionFlag = true;
      }

      if(element["flag"]){
        haveExtensions.add(element);
      }
    });

    print(haveExtensions);

    return extensionFlag;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data){
              //現在のカレンダーに拡張機能が一つでも入っている場合の表示
              return haveExtensions == null ? Container() : Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index){
                      return Column(
                        children: [
                          Container(
                            child: ListTile(
                              title: Text(
                                haveExtensions[index]["ex_name"],
                                style: TextStyle(fontSize: 20),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios),
                              onTap: (){
                                moveExtensionSubPages(context,haveExtensions[index]["id"],widget.callback);
                              },
                            ),
                          ),
                          Divider(
                            color: Colors.grey[500],
                          ),
                        ],
                      );
                    },
                    itemCount: haveExtensions.length,
                ),
              );
            }else{
              //現在のカレンダーに拡張機能が入っていない場合の表示
              return noExtensionView(context);
            }
          } else {
            //処理待ち
            return Center(
                child: CircularProgressIndicator()
            );
          }
        },
      ),
    );
    }
}

//拡張機能なし画面
Widget noExtensionView(BuildContext context){
  return Padding(
    padding: const EdgeInsets.only(top: 100,bottom: 100),
    child: Container(
      child:Center(
        child: Column(
          children: <Widget>[
            Text('拡張機能が追加されていません'),
            Container(
              margin: EdgeInsets.only(top: 8.0),
              child: FlatButton(
                color: getPrimaryColor(context),
                textColor: Colors.white,
                padding: EdgeInsets.all(16.0),
                onPressed: () {
                  moveExtentionAddPage(context);
                  },
                child: Text(
                  "拡張機能を追加する",
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

//拡張機能追加ページへ移動
moveExtentionAddPage(BuildContext context){
  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return ExtensionAddPage();
      },
    ),
  );
}

//ログインページへ移動
moveLoginForm(BuildContext context){
  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return LoginForm();
      },
    ),
  );
}

//拡張機能のページ（機能ページ）へ移動
void moveExtensionSubPages(BuildContext context,int id,callback) async{
  switch(id){
    case 1 : await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context){
          return DiaryMainPage();
        },
      )
    );
      callback(true); break;
    case 2 : await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context){
            return TodoMainPage();
          },
        )
    );
      callback(true);
      break;
  }
}




