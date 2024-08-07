import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensormobileapplication/components/ThemeProvider.dart';
import 'package:sensormobileapplication/screens/StepCounter.dart';
import 'package:sensormobileapplication/screens/lightsensor.dart';
import 'package:sensormobileapplication/screens/maps.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
  await initNotifications();
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // Handle notification tap
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: themeNotifier.currentTheme,
      home: const MyHomePage(title: 'Smart Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E85B2), // Matching cool blue color
        title: Text(
          widget.title,
          style:
              const TextStyle(color: Colors.white), // White text for contrast
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6E85B2), // Cool blue
              Color(0xFFB2C9AB), // Soft green
              Color(0xFFF9F9F9), // Light gray
            ],
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildOption(
              context,
              icon: Icons.map,
              label: 'Maps',
              color: const Color(0xFF6E85B2), // Cool blue for this option
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MapPage())),
            ),
            _buildOption(
              context,
              icon: Icons.run_circle_outlined,
              label: '',
              color:
                  Color.fromARGB(255, 54, 54, 54), // Soft green for this option
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => StepCounterPage())),
            ),
            _buildOption(
              context,
              icon: Icons.lightbulb_rounded,
              label: 'Light Sensor',
              color: Color.fromARGB(255, 64, 118, 233),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => LightSensorPage())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color, // Background color for each grid item
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 50.0, color: Colors.white), // White icon for contrast
            const SizedBox(height: 8.0),
            Text(label,
                style: const TextStyle(
                    color: Colors.white)), // White text for contrast
          ],
        ),
      ),
    );
  }
}
