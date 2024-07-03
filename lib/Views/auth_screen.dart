import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Views/menu_screen.dart';
//Providers
import '../providers/auth.dart';
import '../models/http_exceptions.dart';
import '../widgets/loading_indicator.dart';
import '../providers/qc_status.dart';
import '../providers/qc_reasoncode.dart';
import '../providers/rwsta.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  var _loginDetails = {"userId": "", "password": ""};
  bool _isLoading = false;
  String _currentProgress = 'Loading';
  bool _lock = true;

  @override
  void dispose() {
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error occured'),
              content: Text(message),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Ok'))
              ],
            ));
  }

  Future<void> _login() async {
    _loginFormKey.currentState?.save();
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _currentProgress = 'Authenticating';
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .login(_loginDetails["userId"]!, _loginDetails["password"]!);
      await Provider.of<QCStatuss>(context, listen: false).loadQCStatus();
      await Provider.of<QCReasonCodes>(context, listen: false)
          .loadqcReasonCode();
      await Provider.of<RwStas>(context, listen: false).loadRwSta();

      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pushReplacementNamed(MenuScreen.routeName);
    } on HttpExceptions catch (err) {
      var errorMessage = 'Invalid Credentials';
      errorMessage = err.toString();
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(errorMessage);
    } catch (err) {
      var errorMessage = "Unable authenticate $err";
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _scrennWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: _isLoading
              ? Center(child: LoadingIndicator(desc: _currentProgress))
              : Form(
                  autovalidateMode: AutovalidateMode.always,
                  key: _loginFormKey,
                  child: ListView(
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Skanər',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Icon(
                        Icons.document_scanner,
                        size: _scrennWidth / 10,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          decoration: InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value == '') {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null) {
                              _loginDetails["userId"] = value;
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          obscureText: _lock,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _lock = _lock == true ? false : true;
                                    });
                                  },
                                  icon: Icon(_lock == true
                                      ? Icons.lock_open
                                      : Icons.lock))),
                          validator: (value) {
                            if (value == null || value == '') {
                              return 'Please enter your Password';
                            }
                            if (value.length < 8) {
                              return 'Invalid Password';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value != null) {
                              _loginDetails["password"] = value;
                            }
                          },
                        ),
                      ),
                      Container(
                        height: _scrennWidth / 8,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _login();
                          },
                          child: Text('Login'),
                          style: ElevatedButton.styleFrom(),
                        ),
                      ),
                      Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Powered By Mitra Inti Solusindo'),
                      ))
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
