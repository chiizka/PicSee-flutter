import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picsee/show_album_images.dart';

class AlbumsScreen extends StatefulWidget {
  @override
  _AlbumsScreen createState() => _AlbumsScreen();
}

class _AlbumsScreen extends State<AlbumsScreen> {
  List<AlbumInfo> albums = [];
  String root = '/storage/emulated/0';

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await findImageFolders(root);
  }

  Future<void> findImageFolders(String basePath) async {
    List<AlbumInfo> folders = [];

    Directory baseDirectory = Directory(basePath);
    if (!baseDirectory.existsSync()) {
      print("Invalid path: $basePath");
      return;
    }

    await _findImageFoldersRecursive(baseDirectory, folders);

    setState(() {
      albums = folders;
    });
  }

  Future<void> _findImageFoldersRecursive(
      Directory directory, List<AlbumInfo> albums) async {
    List<FileSystemEntity> entities = directory.listSync();

    bool folderContainsImages = false;
    String? firstImagePath; // Initialize to null

    for (FileSystemEntity entity in entities) {
      if (entity is File && _isImageFile(entity.path)) {
        // If the folder contains an image, mark it
        folderContainsImages = true;
        firstImagePath = entity.path;
        break;
      } else if (entity is Directory) {
        // Check if the directory name is not "Android"
        if (entity.path.endsWith('Android')) {
          continue; // Skip the folder named "Android"
        }

        // Recursively check subdirectories
        await _findImageFoldersRecursive(entity, albums);
      }
    }

    if (folderContainsImages && firstImagePath != null) {
      // Add the path of the folder containing images to the list
      albums.add(AlbumInfo(directory.path, firstImagePath));
    }
  }

  bool _isImageFile(String filePath) {
    List<String> validExtensions = ['.jpg', '.jpeg', '.png'];

    for (String extension in validExtensions) {
      if (filePath.toLowerCase().endsWith(extension)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Albums',
            style: TextStyle(
              color: const Color.fromARGB(255, 174, 106, 208),
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width *
                  0.05, // Adjust the factor as needed
            ),
          ),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            mainAxisSpacing: 0, // Spacing between rows
            crossAxisSpacing: 0, // Spacing between columns
            childAspectRatio: 1, // Adjust the aspect ratio as needed
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Handle album tap, navigate to the screen with images
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPhotoScreen(
                      albumInfo: albums[index],
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(albums[index].thumbnailPath),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: MediaQuery.of(context).size.width * 0.4,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                            )),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              albums[index].name.split('/').last,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width *
                                    0.04, // Adjust the factor as needed
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AlbumInfo {
  final String name;
  final String thumbnailPath;

  AlbumInfo(this.name, this.thumbnailPath);
}
