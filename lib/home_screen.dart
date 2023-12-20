import "package:flutter/material.dart";
import "package:picsee/gallery.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(
          child: ElevatedButton(
              child: const Text("Go to eme"),
              onPressed: () {
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => Gallery()));
              })),
    );
  }
}
