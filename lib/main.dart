import 'package:flutter/material.dart';

import 'package:yunlife/Page/clendar/clendarPage.dart';
import 'package:yunlife/Page/club/clubPage.dart';
import 'package:yunlife/Page/login/loadPage.dart';
import 'package:yunlife/Page/login/loginPage.dart';
import 'package:yunlife/Page/map/mapPage.dart';
import 'package:yunlife/Page/robot/homeRobotPage.dart';
import 'package:yunlife/home.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoadPage(),
    );
  }
}
