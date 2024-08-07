import 'dart:async';
import 'dart:math'; // Import dart:math for sqrt function
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensormobileapplication/main.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StepCounterPage extends StatefulWidget {
  @override
  _StepCounterPageState createState() => _StepCounterPageState();
}

class _StepCounterPageState extends State<StepCounterPage> {
  int _stepCount = 0;
  bool _motionDetected = false;
  bool _notificationShown = false;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  late double _previousMagnitude;
  late DateTime _lastStepTime;

  @override
  void initState() {
    super.initState();
    _previousMagnitude = 0.0;
    _lastStepTime = DateTime.now();
    _startListeningToAccelerometer();
  }

  @override
  void dispose() {
    _accelerometerSubscription.cancel();
    super.dispose();
  }

  void _startListeningToAccelerometer() {
    Timer? motionTimer;

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (_isStepDetected(magnitude)) {
        setState(() {
          _stepCount++;
          _motionDetected = true;
          _triggerNotification();
          _notificationShown = true;
          motionTimer?.cancel();
          motionTimer = Timer(const Duration(seconds: 10), () {
            if (mounted) {
              setState(() {
                _motionDetected = false;
                _notificationShown = false;
              });
            }
          });
        });
      }

      _previousMagnitude = magnitude;
    });
  }

  bool _isStepDetected(double magnitude) {
    final currentTime = DateTime.now();
    final timeDifference = currentTime.difference(_lastStepTime).inMilliseconds;

    // Threshold and time gap to avoid multiple detections for a single step
    if (magnitude > 12 && timeDifference > 300) {
      _lastStepTime = currentTime;
      return true;
    }
    return false;
  }

  void _triggerNotification() async {
    if (!_notificationShown) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'StepCounter_channel',
        'StepCounter Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        'yolla!',
        'Motion detected! keep moving ',
        platformChannelSpecifics,
      );
      print('Motion detected! Alerting user...');
      _notificationShown = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.hintColor,
        title: Text(
          'Motion detector(Steps)',
          style: TextStyle(color: theme.primaryColor),
        ),
        iconTheme: IconThemeData(
          color: theme.primaryColor,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.run_circle_outlined,
              size: 100,
              color: theme.primaryColor,
            ),
            SizedBox(height: 20),
            _buildStepCounterWidget(theme),
            SizedBox(height: 20),
            _motionDetected
                ? Text(
                    'Motion Detected!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Highlight in red for emphasis
                    ),
                  )
                : Text(
                    'At rest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Use green color for rest
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCounterWidget(ThemeData theme) {
    return Container(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Positioned.fill(
            child: CircularProgressIndicator(
              value: _stepCount % 100 / 100, // Normalized to percentage
              strokeWidth: 10,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          Center(
            child: Text(
              '$_stepCount',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
