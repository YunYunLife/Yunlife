import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:yunLife/home.dart';
import 'package:yunLife/Page/login/login.dart';
import 'package:yunLife/global.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String inputUsername = '';
  String inputPassword = '';

  String get getInputUsername => inputUsername;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'YunLife',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loginBody(context),
    );
  }

  Container loginBody(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 400,
            child: Image.asset('asst/images/home.gif'),
          ),
          _textbox('請輸入帳號', false, (value) {
            setState(() {
              inputUsername = value;
            });
          }),
          const SizedBox(height: 30),
          _textbox('請輸入密碼', true, (value) {
            setState(() {
              inputPassword = value;
            });
          }),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              await handleLogin(context, inputUsername, inputPassword);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size(200, 20),
            ),
            child: Text(
              "登入",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    ));
  }

//登入處理
  Future<void> handleLogin(
      BuildContext context, String inputUsername, String inputPassword) async {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('登入中！請耐心等候...')),
    );

    // 调用验证函数
    bool isValid = await verifyUserCredentials(inputUsername, inputPassword);

    if (isValid) {
      globalUsername = inputUsername;
      // 验证成功，跳转到主页
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入成功')),
      );
    } else {
      // 验证失败，显示错误信息
      Future.delayed(Duration(milliseconds: 500), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('帳號或密碼錯誤')));
      });
    }
    ;
  }
}

Container _textbox(String hint, bool isPassword, Function(String) onChanged) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      obscureText: isPassword, // 如果是密码，设置为密文输入
      onChanged: onChanged, // 捕获输入并更新变量
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        filled: true,
      ),
    ),
  );
}

void showRepeatedSnackBar(BuildContext context) {
  Timer.periodic(Duration(seconds: 3), (timer) {
    // 每 3 秒显示一个 SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('登入中！請稍後...')),
    );
  });
}
