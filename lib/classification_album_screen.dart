import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/viewer_screen.dart';

class ClassificationAlbumScreen extends StatelessWidget {
  final String classificationName;
  final List<String> imageFiles;

  const ClassificationAlbumScreen({
    required this.classificationName,
    required this.imageFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(classificationName),
      ),
      backgroundColor: Colors.white,
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: imageFiles.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewerScreen(
                    imageFiles: imageFiles,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: FileImage(File(imageFiles[index])),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
