import 'package:flutter/material.dart';
import 'package:yunLife/clendar/clendarPage.dart';
import 'package:yunLife/login/loadPage.dart';
import 'package:yunLife/login/loginPage.dart';
import 'package:yunLife/map/mapPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: mapPage(),
    );
  }
}
