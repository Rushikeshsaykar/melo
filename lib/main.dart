import 'package:flutter/material.dart';
import 'package:melo/home_screen.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermission();
  runApp(const MyApp());
}

Future<void> _requestPermission() async {
  await [
    Permission.storage,
    Permission.manageExternalStorage,
    Permission.audio,
  ].request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "melo",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}