import 'package:flutter/material.dart';
import 'package:picsee/all_photo_screen.dart';
import 'package:picsee/albums_screen.dart';
import 'package:picsee/home_screen.dart';
import 'package:picsee/search.dart';

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
            bucket: PageStorageBucket(),
            child: AllPhotoScreen(),
          ),
          PageStorage(
            bucket: PageStorageBucket(),
            child: HomeScreen(),
          ),
          PageStorage(
            bucket: PageStorageBucket(),
            child: AlbumsScreen(),
          ),
          PageStorage(
            bucket: PageStorageBucket(),
            child: SearchScreen(),
          ), // New screen added
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: Container(
          height: 65.0,
          width: 30.0,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search', // New item label
              ), // New item added
            ],
            onTap: (index) {
              _pageController.jumpToPage(index);
            },
          ),
        ),
      ),
    );
  }
}
