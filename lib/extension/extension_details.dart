import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExtensionDetailsPage extends StatelessWidget {
  final details;
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
                        child: RaisedButton(
                          child: Text(
                              "追加",
                              style: TextStyle(color: Colors.white,fontSize: 20),
                          ),
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Fluttertoast.showToast(
                              msg: "「${details["ex_name"]}」を追加しました",
                              backgroundColor: Colors.blue,
                              textColor: Colors.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      child: Text("カテゴリ： *******")
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                    child: Text(details["explanation"])
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  //拡張機能を追加済みなら「追加済み」、追加していないなら追加ボタンを表示
  Widget ExtensionButton(list){

  }
}
