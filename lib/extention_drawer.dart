import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'extension_add_page.dart';

class ExpantionDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
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
                      icon: Icon(Icons.add),
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
          ExpantionListView(),
//          ListTile(
//            title: Text("日記"),
//            trailing: Icon(Icons.arrow_forward_ios),
//            onTap: (){ Navigator.pop(context);},
//          )
        ],
      ),
    );
  }

  checkExpantion() {
    return true;
  }
}

//drawerの中身
class ExpantionListView extends StatefulWidget {
  @override
  _ExpantionListViewState createState() => _ExpantionListViewState();
}

class _ExpantionListViewState extends State<ExpantionListView> {
  //拡張機能名と拡張機能を判別するIDが欲しい
  List expantion_items = new List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //拡張機能を有無を判定して表示する
    if(false){
      return Container(
          child: ListView.builder(
            itemCount: expantion_items.length,
            itemBuilder: (context,potision){
              return ListTile(
                title: Text("日記"),
              );
            }
          )
      );
    }else{
      return
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Container(
            child:Center(
              child: Column(
                children: <Widget>[
                  Text('拡張機能が追加されていません'),
                  FlatButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
//                    disabledColor: Colors.grey,
//                    disabledTextColor: Colors.black,
                    padding: EdgeInsets.all(8.0),
//                    splashColor: Colors.blueAccent,
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
  }
}

//拡張機能追加ページへ移動
moveExtentionAddPage(BuildContext context){
  Navigator.of(context).pop();
  Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ExtentionAddPage();
        },
      ),
  );
}

