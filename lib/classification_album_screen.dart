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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
              height: 10,
            ),
          Text(
            classificationName,
            style: const TextStyle(
              color: Colors.white, // Change text color to white
            ),
          ),
          Text(
            ' ${imageFiles.length} Photos',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
              height: 10,
            ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 174, 106, 208),
    ),
    backgroundColor: Colors.white,
    body: Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        right: 10,
      ),
      child: GridView.builder(
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
    ),
  );
}
}
