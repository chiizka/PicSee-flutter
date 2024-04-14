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
          title: const Text('Albums'),
          centerTitle: true, 
        ), 
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            mainAxisSpacing: 8.0, // Spacing between rows
            crossAxisSpacing: 8.0, // Spacing between columns
            childAspectRatio: 0.8, // Adjust the aspect ratio as needed
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Image.file(
                          File(albums[index].thumbnailPath),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          width: 150,
                          height: 150,
                          color: Colors.black.withOpacity(0.5), // Black opacity
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    albums[index].name,
                    textAlign: TextAlign.center,
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
