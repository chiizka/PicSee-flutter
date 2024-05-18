import 'package:flutter/material.dart';
import 'package:picsee/all_photo_screen.dart';
import 'package:picsee/albums_screen.dart';
import 'package:picsee/home_screen.dart';
import 'package:picsee/empty.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          PageStorage(
            bucket: PageStorageBucket(), // Add an empty bucket
            child: HomeScreen(),
          ),
          PageStorage(
            bucket: PageStorageBucket(), // Add an empty bucket
            child: EmptyScreen(),
          ),
          PageStorage(
            bucket: PageStorageBucket(), // Add an empty bucket
            child: EmptyScreen(),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: Container(
          height: 60.0,
          width: 20.0,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            iconSize: 30,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
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
              _pageController.animateToPage(
                index,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
        ),
      ),
    );
  }
}
