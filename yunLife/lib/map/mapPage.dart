import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 添加 Google Maps Flutter 包
import 'package:location/location.dart';

class mapPage extends StatefulWidget {
  const mapPage({super.key});

  @override
  State<mapPage> createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  final locationController = Location();
  static const googlePlex = LatLng(23.693809679486208, 120.53182880511123);
  static const goatlocation = LatLng(23.6947643780979, 120.5378082675644);
  LatLng? currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await fetchLocationUpdates());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: googlePlex,
                zoom: 16,
              ),
              markers: {
                Marker(
                    markerId: const MarkerId('currentLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: currentPosition!),
                const Marker(
                    markerId: MarkerId('sourceLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: googlePlex),
                const Marker(
                    markerId: MarkerId('goat'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: goatlocation)
              },
            ),
    );
  }

  Future<void> fetchLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    permissionStatus = await locationController.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await locationController.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }
    locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPosition = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
        print(currentPosition!);
      }
    });
  }

//   Future<List<LatLng>> fetchPolylinePoints() async {
//     final polylinePoints = PolylinePoints();

//     final result = await polylinePoints.getRouteBetweenCoordinates(
//       googleMapsApiKey,
//       PointLatLng(googlePlex.latitude, googlePlex.longitude),
//       PointLatLng(mountainView.latitude, mountainView.longitude),
//     );

//     if (result.points.isNotEmpty) {
//       return result.points
//           .map((point) => LatLng(point.latitude, point.longitude))
//           .toList();
//     } else {
//       debugPrint(result.errorMessage);
//       return [];
//     }
//   }

//   Future<void> generatePolyLineFromPoints(
//       List<LatLng> polylineCoordinates) async {
//     const id = PolylineId('polyline');

//     final polyline = Polyline(
//       polylineId: id,
//       color: Colors.blueAccent,
//       points: polylineCoordinates,
//       width: 5,
//     );

//     setState(() => polylines[id] = polyline);
}
