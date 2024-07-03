// ignore_for_file: prefer_const_constructors
import 'package:firts_app/widgets/loading_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_theme.dart';
//Providers
import '../providers/auth.dart';

class AboutScreen extends StatefulWidget {
  static const routeName = '/about-screen';

  const AboutScreen({Key? key}) : super(key: key);

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _AboutFormKey = GlobalKey<FormState>();
  final TransactionTheme transTheme =
      TransactionTheme(color: Colors.indigo, title: 'About');

  bool _getData = false;
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> getAppInfo() async {
    while (appName == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      // ignore: prefer_if_null_operators
      buildNumber = packageInfo.buildNumber.toString() != null
          ? packageInfo.buildNumber.toString()
          : '1';
    }
    _getData = true;
    return _getData;
  }

  @override
  Widget build(BuildContext context) {
    final _scrennWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: transTheme.color,
            title: Text(
              transTheme.title,
              style: Theme.of(context).textTheme.headline3,
            )),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _AboutFormKey,
              child: FutureBuilder(
                  future: getAppInfo(),
                  builder: (context, snapshot) {
                    return _getData
                        ? ListView(
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Text('Application:'),
                                    Text(appName!)
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Text('Package:'),
                                    Text(packageName!)
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Text('Version:'),
                                    Text(version!)
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    const Text('BuildNumber:'),
                                    Text(buildNumber!)
                                  ],
                                ),
                              ),
                              const Center(
                                  child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('Powered By Mitra Inti Solusindo'),
                              ))
                            ],
                          )
                        : Container(
                            child: Center(
                                child: LoadingIndicator(desc: 'Loading')));
                  }),
            ),
          ),
        ));
  }
}
