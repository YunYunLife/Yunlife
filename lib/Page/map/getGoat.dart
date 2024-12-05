import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yunlife/setting.dart';


Future<LatLng?> getPointFromServer(String listname) async {
  LatLng? result;
  
  try {
    final response = await http.get(Uri.parse('$SERVER_IP/map_point'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      final List<dynamic> dataList = decoded['greetings'];

      // 查找匹配的 listname 项目
      final Map<String, dynamic> matchedItem = dataList
          .cast<Map<String, dynamic>>()
          .firstWhere((item) => item['filename'] == listname, orElse: () => <String, dynamic>{});

      // 提取 point 字段
      final point = matchedItem['point'] as String?;
      if (point != null) {
        // 分割字符串并解析为 LatLng
        final coordinates = point.split(',');
        if (coordinates.length == 2) {
          double lat = double.parse(coordinates[0].trim());
          double lng = double.parse(coordinates[1].trim());
          result = LatLng(lat, lng);
          print("Found point value: $result");
        } else {
          print("Invalid point format.");
        }
      } else {
        print("Point field is null.");
      }
        } else {
      print("Failed to fetch data. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }

  return result;
}

