import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/classification_album_screen.dart';
import 'package:picsee/viewer_screen.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String root = '/storage/emulated/0';
  Map<String, List<String>> imageAlbums = {};
  bool isModelLoaded = false;
  bool isImagesDetected = false; // Track if images have been detected
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    initApp();
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
    List<String> validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];

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
        if (recognitions[i]!['confidence'] >= 0.80) {
          String category = recognitions[i]!['label'];
          setState(() {
            imageAlbums.putIfAbsent(category, () => []).add(image.path);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter all image files based on search text
    var filteredTags = imageAlbums.keys
        .where((tag) => tag.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    var filteredImages =
        filteredTags.expand((tag) => imageAlbums[tag]!).toList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 0.8,
                ),
                itemCount: _searchText.isEmpty
                    ? imageAlbums.length
                    : filteredImages.length,
                itemBuilder: (context, index) {
                  if (_searchText.isEmpty) {
                    // Display categorized albums when no search is performed
                    var albumName = imageAlbums.keys.elementAt(index);
                    var thumbnailPath = imageAlbums[albumName]!.first;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClassificationAlbumScreen(
                              classificationName: albumName,
                              imageFiles: imageAlbums[albumName]!,
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
                  } else {
                    // Display filtered images when search is performed
                    var imagePath = filteredImages[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewerScreen(
                              imageFiles: filteredImages,
                              initialIndex: index,
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
                                    File(imagePath),
                                    width: 170,
                                    height: 170,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // You can add additional UI elements here if needed
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
