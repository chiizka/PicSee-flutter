import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/viewer_screen.dart';

class AllPhotoScreen extends StatefulWidget {
  @override
  _AllPhotoScreenState createState() => _AllPhotoScreenState();
}

class _AllPhotoScreenState extends State<AllPhotoScreen> {
  List<String> imageFiles = [];
  String root = '/storage/emulated/0';

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await findImageFiles(root);
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
      debugShowCheckedModeBanner: false, // Set this to false
      title: "gallery",
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 174, 106, 208),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 40,
              ),
              const Text(
                'All Photos',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
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
                            borderRadius: BorderRadius.circular(15),
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
      ),
    );
  }
}
