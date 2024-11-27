import 'package:flutter/material.dart';
import 'login.dart';


class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MTC',
      home: Login(), // Aquí llamas al LoginScreen
    );
  }
}
