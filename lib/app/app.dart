import 'package:flutter/material.dart';

class MonthlyTraqApp extends StatelessWidget {
  const MonthlyTraqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonthlyTraq',
      debugShowCheckedModeBanner: true,
      home: Scaffold(
        appBar: AppBar(title: const Text('MonthlyTraq')),
        body: const Center(child: Text('Welcome to MonthlyTraq')),
      ),
    );
  }
}
