import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:picsee/classification_album_screen.dart';
import 'search.dart'; // Import the SearchScreen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String root = '/storage/emulated/0';
  Map<String, List<String>> imageAlbums = {};
  bool isModelLoaded = false;
  bool isImagesDetected = false;
  bool _initialized = false;
  late StreamController<Map<String, List<String>>> _imageAlbumsController;

  @override
  void initState() {
    super.initState();
    _imageAlbumsController =
        StreamController<Map<String, List<String>>>.broadcast();
    checkInitialization();
  }

  @override
  void dispose() {
    _imageAlbumsController.close();
    super.dispose();
  }

  Future<void> checkInitialization() async {
    try {
      final initialized = await readInitializationFlag();
      print("Initialization flag: $initialized");

      setState(() {
        _initialized = initialized;
      });

      if (!_initialized) {
        await initApp();
      } else {
        final cachedImageAlbums = await readCachedImageAlbums();
        print("Cached Image Albums: $cachedImageAlbums");
        if (cachedImageAlbums.isNotEmpty) {
          print(
              "*******************************************************************************");
          setState(() {
            imageAlbums = cachedImageAlbums;
            isImagesDetected = true;
          });
          // Notify listeners with the loaded cached image albums
          _imageAlbumsController.add(imageAlbums);
        } else {
          print(
              "------------------------------------------------------------------------------------------");
          // If there's no cache, initialize the app (unlikely case)
          await initApp();
        }
      }
    } catch (e) {
      print('Error checking initialization: $e');
    }
  }

  Future<void> initApp() async {
    try {
      await loadModel();
      await findImageFiles(root);
      await writeInitializationFlag(true); // Set initialization flag to true
    } catch (e) {
      print('Error initializing app: $e');
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
      isImagesDetected = true;
    });
    // Cache the detected image albums
    await writeCachedImageAlbums(imageAlbums);
    print('Cached image albums written: $imageAlbums');
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

    // Merge the new image albums with the existing ones
    newImageAlbums.forEach((category, images) {
      imageAlbums.putIfAbsent(category, () => []);
      imageAlbums[category]!.addAll(images);
    });

    // Notify listeners with the updated image albums map
    _imageAlbumsController.add(imageAlbums);
  }

  Future<void> writeInitializationFlag(bool initialized) async {
    try {
      final file = await _getInitializationFlagFile();
      if (file != null) {
        await file.writeAsString(initialized ? '1' : '0');
      }
    } catch (e) {
      print('Error writing initialization flag to file: $e');
    }
  }

  Future<bool> readInitializationFlag() async {
    try {
      final file = await _getInitializationFlagFile();
      if (file != null && file.existsSync()) {
        String content = await file.readAsString();
        return content.trim() == '1';
      }
    } catch (e) {
      print('Error reading initialization flag from file: $e');
    }
    return false;
  }

  Future<File?> _getInitializationFlagFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/initialization_flag.txt');
  }

  Future<void> writeCachedImageAlbums(
      Map<String, List<String>> imageAlbums) async {
    try {
      final file = await _getCachedImageAlbumsFile();
      if (file != null) {
        await file.writeAsString(json.encode(imageAlbums));
      }
    } catch (e) {
      print('Error writing cached image albums to file: $e');
    }
  }

  Future<Map<String, List<String>>> readCachedImageAlbums() async {
    try {
      final file = await _getCachedImageAlbumsFile();
      if (file != null && file.existsSync()) {
        String content = await file.readAsString();
        print('Cached image albums content: $content');
        final decodedData = json.decode(content);
        if (decodedData is Map<String, dynamic>) {
          return decodedData
              .map((key, value) => MapEntry(key, List<String>.from(value)));
        } else {
          print('Invalid format for cached image albums data.');
        }
      }
    } catch (e) {
      print('Error reading cached image albums from file: $e');
    }
    return {};
  }

  Future<File?> _getCachedImageAlbumsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/cached_image_albums.json');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text(
          'Categories',
          style: TextStyle(
            color:   Color.fromARGB(255, 174, 106, 208),
            fontWeight: FontWeight.bold,
            fontSize: 25// Make font bold here
          ),
        ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Initialization Status'),
                      content: Text(_initialized
                          ? 'App initialized'
                          : 'App not initialized'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<Map<String, List<String>>>(
          stream: _imageAlbumsController.stream,
          builder:
              (context, AsyncSnapshot<Map<String, List<String>>?> snapshot) {
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(),
                            ),
                          );
                        },
                        child: Text('Search'),
                      ),
                      ElevatedButton(
                        onPressed: () {
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
                      var thumbnailPaths = data[albumName]!;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassificationAlbumScreen(
                                classificationName: albumName,
                                imageFiles: thumbnailPaths,
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
                                      File(thumbnailPaths.first),
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
