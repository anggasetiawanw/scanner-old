import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils.dart';
import '../models/http_exceptions.dart';
import 'package:http/io_client.dart' as ioClient;
import 'package:package_info_plus/package_info_plus.dart';

class Auth with ChangeNotifier {
  String? _token = "";
  // DateTime? _expiryDate;
  String? _username = "";
  String? _userId = "";
  String? _routeID = "";
  Map<String, String> cookies = {};
  String? _appName = "";
  String? _packageName = "";
  String? _version = "";
  String? _buildNumber = "";
  bool _getData = false;

  //Determines if the user is loggedIn
  bool get isAuth {
    return token != '';
  }

  String? get username {
    return _username;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    // if (_expiryDate != null) {
    //   if (_expiryDate!.isAfter(DateTime.now()) && _token != null) {
    return _token;
    //   }
    // }
    // return '';
  }

  String get routeID {
    return _routeID!;
  }

  String? get appName {
    return _appName;
  }

  String? get packageName {
    return _packageName;
  }

  String? get version {
    return _version;
  }

  String? get buildNumber {
    return _buildNumber;
  }

  Future<bool> getAppInfo() async {
    while (appName == "") {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _version = packageInfo.version;
      // ignore: prefer_if_null_operators
      _buildNumber = packageInfo.buildNumber.toString() != null
          ? packageInfo.buildNumber.toString()
          : '1';
    }
    _getData = true;
    return _getData;
  }

  void _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];
    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');
      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');
        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];
        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;
        this.cookies[key] = value;
      }
    }
  }

  // //Authenticate BudiN SL
  // Future<void> _authenticate(String userId, String password) async {
  //   final url = Uri.parse('${Utils.apiBase}/b1s/v1/Login');
  //   SecurityContext sslcontext = SecurityContext.defaultContext;
  //   HttpClient client = HttpClient(context: sslcontext);
  //   client.badCertificateCallback =
  //       (X509Certificate cert, String host, int port) => true;
  //   try {
  //     http.Response res = await ioClient.IOClient(client).post(url,
  //         headers: {"Content-Type": "application/json"},
  //         body: json.encode({
  //           "UserName": userId,
  //           "Password": password,
  //           "CompanyDB": "SBO_DDAJ_TEST"
  //         }));

  //     final resData = json.decode(res.body);
  //     client.close();
  //     if (res.statusCode == 200) {
  //       _updateCookie(res);
  //       _token = resData['SessionId'];
  //       _routeID = cookies['ROUTEID'];
  //       _userId = userId;
  //       _username = await _setUsername(_token!, _routeID!);
  //       _expiryDate =
  //           DateTime.now().add(Duration(seconds: resData['SessionTimeout']));
  //     } else {
  //       client.close();
  //       throw new HttpExceptions(message: res.reasonPhrase.toString());
  //     }
  //   } catch (err) {
  //     throw err;
  //   }
  // }

  // //Get username BudiN SL
  // Future<String?> _setUsername(String token, String routeID) async {
  //   String sUrl = '${Utils.apiBase}/b1s/v1/Users?\$filter=UserCode eq \'' +
  //       _userId! +
  //       '\'';
  //   final url = Uri.parse(sUrl);
  //   SecurityContext sslcontext = SecurityContext.defaultContext;
  //   HttpClient client = HttpClient(context: sslcontext);
  //   client.badCertificateCallback =
  //       (X509Certificate cert, String host, int port) => true;
  //   try {
  //     http.Response res = await ioClient.IOClient(client).get(url, headers: {
  //       "Content-Type": "application/json",
  //       "Cookie": "B1SESSION=" + token + "; ROUTEID=" + routeID + ";"
  //     });
  //     final resData = json.decode(res.body);
  //     client.close();
  //     if (res.statusCode != 200) {
  //       throw new HttpExceptions(message: resData['errors'][0]['msg']);
  //     }
  //     return resData["value"][0]['UserName'];
  //   } catch (err) {
  //     client.close();
  //     throw err;
  //   }
  // }

  //Authenticate Felix
  Future<void> _authenticate(String userId, String password) async {
    final url = Uri.parse('${Utils.apiBase}/api/auth');
    try {
      final res = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({"userId": userId, "password": password}));
      final resData = json.decode(res.body);
      //Check for response status code >= 400 means error
      if (res.statusCode >= 400) {
        throw new HttpExceptions(message: resData['errors'][0]['msg']);
      }
      _token = resData['token'];
      // _expiryDate = DateTime.now().add(const Duration(seconds: 36000));
      _userId = userId;
      _username = await _setUsername(_token!);
      while (_getData == false) {
        await getAppInfo();
      }
    } catch (err) {
      throw err;
    }
  }

  //Get username Felix
  Future<String?> _setUsername(String token) async {
    final url = Uri.parse('${Utils.apiBase}/api/user/username');
    try {
      final res = await http.get(url,
          headers: {"Content-Type": "application/json", "x-auth-token": token});
      final resData = json.decode(res.body);
      if (res.statusCode >= 400) {
        throw new HttpExceptions(message: resData['errors'][0]['msg']);
      }
      return resData['U_MIS_USERNM'];
    } catch (err) {
      throw err;
    }
  }

  //LOGIN
  Future<void> login(String userId, String password) async {
    return _authenticate(userId, password);
  }

  //LOGOUT
  void logout() {
    _token = null;
    // _expiryDate = null;
    _userId = null;
    _username = null;
    _routeID = null;
    _appName = null;
    _packageName = null;
    _version = null;
    _buildNumber = null;
    _getData = false;
  }
}
