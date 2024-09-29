import 'package:flutter/material.dart';
import 'package:yunlife/articles/articlesPage.dart';
import 'package:yunlife/clendar/clendarPage.dart';
import 'package:yunlife/robot/homeRobotPage.dart';
import 'package:yunlife/club/clubPage.dart';
import 'package:yunlife/set/setPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _choose() {
    switch (_selectedIndex) {
      case 0:
        return evaluatePage();
      case 1:
        return clendarPage();
      case 2:
        return homeRobotPage();
      case 3:
        return clubPage();
      case 4:
        return setPage();
      default:
        return Text('ERROR');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: _choose(),
      bottomNavigationBar: _BottomNavigationBar(),
    );
  }

  BottomNavigationBar _BottomNavigationBar() {
    return BottomNavigationBar(
      iconSize: 32,
      selectedItemColor: Colors.amber[800],
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: '課堂評價',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.date_range),
          label: '行事曆',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首頁',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: '校園社團',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.man),
          label: '設定',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        'Yun Life',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {},
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
      actions: [
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: EdgeInsets.all(10),
            width: 37,
            height: 37,
            child: Icon(
              Icons.density_medium,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
