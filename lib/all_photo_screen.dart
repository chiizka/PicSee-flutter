import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';

class AllPhotoScreen extends StatefulWidget {
  @override
  _AllPhotoScreen createState() => _AllPhotoScreen();
}

class _AllPhotoScreen extends State<AllPhotoScreen> {
  List<String> imageFiles = [];
  String root = '/storage/emulated/0';

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    findImageFiles(root);
  }

  Future<void> findImageFiles(String basePath) async {
    List<String> files = [];

    Directory baseDirectory = Directory(basePath);
    if (!baseDirectory.existsSync()) {
      print("Invalid path: $basePath");
      return;
    }

    await _findImageFilesRecursive(baseDirectory, files);

    setState(() {
      imageFiles = files;
    });
  }

  Future<void> _findImageFilesRecursive(
      Directory directory, List<String> files) async {
    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is File && _isImageFile(entity.path)) {
        // If the entity is an image file, add its path to the list
        files.add(entity.path);
      } else if (entity is Directory) {
        // Check if the directory name is not "Android"
        if (entity.path.endsWith('Android')) {
          continue; // Skip the folder named "Android"
        }

        // Recursively check subdirectories
        await _findImageFilesRecursive(entity, files);
      }
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
          title: const Text('All Photos'),
        ),
        body: ListView.builder(
          itemCount: imageFiles.length,
          itemBuilder: (context, index) {
            return Center(child: Text("${imageFiles[index]}"));
          },
        ),
      ),
    );
  }
}
