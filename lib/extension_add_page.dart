import 'package:flutter/material.dart';

class ExtentionAddPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  //拡張機能の情報(id,ex_name)を取得する
  var listItems = ["日記","タスク管理","シフト管理"]; //ダミー

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(listItems[index]),
              subtitle: Text("拡張機能の説明です。"),
              trailing: IconButton(
                  icon: Icon(Icons.add),
                  iconSize: 40.0,
                  onPressed: (){ extentionAdd(index); }
              ),
            );
          },
        itemCount: listItems.length,
      ),
    );
  }

  void extentionAdd(int index) {
    debugPrint("index : $index");
  }
}
