import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:scheduleapp/main.dart';
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

  var errorMessages = "";

  var isObscureText = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('新規登録'),
      ),
      body: SingleChildScrollView(
        child: Center(
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
                            if(validateEmail(emailValue)){
                              return '無効なメールアドレスです';
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
                          obscureText: !isObscureText,
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
                      Container(
                        margin: EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          obscureText: !isObscureText,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key),
                              hintText: 'パスワード再入力'
                          ),
                          validator: (passwordSecondValue){
                            if(passwordSecondValue.isEmpty){
                              if(password == ''){
                                return 'パスワードを再入力してください';
                              }
                              return 'パスワードを入力してください';
                            }
                            if(passwordSecondValue != password){
                              return '入力されたパスワードが一致しましせん';
                            }
                            return null;
                          },
                        ),
                      ),
                      InkWell(
                        onTap: changedIsObscureText,
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: isObscureText,
//                              onChanged: changedIsObscureText,
                            ),
                            Text("パスワードを表示する",style: TextStyle(fontSize: 15),)
                          ],
                        ),
                      ),
                      Container(
                        child: Text(
                          errorMessages,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: FlatButton(
                          padding: EdgeInsets.only(top: 5,bottom: 5,left: 20,right: 20),
                          color: Theme.of(context).primaryColor,
                          child: Text(
                            '登録する',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0
                            ),
                          ),
                          onPressed: (){
                            setState(() {
                              errorMessages = "";
                            });
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
      ),
    );
  }


//  メールアドレスのバリデーション
  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    return (regex.hasMatch(value)) ? false : true;
  }

  _register() async{
    errorMessages = "";
    var data = {
      'email' : email,
      'name' : name,
      'password': password,
    };

    var res = await Network().authData(data, 'register');
    var body = json.decode(res.body);

    if(body['success']){
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      localStorage.setString('calendar',json.encode(body['calendar']));

      Navigator.of(context).pop();
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => MyHomePage(title: '2020年',)
      ));

    }else{
      //登録失敗（バリデーションエラー）
      Map<String,dynamic> messages = body["message"];
      var tmp;
      var message;
      for(String key in messages.keys){
        tmp = messages[key].toString();
        message = tmp.substring(1,tmp.length - 1);
        setState(() {
          errorMessages += (message + '\n');
        });

      }
    }

  }

  void changedIsObscureText() {
    setState(() {
      isObscureText = !isObscureText;
    });
  }
}
