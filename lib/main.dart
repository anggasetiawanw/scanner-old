// ignore_for_file: prefer_const_constructors

import 'package:firts_app/Views/about_screen.dart';
import 'package:firts_app/Views/account_screen.dart';
import 'package:firts_app/Views/screen_scanfg.dart';
//import 'package:firts_app/Views/scanfgscreen.dart';
import 'package:firts_app/Views/screen_qc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//Screens
import '../Views/auth_screen.dart';
import '../Views/menu_screen.dart';

//Providers
import 'providers/auth.dart';
import '../providers/cart.dart';
import '../providers/qc_status.dart';
import '../providers/qc_reasoncode.dart';
import '../providers/rwsta.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (ctx) => Auth()),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, QCStatuss>(
              create: (ctx) => QCStatuss('', []),
              update: (ctx, auth, prevqcStatuss) => QCStatuss(auth.token,
                  prevqcStatuss == null ? [] : prevqcStatuss.qcStatus)),
          ChangeNotifierProxyProvider<Auth, QCReasonCodes>(
              create: (ctx) => QCReasonCodes('', []),
              update: (ctx, auth, prevqcReasonCodes) => QCReasonCodes(
                  auth.token,
                  prevqcReasonCodes == null
                      ? []
                      : prevqcReasonCodes.qcReasonCode)),
          ChangeNotifierProxyProvider<Auth, RwStas>(
              create: (ctx) => RwStas('', []),
              update: (ctx, auth, prevqcStatuss) => RwStas(
                  auth.token, prevqcStatuss == null ? [] : prevqcStatuss.rwSta))
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Glass Barcode Scanner',
            theme: ThemeData(
                primaryColor: Colors.blue,
                accentColor: Colors.redAccent,
                fontFamily: 'Roboto',
                textTheme: ThemeData.light().textTheme.copyWith(
                    headline1: const TextStyle(
                        fontSize: 25,
                        fontFamily: 'Questrial',
                        color: Colors.black),
                    headline2: TextStyle(
                      fontSize: 20,
                      fontFamily: 'OpenSans',
                      color: Colors.black,
                    ),
                    headline3: TextStyle(
                      fontSize: 20,
                      fontFamily: 'OpenSans',
                      color: Colors.white,
                    ))),
            home: auth.isAuth ? MenuScreen() : AuthScreen(),
            routes: {
              AuthScreen.routeName: (ctx) => AuthScreen(),
              MenuScreen.routeName: (ctx) => MenuScreen(),
              ScanFGScreen.routeName: (ctx) => const ScanFGScreen(),
              QCScreen.routeName: (ctx) => const QCScreen(),
              AboutScreen.routeName: (ctx) => const AboutScreen(),
              AccountScreen.routeName: (ctx) => const AccountScreen()
            },
          ),
        ));
  }
}
