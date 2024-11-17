import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:yunLife/setting.dart';

class mapPage extends StatefulWidget {
  const mapPage({super.key});

  @override
  State<mapPage> createState() => _MapPageState();
}

class _MapPageState extends State<mapPage> {
  final myGoat = TextEditingController();

  String goat() {
    String text = myGoat.text;
    if (text.length < 3) {
      return "學校沒有這教室";
    } else  {
      return text.substring(0, 2)+" "+text.substring(2, 3)+" 樓地圖";
    } 

  }

  late GoogleMapController mapController;
  final Location location = Location();
  LatLng goatLocation = const LatLng(23.6947643780979, 120.5378082675644);
  LatLng? currentLocation;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _addMarker(goatLocation, "goatLocation", BitmapDescriptor.defaultMarker);
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
          currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        });
        _getPolyline();
      }
    });
  }

  void _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers[markerId] = marker;
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        origin: PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
        destination: PointLatLng(goatLocation.latitude, goatLocation.longitude),
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.amber[200],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: myGoat,
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
            ],
          ),

          // GoogleMap(
          //   initialCameraPosition: CameraPosition(
          //     target: currentLocation ?? LatLng(23.693297406133105, 120.53458268547402),
          //     zoom: 15,
          //   ),
          //   myLocationEnabled: true,
          //   onMapCreated: _onMapCreated,
          //   markers: Set<Marker>.of(markers.values),
          //   polylines: Set<Polyline>.of(polylines.values),
          // ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(goat()),
                    content: Text('this is picture'),
                  );
                },
              );
            },
            tooltip: "顯示該樓層地圖",
            child: Icon(Icons.insert_photo)),
      ),
    );
  }
}
