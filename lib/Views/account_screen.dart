// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_theme.dart';
//Providers
import '../providers/auth.dart';

class AccountScreen extends StatefulWidget {
  static const routeName = '/account-screen';

  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _accountFormKey = GlobalKey<FormState>();
  final TransactionTheme transTheme =
      TransactionTheme(color: Colors.indigo, title: 'Account');

  @override
  void dispose() {
    super.dispose();
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
            key: _accountFormKey,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('UserId:'),
                      Text(Provider.of<Auth>(context).userId.toString())
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text('UserName:'),
                      Text(Provider.of<Auth>(context).username.toString())
                    ],
                  ),
                ),
                const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
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
