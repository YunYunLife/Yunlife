
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yunLife/login/login.dart';

class LoadPage extends StatefulWidget {
  const LoadPage({super.key});

  // 添加 LoadPage 类
  @override
  _LoadPageState createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()));
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 200, 213, 180),
      body: Center(child: Center(child: Image.asset('asst/load/load.png')),),
    );
  }
}
