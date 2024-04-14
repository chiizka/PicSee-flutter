import 'package:flutter/material.dart';
import "package:picsee/all_photo_screen.dart";
import "package:picsee/albums_screen.dart";
import "package:picsee/home_screen.dart";

class Gallery extends StatefulWidget {
  @override
  _Gallery createState() => _Gallery();
}

class _Gallery extends State<Gallery> {
  int _currentIndex = 0;
  List<Widget> _screens = [
    AllPhotoScreen(),
    HomeScreen(),
    AlbumsScreen(),
  ];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ClipRRect(
        child: Container(
          height:60.0,
          width: 20.0,
          // margin: EdgeInsets.only(
          //   bottom: 16.0,
          //   left: 16.0,
          //   right: 16.0,
          // ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            iconSize: 30,
            selectedFontSize:
               10, // Set the selectedFontSize to 0 to hide the label when selected
            unselectedFontSize:
                10, // Set the unselectedFontSize to 0 to hide the label when unselected
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold, // Make selected text bold
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold, // Make unselected text bold
            ),
             selectedItemColor: const Color.fromARGB(255, 174, 106, 208),
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.image_outlined),
                label: 'All images',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_open_outlined),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_copy_outlined),
                label: 'Local Albums',
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
