import 'package:flutter/material.dart';
import "package:picsee/all_photo_screen.dart";
import "package:picsee/albums_screen.dart";

class Gallery extends StatefulWidget {
  @override
  _Gallery createState() => _Gallery();
}

class _Gallery extends State<Gallery> {
  int _currentIndex = 1;
  List<Widget> _screens = [
    AllPhotoScreen(),
    ImageFilesScreen(),
    AlbumsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(50.0),
          bottom: Radius.circular(50.0),
        ),
        child: Container(
          height: 100.0,
          width: 20.0,
          // margin: EdgeInsets.only(
          //   bottom: 16.0,
          //   left: 16.0,
          //   right: 16.0,
          // ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Color(0xFF909090),
            iconSize: 40,
            selectedFontSize:
                0, // Set the selectedFontSize to 0 to hide the label when selected
            unselectedFontSize:
                0, // Set the unselectedFontSize to 0 to hide the label when unselected
            selectedLabelStyle: TextStyle(fontSize: 0),
            unselectedLabelStyle: TextStyle(fontSize: 0),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.all_inbox),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder),
                label: '',
              ),
            ],
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

class ImageFilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Image Files Screen'),
      ),
    );
  }
}
