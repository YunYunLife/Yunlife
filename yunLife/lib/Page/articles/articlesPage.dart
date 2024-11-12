import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yunLife/setting.dart';

class evaluatePage extends StatefulWidget {
  const evaluatePage({super.key});

  @override
  State<evaluatePage> createState() => _evaluatePageState();
}

class _evaluatePageState extends State<evaluatePage> {
  List<Widget> clubData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$SERVER_IP/articles'));

    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> dataList = decoded['greetings'] as List<dynamic>;

    getData(dataList);
  }

  void getData(List<dynamic> dataList) {
    return setState(() {
      clubData = dataList.map((item) {
        final title = item['title'];
        final date = item['date'];
        final content = item['content'];
        final tags = List<String>.from(item['tags']);

        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            _clubBox(title, date, content, tags)
          ],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Expanded(child: ListView(children: clubData))],
      )),
    );
  }
}

Container _clubBox(
    String title, String date, String content, List<String> tags) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.brown[300],
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    width: 300,
    constraints: BoxConstraints(
      minHeight: 180,
      maxHeight: double.infinity,
    ),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '課堂名稱：$title',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
              fontSize: 20,
            ),
          ),
          // SizedBox(height: 8),
          Text(
            '日期：$date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
              fontSize: 20,
            ),
          ),
          // SizedBox(height: 8),
          Text(
            '評論：$content',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
              fontSize: 20,
            ),
          ),
          // SizedBox(height: 8),
          Wrap(
            spacing: 8.0, // 间距
            children: tags.map((tag) {
              return Chip(
                label: Text(
                  tag,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                      fontSize: 15),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}
