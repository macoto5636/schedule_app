import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scheduleapp/auth/login.dart';
import 'package:scheduleapp/auth/register.dart';
import 'package:scheduleapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _moveFirstPages();
  }

  _moveFirstPages() async{
    Future.delayed(Duration(seconds: 3));
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var _token = localStorage.getString('user');

    if(_token == null){
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => FirstBootPage()
      ));
    }else{
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => MyHomePage()
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset('images/flutter-logo.png')
        ),
      )
    );
  }
}


class FirstBootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
           Container(
              padding: EdgeInsets.all(60),
               child: Image.asset('images/flutter-logo.png')
           ),
            Text(
              "カレンダー＋",
              style: TextStyle(fontSize: 30,color: Colors.blue),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: SizedBox(
                width: 300,
                child: RaisedButton(
                  padding: EdgeInsets.only(top: 10,bottom: 10),
                  child: Text(
                      "ログイン",
                      style: TextStyle(fontSize: 20,color: Colors.white),
                  ),
                  color: Colors.blue,
                  shape: StadiumBorder(),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LoginForm()
                    ));
                  },
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: SizedBox(
                width: 300,
                child: RaisedButton(
                  padding: EdgeInsets.only(top: 10,bottom: 10),
                  child: Text(
                    "会員登録",
                    style: TextStyle(fontSize: 20,color: Colors.white),
                  ),
                  color: Colors.blue,
                  shape: StadiumBorder(),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => RegisterForm()
                    ));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
