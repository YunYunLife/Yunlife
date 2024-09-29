import 'package:flutter/material.dart';
import 'package:yunLife/home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Yunlife',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: login_body(context),
    );
  }

  Container login_body(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 400,
            child: Image.asset('asst/images/home.gif'),
          ),
          _textbox('請輸入帳號'),
          SizedBox(
            height: 30,
          ),
          _textbox('請輸入密碼'),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: _button('登入', true),
              ),
              SizedBox(
                width: 60,
              ),
              GestureDetector(
                onTap: () {},
                child: _button('登出', false),
              ),
            ],
          )
        ],
      ),
    ));
  }

  Container _button(String input, bool choose) {
    Color buttoncolor = Colors.grey;
    if (choose) {
      buttoncolor = Colors.blue;
    }
    return Container(
      height: 30,
      width: 100,
      decoration: BoxDecoration(
        color: buttoncolor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          input,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Container _textbox(String input) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        decoration: InputDecoration(
          hintText: input,
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
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
