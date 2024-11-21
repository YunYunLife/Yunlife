import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yunLife/Page/articles/dashline.dart';
import 'package:yunLife/setting.dart';

class evaluatePage extends StatefulWidget {
  const evaluatePage({super.key});

  @override
  State<evaluatePage> createState() => _evaluatePageState();
}

class _evaluatePageState extends State<evaluatePage> {
  List<Widget> clubData = [];
  List<dynamic> dataList = [];
  var myGoat = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$SERVER_IP/articles'));
    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;
    dataList = decoded['greetings'] as List<dynamic>;

    getData(dataList);
  }

  void findDataByKeyword() {
    if (myGoat.text == "") {
      getData(dataList);
    } else {
      final List<dynamic> goatdata = [];
      for (var item in dataList) {
        final title = item['title'] as String;
        final parts = title.split(" ");

        if (parts[3] == myGoat.text) {
          goatdata.add(item);
        }
      }
      if (goatdata.toString() == '[]') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查無此課堂！請確認輸入內容是否正確及完整')),
        );
      }
      getData(goatdata);
    }
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
            _clubBox(title, date, content, tags, context)
          ],
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffeeeeee),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            child: TextField(
              controller: myGoat,
              onEditingComplete: () => findDataByKeyword(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search),
                labelText: "請輸入課堂名稱",
                hintText: "範例：網頁設計",
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(child: ListView(children: clubData))
        ],
      )),
    );
  }
}

Container _clubBox(String mass, String date, String content, List<String> tags,
    BuildContext context) {
  List<String> title = mass.split(' ');
  String semester = (title[0].substring(3, 4) == '1') ? '第一學期' : '第二學期';
  String teacher = title[2];
  String classNamech = title[3];
  String? classNameen = title.length > 4 ? title.sublist(4).join(' ') : null;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
    ),
    width: MediaQuery.of(context).size.width * 1,
    constraints: BoxConstraints(
      minHeight: 180.0,
      maxHeight: double.infinity,
    ),
    child: Padding(
        padding: EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  classNamech,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
                Icon(Icons.more_horiz)
              ],
            ),
            if (classNameen != null)
              Text(
                classNameen,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF9B979C)),
              ),
            Text(
              teacher + " " + semester,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF737373)),
            ),
            Text(
              date + ' 評論',
              style: TextStyle(fontSize: 18, color: Color(0xFF9b979c)),
            ),
            SizedBox(
              height: 2,
            ),
            DashedLine(),
            Text(content),
            Wrap(
              spacing: 10.0, // 间距
              children: tags.map((tag) {
                return Chip(
                  side: BorderSide.none,
                  backgroundColor: Color(0xFFFFDE59),
                  label: Text(
                    tag,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                );
              }).toList(),
            ),
          ],
        )),
  );
}
