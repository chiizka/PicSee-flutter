import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/classification_album_screen.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'search.dart'; // Import the SearchScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String root = '/storage/emulated/0';
  Map<String, List<String>> imageAlbums = {};
  bool isModelLoaded = false;
  bool isImagesDetected = false; // Track if images have been detected
  late StreamController<Map<String, List<String>>> _imageAlbumsController;

  @override
  void initState() {
    super.initState();
    _imageAlbumsController =
        StreamController<Map<String, List<String>>>.broadcast();
    initApp();
  }

  @override
  void dispose() {
    _imageAlbumsController.close();
    super.dispose();
  }

  Future<void> initApp() async {
    await loadModel();
    if (!isImagesDetected) {
      await findImageFiles(root);
    }
  }

  Future<void> findImageFiles(String basePath) async {
    List<String> files = [];

    Directory baseDirectory = Directory(basePath);
    if (!baseDirectory.existsSync()) {
      print("Invalid path: $basePath");
      return;
    }

    await _findImageFilesRecursive(baseDirectory, files);
    await detectImages(files);
    setState(() {
      isImagesDetected = true; // Update flag after detecting images
    });
  }

  Future<void> _findImageFilesRecursive(
      Directory directory, List<String> files) async {
    List<FileSystemEntity> entities = directory.listSync();

    for (FileSystemEntity entity in entities) {
      if (entity is File && _isImageFile(entity.path)) {
        files.add(entity.path);
      } else if (entity is Directory) {
        if (entity.path.endsWith('Android')) {
          continue;
        }

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

  Future<void> loadModel() async {
    if (!isModelLoaded) {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
      );
      isModelLoaded = true;
    }
  }

  Future<void> detectImages(List<String> imageFiles) async {
    Map<String, List<String>> newImageAlbums = {};

    for (String imagePath in imageFiles) {
      File image = File(imagePath);
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 8,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      for (int i = 0; i < recognitions!.length; i++) {
        if (recognitions[i]!['confidence'] >= 0.90) {
          String category = recognitions[i]!['label'];
          newImageAlbums.putIfAbsent(category, () => []).add(image.path);
        }
      }
    }

    if (mounted) {
      if (!_imageAlbumsController.isClosed) {
        _imageAlbumsController.add(newImageAlbums);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          centerTitle: true,
        ),
        body: StreamBuilder<Map<String, List<String>>>(
          stream: _imageAlbumsController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            Map<String, List<String>>? data = snapshot.data;
            if (data == null || data.isEmpty) {
              return Center(
                child: Text('No data available.'),
              );
            }

            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the SearchScreen when the "Search" button is clicked
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()),
                          );
                        },
                        child: Text('Search'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Show the utilities panel when the "Utilities" button is clicked
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Action for "New Album"
                                      },
                                      child: Text('New Album'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Action for "Manual Categorization"
                                      },
                                      child: Text('Manual Categorization'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Text('Utilities'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      var albumName = data.keys.elementAt(index);
                      var thumbnailPath = data[albumName]!.first;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassificationAlbumScreen(
                                classificationName: albumName,
                                imageFiles: data[albumName]!,
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
                                      File(thumbnailPath),
                                      width: 170,
                                      height: 170,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Container(
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        albumName,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
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
              ],
            );
          },
        ),
      ),
    );
  }
}
