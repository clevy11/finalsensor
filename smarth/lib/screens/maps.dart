import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensormobileapplication/main.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  LatLng? _currentLocation;
  Map<PolygonId, Polygon> _polygons = {};
  StreamSubscription<LocationData>? _locationSubscription;
  bool _notificationSentOutSide = false;
  bool _notificationSentInSide = false;

  @override
  void initState() {
    super.initState();
    _createGeofence();
    getLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.hintColor,
        title: Text(
          'Your Location',
          style: TextStyle(color: theme.primaryColor),
        ),
        iconTheme: IconThemeData(
          color: theme.primaryColor,
        ),
      ),
      body: _currentLocation == null
          ? const Center(child: Text("Loading..."))
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) =>
                  _mapController.complete(controller),
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              polygons: Set<Polygon>.of(_polygons.values),
              markers: {
                Marker(
                  markerId: MarkerId("_currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentLocation!,
                ),
              },
            ),
    );
  }

  void _triggerInSideNotification() async {
    if (!_notificationSentInSide) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'Map_channel',
        'Map Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Welcome!',
        'Now, you are inside AUCA geographical boundaries.',
        platformChannelSpecifics,
      );
      print('Inside geofence notification sent');
      _notificationSentInSide = true;
      _notificationSentOutSide = false;
    }
  }

  void _triggerOutSideNotification() async {
    if (!_notificationSentOutSide) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'Map_channel',
        'Map Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'Hello!',
        'You are outside AUCA geographical boundaries.',
        platformChannelSpecifics,
      );
      print('Outside geofence notification sent');
      _notificationSentOutSide = true;
      _notificationSentInSide = false;
    }
  }

  void _createGeofence() {
    List<LatLng> boundaries = [
      LatLng(-1.95546, 30.10408), // Bottom-left
      LatLng(-1.95574, 30.10429), // Top-left
      LatLng(-1.95548, 30.10465), // Top-right
      LatLng(-1.95519, 30.10443), // Bottom-right
    ];

    PolygonId polygonId = PolygonId('campus_geofence');
    Polygon polygon = Polygon(
      polygonId: polygonId,
      points: boundaries,
      strokeWidth: 2,
      strokeColor: Colors.blue,
      fillColor: Colors.blue.withOpacity(0.3),
    );

    setState(() {
      _polygons[polygonId] = polygon;
    });

    _startLocationUpdates();
  }

  void _startLocationUpdates() async {
    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      double latitude = currentLocation.latitude!;
      double longitude = currentLocation.longitude!;

      bool insideGeofence = _isLocationInsideGeofence(latitude, longitude);

      if (insideGeofence && !_notificationSentInSide) {
        _triggerInSideNotification();
      } else if (!insideGeofence && !_notificationSentOutSide) {
        _triggerOutSideNotification();
      }

      // Update the current location and map position
      setState(() {
        _currentLocation = LatLng(latitude, longitude);
      });

      // Debug: Print the current location and status
      print("Current Location: Lat: $latitude, Lng: $longitude");
      print("Inside Geofence: $insideGeofence");
    });
  }

  bool _isLocationInsideGeofence(double latitude, double longitude) {
    List<LatLng> boundaries = [
      LatLng(-1.95546, 30.10408), // Bottom-left
      LatLng(-1.95574, 30.10429), // Top-left
      LatLng(-1.95548, 30.10465), // Top-right
      LatLng(-1.95519, 30.10443), // Bottom-right
    ];

    int n = boundaries.length;
    bool inside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      if ((boundaries[i].latitude > latitude) !=
              (boundaries[j].latitude > latitude) &&
          longitude <
              (boundaries[j].longitude - boundaries[i].longitude) *
                      (latitude - boundaries[i].latitude) /
                      (boundaries[j].latitude - boundaries[i].latitude) +
                  boundaries[i].longitude) {
        inside = !inside;
      }
    }
    return inside;
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Set desired accuracy (High accuracy)
    _locationController.changeSettings(accuracy: LocationAccuracy.high);
  }
}
