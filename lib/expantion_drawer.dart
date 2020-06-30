import 'package:flutter/material.dart';

class ExpantionDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: <Widget>[
          Container(
            height: 80,
            child: DrawerHeader(
              child: Text('拡張機能',style: TextStyle(fontSize: 25),),
              decoration: BoxDecoration(
                color: Colors.black12,
              ),
            ),
          ),
          Container(
            child: Sample(),
          ),
        ],
      ),
    );
  }
}

class Sample extends StatelessWidget {
  final bool flag = true;
  @override

  Widget build(BuildContext context) {
    //拡張機能の有無判定
    if(flag){
      return Container(child: Text('拡張機能入ってるよ'));
    }else{
      return Container(child: Text('何も拡張機能がないよ'));
    }
  }
}


