import 'package:firts_app/Views/screen_scanfg.dart';
//import 'package:firts_app/Views/scanfgscreen.dart';
import 'package:firts_app/Views/screen_qc.dart';
import 'package:firts_app/providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//Providers
import '../providers/auth.dart';
//Widget
import '../widgets/card_button.dart';
import '../widgets/app_drawer.dart';
//Screen

class MenuScreen extends StatelessWidget {
  static const routeName = '/menu-screen';
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  MenuScreen({Key? key}) : super(key: key);

  String getFirstName(String fullName) {
    List<String> names = [];
    fullName.split(' ').forEach((namePart) {
      names.add(namePart);
    });
    return names[0];
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<Auth>(context).username;
    final _screenHeight = MediaQuery.of(context).size.height;
    final _iconSize = _screenHeight / 14;
    return Scaffold(
      key: _drawerKey,
      drawer: AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: _screenHeight / 30,
                    child: IconButton(
                      icon: Icon(Icons.menu),
                      onPressed: () {
                        _drawerKey.currentState!.openDrawer();
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Hi, ${getFirstName(username!)}',
                    style: Theme.of(context).textTheme.headline1,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: _screenHeight / 8,
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: CardButton(
                  title: 'Scan FG',
                  image: IconButton(
                    icon: Icon(Icons.scanner),
                    iconSize: _iconSize,
                    color: Colors.pink,
                    onPressed: () {
                      Navigator.of(context).pushNamed(ScanFGScreen.routeName);
                    },
                  ),
                  action: () {
                    Navigator.of(context).pushNamed(ScanFGScreen.routeName);
                  }),
            ),
            Container(
              height: _screenHeight / 8,
              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: CardButton(
                  title: 'QC',
                  image: IconButton(
                    icon: Icon(Icons.check),
                    iconSize: _iconSize,
                    color: Colors.pink,
                    onPressed: () {
                      Navigator.of(context).pushNamed(QCScreen.routeName);
                    },
                  ),
                  action: () {
                    Navigator.of(context).pushNamed(QCScreen.routeName);
                  }),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Text('Powered By Mitra Inti Solusindo'))
          ],
        ),
      ),
    );
  }
}
