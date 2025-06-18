import 'package:flutter/material.dart';
import 'home_page.dart';
// import 'telugu_input_demo.dart';


void main() {
  runApp(const MyApp());
  //here..
  // runApp(const MaterialApp(
  //   debugShowCheckedModeBanner: false,
  //   home: TeluguInputDemo(),
  // ));
  //here.

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crop Disease Detector',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}
