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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('$SERVER_IP/clubs'));

    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;
    final List<dynamic> dataList = decoded['greetings'] as List<dynamic>;

    getData(dataList);
  }

  void getData(List<dynamic> dataList) {
    return setState(() {
      clubData = dataList.map((item) {
        final name = item['name'];
        final president = item['president'];
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
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: clubData,
          ),
        ),
      ),
    );
  }
}
