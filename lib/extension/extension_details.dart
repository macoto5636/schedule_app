import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ExtensionDetailsPage extends StatelessWidget {
  final details;
  var token;

  ExtensionDetailsPage({Key key, this.details}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("詳細"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                          Icons.extension,
                        size: 35,
                      ),
                      Text(
                        details["ex_name"],
                        style: TextStyle(fontSize: 35),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        child: details["flag"] ? Center(child: Text("追加済み"))
                            : RaisedButton(
                          child: Text(
                            "追加",
                            style: TextStyle(color: Colors.white,fontSize: 20),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                            extensionAdd(details["id"]);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "「${details["ex_name"]}」を追加しました",
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
//            Container(
//              margin: EdgeInsets.only(top: 20),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Container(
//                      child: Text("カテゴリ： *******")
//                  ),
//                ],
//              ),
//            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20),
                    child: Text(
                        details["explanation"],
                        style: TextStyle(fontSize: 20),
                    )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void extensionAdd (int id) async{
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

    final json = jsonEncode(<String,String>{
      "calendar_id" : calendarId.toString(),
      "extension_id" : id.toString()
    });
    postData(json);
  }

  Future postData(json) async{
    final _url = "http://${DotEnv().env['API_ADDRESS']}/api/extension/calexadd";

//     ローカルストレージに保存している認証トークンを取り出している
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];

//    HTTPリクエストのヘッダー部分
//    トークンをセットしている
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': "Bearer $token"
    };

    http.Response response = await http.post(
        _url,
        headers: requestHeaders,
        body: json
    );
  }

  //拡張機能を追加済みなら「追加済み」、追加していないなら追加ボタンを表示
  Widget ExtensionButton(list){

  }
}
