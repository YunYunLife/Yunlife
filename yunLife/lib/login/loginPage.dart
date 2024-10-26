import 'package:flutter/material.dart';
import 'package:yunLife/home.dart';
import 'package:yunLife/login/login.dart';
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
          'Yunlife',
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    // 调用验证函数
                    bool isValid = await verifyUserCredentials(
                        inputUsername, inputPassword);

                    if (isValid) {
                      globalUsername = inputUsername;
                      // 验证成功，跳转到主页
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } else {
                      // 验证失败，显示错误信息
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('帳號或密碼錯誤')),
                      );
                    }
                  },
                  child: _button('登入', true),
                ),
                const SizedBox(width: 60),
                GestureDetector(
                  onTap: () {
                    // 清空输入的账号和密码
                    setState(() {
                      inputUsername = '';
                      inputPassword = '';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已登出')),
                    );
                  },
                  child: _button('登出', false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _button(String label, bool isPrimary) {
    Color buttonColor = isPrimary ? Colors.blue : Colors.grey;
    return Container(
      height: 30,
      width: 100,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
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
}
