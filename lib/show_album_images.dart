import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/viewer_screen.dart';
import 'package:picsee/albums_screen.dart';

class AllPhotoScreen extends StatefulWidget {
  final AlbumInfo albumInfo;

  const AllPhotoScreen({required this.albumInfo});

  @override
  _AllPhotoScreenState createState() => _AllPhotoScreenState();
}

class _AllPhotoScreenState extends State<AllPhotoScreen> {
  List<String> imageFiles = [];

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await findImageFiles(widget.albumInfo.name);
  }

  Future<void> findImageFiles(String basePath) async {
    List<String> files = [];

    Directory baseDirectory = Directory(basePath);
    if (!baseDirectory.existsSync()) {
      print("Invalid path: $basePath");
      return;
    }

    await _findImageFilesRecursive(baseDirectory, files);

    // Sort the files based on their last modified time in descending order
    files.sort((a, b) {
      File fileA = File(a);
      File fileB = File(b);
      return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
    });

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
      debugShowCheckedModeBanner: false,
      title: "gallery",
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 174, 106, 208),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      widget.albumInfo.name.split('/').last,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center, // Center the text
                    ),
                  ),
                    Container(width: 48),
                ],
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 10, // Padding on top
                      left: 10,
                      right: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return RawMaterialButton(
                        onPressed: () {
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
                            borderRadius: BorderRadius.circular(5),
                            image: DecorationImage(
                              image: FileImage(File(imageFiles[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: imageFiles.length,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Add the AppBar with a back button
      ),
    );
  }
}
