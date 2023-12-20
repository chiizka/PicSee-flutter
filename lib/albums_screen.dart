import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:picsee/all_photo_screen.dart';

class AlbumsScreen extends StatefulWidget {
  @override
  _AlbumsScreen createState() => _AlbumsScreen();
}

class _AlbumsScreen extends State<AlbumsScreen> {
  List<String> imageFolders = [];
  String root = '/storage/emulated/0';

  @override
  void initState() {
    super.initState();

    initApp();
  }

  Future<void> initApp() async {
    findImageFolders(root);
  }

  Future<void> findImageFolders(String basePath) async {
    List<String> folders = [];

    Directory baseDirectory = Directory(basePath);
    if (!baseDirectory.existsSync()) {
      print("Invalid path: $basePath");
      return;
    }

    await _findImageFoldersRecursive(baseDirectory, folders);

    setState(() {
      imageFolders = folders;
    });
  }

  Future<void> _findImageFoldersRecursive(
      Directory directory, List<String> folders) async {
    List<FileSystemEntity> entities = directory.listSync();

    bool folderContainsImages = false;

    for (FileSystemEntity entity in entities) {
      if (entity is File && _isImageFile(entity.path)) {
        // If the folder contains an image, mark it
        folderContainsImages = true;
      } else if (entity is Directory) {
        // Check if the directory name is not "Android"
        if (entity.path.endsWith('Android')) {
          continue; // Skip the folder named "Android"
        }

        // Recursively check subdirectories
        await _findImageFoldersRecursive(entity, folders);
      }
    }

    if (folderContainsImages) {
      // Add the path of the folder containing images to the list
      folders.add(directory.path);
    }
  }

  bool _isImageFile(String filePath) {
    List<String> validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];

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
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
      ),
      body: ListView.builder(
          itemCount: imageFolders.length,
          itemBuilder: (context, index) {
            return Center(child: Text("${imageFolders[index]}"));
          }),
    ));
  }
}
