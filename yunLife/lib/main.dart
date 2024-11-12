import 'package:flutter/material.dart';

import 'package:yunLife/Page/clendar/clendarPage.dart';
import 'package:yunLife/Page/club/clubPage.dart';
import 'package:yunLife/Page/login/loadPage.dart';
import 'package:yunLife/Page/login/loginPage.dart';
import 'package:yunLife/Page/map/mapPage.dart';
import 'package:yunLife/home.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
