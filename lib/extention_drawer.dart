import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scheduleapp/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'extension_add_page.dart';

class ExtensionDrawer extends StatefulWidget {
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
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 10,bottom: 5),
          child: Text('$name  さん',style: TextStyle(fontSize: 20),),
        ),
        ExtensionListView(),
        authButton(),
      ],
    );
  }

//  認証済判定
//  未認証なら「ログイン会員登録」ボタン表示
  Widget authButton(){
    var _token = _getPrefItems();

    print("token");
    print(_token);
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
  @override
  _ExtensionListViewState createState() => _ExtensionListViewState();
}

class _ExtensionListViewState extends State<ExtensionListView> {
  List extensions = new List();
  var token;
  bool extensionFlag = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  Future<bool> _getData() async {
//    ローカルストレージに保存している認証トークンを取り出している
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];

//    HTTPリクエストのヘッダー部分
//    トークンをセットしている
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': "Bearer $token"
    };

    final String url = "http://10.0.2.2:8000/api/extension/addlist";
    http.Response response = await http.get(
        url,
        headers: requestHeaders
    );

    extensions = jsonDecode(response.body);

    extensions.forEach((element) {
      if(!element["flag"]){
        extensionFlag = false;
      }
    });

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
              return extensions == null ? Container() : Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index){
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[50],
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            bottom: BorderSide(color: Colors.grey)
                          )
                        ),
                        child: ListTile(
                          title: Text(
                            extensions[index]["ex_name"],
                            style: TextStyle(fontSize: 20),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: (){},
                        ),
                      );
                    },
                    itemCount: extensions.length,
                ),
              );
            }else{
              //現在のカレンダーに拡張機能が入っていない場合の表示
              return NoExtension(context);
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
Widget NoExtension(BuildContext context){
        return Padding(
          padding: const EdgeInsets.only(top: 100,bottom: 100),
          child: Container(
            child:Center(
              child: Column(
                children: <Widget>[
                  Text('拡張機能が追加されていません'),
                  FlatButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {
                      moveExtentionAddPage(context);
                    },
                    child: Text(
                      "拡張機能を追加する",
                      style: TextStyle(fontSize: 15.0),
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




