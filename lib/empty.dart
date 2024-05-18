import 'package:flutter/material.dart';

class EmptyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empty Screen'),
      ),
      body: Center(
        child: Text(
          'This is an empty screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
