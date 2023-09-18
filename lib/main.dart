import 'package:flutter/material.dart';
import 'package:webscoket_learning/chat.dart';

void main(List<String> args) {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Chat(),
    );
  }
}
