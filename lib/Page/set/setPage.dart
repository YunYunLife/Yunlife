import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yunLife/Page/login/loginPage.dart';
import 'package:yunLife/setting.dart';

class setPage extends StatefulWidget {
  const setPage({super.key});

  @override
  State<setPage> createState() => _setPageState();
}

class _setPageState extends State<setPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "意見回饋",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.all(10),
              width: 37,
              height: 37,
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ),
        body: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ElevatedButton(
                onPressed: () {
                  _showInputDialog(context);
                },
                child: Text("意見回饋")),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            ElevatedButton(
                onPressed: () {
                  _showHowToUse(context);
                },
                child: Text("使用說明")),
          ]),
          SizedBox(
            height: 100,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('登出'),
          )
        ]));
  }

  void _showInputDialog(BuildContext context) {
    TextEditingController _textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('意見回饋'),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: "輸入您想回饋的內容"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                String inputText = _textController.text;
                _sendFeedback(inputText);
                Navigator.of(context).pop();
              },
              child: Text('送出'),
            ),
          ],
        );
      },
    );
  }

  void _showHowToUse(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("使用說明"),
          content: Text("這是使用說明"),
        );
      },
    );
  }

  Future<void> _sendFeedback(String feedback) async {
    final String apiUrl = '$SERVER_IP/feedback';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'feedback': feedback}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('回饋已提交！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失敗，請重試！')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('無網路，請確認連接！')),
      );
    }
  }
}
