import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scheduleapp/auth/register.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ログイン'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: 'メールアドレス'
                        ),
                        validator: (emailValue){
                          if(emailValue.isEmpty){
                            return 'メールアドレスを入力してください';
                          }
                          email = emailValue;
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.vpn_key),
                            hintText: 'パスワード'
                        ),
                        validator: (passwordValue){
                          if(passwordValue.isEmpty){
                            return 'パスワードを入力してください';
                          }
                          password = passwordValue;
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: FlatButton(
                          padding: EdgeInsets.only(top: 5,bottom: 5,left: 20,right: 20),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                              'ログイン',
                              style: TextStyle(
                                  color: Colors.white,
                                fontSize: 20.0
                              ),
                          ),
                          onPressed: (){
                            if(_formKey.currentState.validate()){
                              _login();
                            }
                          },
                      ),
                    ),
                    FlatButton(
                      child: Text('新規会員登録はこちら'),
                      onPressed: (){
                        moveRegisterForm(context);
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// ログイン
  _login() async{
    var data = {
      'email' : email,
      'password' : password
    };

    var res = await Network().postData(data, 'login');
    var body = json.decode(res.body);
    print(body);

    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      Navigator.of(context).pop();
      debugPrint('ログイン成功ecc');
//
//      Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) => Home()
//        ),
//      );
    }else{
      debugPrint('ログイン失敗');
    }
  }
}

//新規登録ページへ移動
moveRegisterForm(BuildContext context){
  Navigator.of(context).pop();
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return RegisterForm();
      },
    ),
  );
}


