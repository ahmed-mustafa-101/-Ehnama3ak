import 'package:flutter/material.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key});

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('My Progress Content'));
  }
}
