import 'package:flutter/material.dart';

class DiaryDetailPage extends StatelessWidget {
  DiaryDetailPage({ this.diaryData });
  final diaryData;
  @override
  Widget build(BuildContext context) {
    print(diaryData["date"]);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(diaryData["date"]),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: (){},
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: (){},
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Text(
          diaryData["article"],
          style: TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
