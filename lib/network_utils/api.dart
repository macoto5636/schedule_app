import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Network{
// アンドロイドエミュレーターの場合10.0.2.2:8000を使用
  final String _url = 'http://10.0.2.2:8000/api/';

  static var token;

  Future<void> _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = jsonDecode(localStorage.getString('token'))['token'];
  }

  //認証用
  authData(data,apiUrl) async{
    var fullUrl = _url + apiUrl;
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  //POST（データ保存用）
  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    print(data);
    print(fullUrl);
    return await http.post(
        fullUrl,
        body: jsonEncode(data),
        headers: _setHeaders()
    );
  }

  //GET（データ取得用）
  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    await _getToken();
    print(fullUrl);
    return await http.get(
        fullUrl,
        headers: _setHeaders()
    );
  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
    'Authorization' : 'Bearer $token'
  };

}