import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pic',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'See',
                style: TextStyle(
                  color: Color(0xFF6552FE),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle Search button tap
              print('Search button tapped');
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF6552FE), // Set button color
              fixedSize: Size(150, 60), // Set button size
            ),
            child: Text(
              'Search',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Set text size
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle Utilities button tap
              print('Utilities button tapped');
            },
            style: ElevatedButton.styleFrom(
              primary: Color(0xFF6552FE), // Set button color
              fixedSize: Size(150, 60), // Set button size
            ),
            child: Text(
              'Utilities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Set text size
              ),
            ),
          ),
        ],
      ),
    );
  }
}
