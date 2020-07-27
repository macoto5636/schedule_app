import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scheduleapp/network_utils/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  var email;
  var name;
  var password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新規登録'),
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
                            prefixIcon: Icon(Icons.people),
                            hintText: '名前'
                        ),
                        validator: (nameValue){
                          if(nameValue.isEmpty){
                            return '名前を入力してください';
                          }
                          name = nameValue;
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
                          '登録',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0
                          ),
                        ),
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            _register();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _register()async{
    var data = {
      'email' : email,
      'name' : name,
      'password': password,
    };

    var res = await Network().postData(data, 'register');
    var body = json.decode(res.body);
    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
//      Navigator.push(
//        context,
//        new MaterialPageRoute(
//            builder: (context) => Home()
//        ),
//      );
      debugPrint('登録成功');
    }

  }
}
