import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scheduleapp/extension/extension_details.dart';


class ExtensionAddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text("拡張機能の追加"),
      ),
      body: Container(
        child: Center(
          child: ExtensionAllList(),
        ),
      ),
    );
  }
}

class ExtensionAllList extends StatefulWidget {
  @override
  _ExtensionAllListState createState() => _ExtensionAllListState();
}

class _ExtensionAllListState extends State<ExtensionAllList> {
  List extensionList;
  var token;
  var calendarId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  Future getData() async{
//    ローカルストレージに保存している認証トークンを取り出している
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
    calendarId = jsonDecode(localStorage.getString('calendar'))['id'];

//    HTTPリクエストのヘッダー部分
//    トークンをセットしている
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': "Bearer $token"
    };

    final String url = "http://${DotEnv().env['API_ADDRESS']}/api/extension/addlist/$calendarId";
    http.Response response = await http.get(
        url,
        headers: requestHeaders
    );

    setState(() {
      extensionList = jsonDecode(response.body);
    });
  }
  
  Widget ExtensionButton(list){
    var _widget;
    bool flag = list["flag"];
    int id = list["id"];


    if(flag){
      _widget = Text("追加済み");
    }else{
      _widget = IconButton(
          icon: Icon(Icons.add),
          iconSize: 40.0,
          onPressed: (){
            moveExtensionDetailsPage(list);
          },
      );
    }
    
    return _widget;
  }

  @override
  Widget build(BuildContext context) {
    return extensionList == null? Container() : Container(
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(extensionList[index]["ex_name"]),
              subtitle: Text(extensionList[index]["explanation"]),
              trailing: ExtensionButton(extensionList[index]),
              onTap: () => moveExtensionDetailsPage(extensionList[index])
            );
          },
        itemCount: extensionList.length,
      ),
    );
  }
  
  moveExtensionDetailsPage(item){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ExtensionDetailsPage(details: item)
        )
    );
  }
}


