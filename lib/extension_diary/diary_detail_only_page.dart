import 'package:flutter/material.dart';
import 'package:scheduleapp/network_utils/api.dart';

class DiaryDetailOnlyPage extends StatelessWidget {
  var diaryData;
//  var index;
  DiaryDetailOnlyPage(diaryDate,index){
    this.diaryData = diaryDate[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle:true,
        title: Text(diaryData["date"]),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      diaryData["article"],
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(15),
              child: diaryData["image_path"] != null
                  ? Image.network(Network().imagesDirectory('diary_images') + diaryData["image_path"])
                  : Container(),
            )
          ],
        ),
      ),
    );
  }
}
