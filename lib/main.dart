import 'package:flutter/material.dart';
import 'package:handwriting_front/screens/input_screen.dart';

void main() {
  runApp(const HandwritingApp());
}

class HandwritingApp extends StatelessWidget {
  const HandwritingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handwriting App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InputScreen(),
    );
  }
}