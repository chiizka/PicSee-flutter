import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picsee/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen()); //call yun splash screen
  }
}
