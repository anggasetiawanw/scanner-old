import 'package:firts_app/Views/auth_screen.dart';
import 'package:firts_app/providers/cart.dart';
import 'package:flutter/material.dart';
//Screens
import '../Views/menu_screen.dart';
import '../Views/account_screen.dart';
import '../Views/about_screen.dart';
import '../providers/auth.dart';
import 'package:provider/provider.dart';
import '../providers/qc_status.dart';
import '../providers/qc_reasoncode.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.of(context).popAndPushNamed(MenuScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Account'),
            onTap: () {
              Navigator.of(context).pushNamed(AccountScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('About'),
            trailing: Text('MIS'),
            onTap: () {
              Navigator.of(context).pushNamed(AboutScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Provider.of<QCStatuss>(context, listen: false).clear();
              Provider.of<QCReasonCodes>(context, listen: false).clear();
              Provider.of<Cart>(context, listen: false).clear();
              Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  AuthScreen.routeName, (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }
}
