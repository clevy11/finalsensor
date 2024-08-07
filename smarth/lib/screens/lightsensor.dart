import 'dart:async';
import 'package:flutter/material.dart';
import 'package:light_sensor/light_sensor.dart';

class LightSensorPage extends StatefulWidget {
  @override
  _LightSensorPageState createState() => _LightSensorPageState();
}

class _LightSensorPageState extends State<LightSensorPage> {
  double _lightIntensity = 0.0;
  bool _showHighIntensityPopup = true;
  bool _showLowIntensityPopup = true;
  late StreamSubscription<int> _lightSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToLightSensor();
  }

  @override
  void dispose() {
    _lightSubscription.cancel();
    super.dispose();
  }

  void _startListeningToLightSensor() {
    LightSensor.hasSensor().then((hasSensor) {
      if (hasSensor) {
        _lightSubscription = LightSensor.luxStream().listen((int luxValue) {
          setState(() {
            _lightIntensity = luxValue.toDouble();
            checkAndTriggerPopups();
          });
        });
      } else {
        print("Device does not have a light sensor");
      }
    });
  }

  void checkAndTriggerPopups() {
    if (_lightIntensity >= 30000.0 && _showHighIntensityPopup) {
      _showPopup(
          'High Light Intensity', 'Ambient light level is at its highest.');
      _showHighIntensityPopup = false;
    } else if (_lightIntensity != 10000.0) {
      _showHighIntensityPopup = true;
    }

    if (_lightIntensity == 0 && _showLowIntensityPopup) {
      _showPopup(
          'Low Light Intensity', 'Ambient light level is at its lowest.');
      _showLowIntensityPopup = false;
    } else if (_lightIntensity != 0) {
      _showLowIntensityPopup = true;
    }
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double containerOpacity = 1 - (_lightIntensity / 40000);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Light Sensor',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 26,
              left: 100,
              child: Container(
                width: 196,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 255, 255, 255)
                      .withOpacity(containerOpacity),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 255, 221, 1)
                          .withOpacity(containerOpacity),
                      blurRadius: 10,
                      spreadRadius: 10,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/bulb.png',
                  width: 400,
                  height: 400,
                ),
                SizedBox(height: 20),
                Text(
                  'Light Intensity: $_lightIntensity lx',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Change text color to white
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
