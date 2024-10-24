import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
    final response = await http.get(Uri.parse('http://yunlifeserver.glitch.me/clubs'));

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

        return Padding(padding: EdgeInsets.all(8),
        child:ListTile(
          tileColor: Color.fromARGB(255, 247, 236, 187),
          contentPadding: EdgeInsets.all(8),
          title: Text(name),
          subtitle: Text("社長："+ president),
          trailing:Column(crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("社團辦公室："+ office),
            Text("集社時間："+ meetingTime),
            Text("集社地點："+ meetingPlace),
          ],) 
        ),
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

Container _clubBox(String name, String president, String office,
    String meetingTime, String meetingPlace) {
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
              '社團名稱：$name',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontSize: 20),
            ),
            Text(
              '社長：$president',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontSize: 20),
            ),
            Text(
              '社團辦公室：$office',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontSize: 20),
            ),
            Text(
              '集社時間：$meetingTime',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontSize: 20),
            ),
            Text(
              '集社地點$name',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                  fontSize: 20),
            ),
          ],
        )),
  );
}
