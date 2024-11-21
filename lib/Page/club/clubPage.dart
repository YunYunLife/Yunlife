import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yunLife/setting.dart';

class clubPage extends StatefulWidget {
  const clubPage({super.key});

  @override
  State<clubPage> createState() => _clubPageState();
}

class _clubPageState extends State<clubPage> {
  List<Widget> clubData = [];
  final myGoat = TextEditingController();
  List<dynamic> dataList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$SERVER_IP/clubs'));

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
        final title = item['name'] as String;

        if (title == myGoat.text) {
          goatdata.add(item);
        }
      }
      if (goatdata.toString() == '[]') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('查無此社團！請確認輸入內容是否正確及完整')),
        );
      }
      getData(goatdata);
    }
  }

  void getData(List<dynamic> dataList) {
    return setState(() {
      clubData = dataList.map((item) {
        final name = item['name'];
        // final president = item['president'];
        final office = item['office'];
        final meetingTime = item['meeting_time'];
        final meetingPlace = item['meeting_place'] ?? "";

        return Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            tileColor: Color.fromARGB(255, 247, 236, 187),
            contentPadding: EdgeInsets.all(8),
            leading: Container(
              child: Text(
                "$name",
                style: TextStyle(fontSize: 15),
              ),
              width: 100,
            ),
            title: Text(
              "社團辦公室：$office\n集社時間：$meetingTime\n集社地點：$meetingPlace",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 10),
            ),
          ),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: TextField(
            controller: myGoat,
            onEditingComplete: () => findDataByKeyword(),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: Icon(Icons.search),
              labelText: "請輸入社團名稱",
              hintText: "範例：攝影社",
              hintStyle: TextStyle(color: Colors.grey[700]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: clubData,
          ),
        ),
      ]),
    );
  }
}
