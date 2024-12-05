import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:yunlife/Page/map/getGoat.dart';
import 'package:yunlife/setting.dart';

class mapPage extends StatefulWidget {
  const mapPage({super.key});

  @override
  State<mapPage> createState() => _MapPageState();
}

class _MapPageState extends State<mapPage> {
  LatLng? goatLocation;
  String message = "未輸入資料";
  final myGoat = TextEditingController();
  bool havePic = false;

  Future<void> goat() async {
    havePic = false;
    String text = myGoat.text;
    LatLng? location = await getPointFromServer(text.substring(0, 2));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("連線中，請稍後...")),
    );
    if (location != null && text.length>4) {
      setState(() {
        goatLocation = location;
      });
      _updateMapView(location);
      message = text.substring(0, 2) + " " + text.substring(2, 3) + " 樓地圖";
      havePic = true;
    } else {
      message = "學校沒有這教室";
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    ;
  }

  void _updateMapView(LatLng location) {
    mapController.animateCamera(CameraUpdate.newLatLng(location));
  }

 getpic() {
  String text = myGoat.text.substring(0, 3);
  if (havePic) {
    double _scale = 1.0; 
    double _maxScale = 5.0; 

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InteractiveViewer(
              maxScale: _maxScale,
              child: Image.network(
                'http://yunlifeserver.glitch.me/image_by_name/$text',
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child; // 图片加载完成显示
                  }
                  return const Center(
                    child: CircularProgressIndicator(), // 显示加载指示器
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    "圖片加載失敗",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  } else {
    return const Text(
      "沒有圖片",
      style: TextStyle(fontSize: 16, color: Colors.red),
    );
  }
}

  late GoogleMapController mapController;
  final Location location = Location();
  LatLng? currentLocation = LatLng(23.693297406133105, 120.53458268547402);
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 检查定位服务是否启用
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    // 检查位置权限
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // 获取当前位置并实时更新
    location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          currentLocation =
              LatLng(locationData.latitude!, locationData.longitude!);
          if (goatLocation != null) {
            _getPolyline();
            _addMarker(
                goatLocation!, "goatLocation", BitmapDescriptor.defaultMarker);
          }
        });
      }
    });
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker =
        Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (goatLocation != null) {
      mapController.animateCamera(CameraUpdate.newLatLng(goatLocation!));
    }
  }

  void _addPolyline() {
    PolylineId id = PolylineId("polyline");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<void> _getPolyline() async {
    if (currentLocation == null) return;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin:
            PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
        destination:
            PointLatLng(goatLocation!.latitude, goatLocation!.longitude),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      _addPolyline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: myGoat,
              onEditingComplete: () => goat(),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search),
                labelText: "請輸入教室代號",
                hintText: "範例：MA214",
                hintStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 16,
              ),
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(message),
                content: getpic(),
              );
            },
          );
        },
        tooltip: "顯示該樓層地圖",
        child: Icon(Icons.insert_photo),
      ),
    );
  }
}
