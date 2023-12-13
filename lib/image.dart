import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final String imagepath;
  const MyWidget(this.imagepath );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)),
                    image: DecorationImage(
                      image: AssetImage('imagepath'),
                      fit: BoxFit.cover,
                    ),
                  ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
