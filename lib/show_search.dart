import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/viewer_screen.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ShowSearchScreen extends StatefulWidget {
  final List<String> tags;

  ShowSearchScreen({Key? key, required List<String> tags})
      : tags = tags.map((tag) => _formatTag(tag)).toList(), // Format each tag
        super(key: key);

  static String _formatTag(String tag) {
    if (tag.isEmpty) return tag;

    // Capitalize the first letter and make the rest lowercase
    return tag.substring(0, 1).toUpperCase() + tag.substring(1).toLowerCase();
  }

  @override
  _ShowSearchScreenState createState() => _ShowSearchScreenState();
}

class _ShowSearchScreenState extends State<ShowSearchScreen> {
  String root = '/storage/emulated/0';
  Map<String, List<String>> imageAlbums = {};
  bool isModelLoaded = false;
  bool isImagesDetected = false;

  @override
  void initState() {
    super.initState();
    print("Tags: ${widget.tags}");
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
      isImagesDetected = true;
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
    for (String imagePath in imageFiles) {
      File image = File(imagePath);
      var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 8,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      print('Image: $imagePath, Recognitions: $recognitions');

      for (int i = 0; recognitions != null && i < recognitions.length; i++) {
        if (recognitions[i]!['confidence'] >= 0.80) {
          String category = recognitions[i]!['label'];
          if (widget.tags.contains(category)) {
            setState(() {
              imageAlbums.putIfAbsent(category, () => []).add(image.path);
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Tags passed to ShowSearchScreen: ${widget.tags}");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Categories'),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView.builder(
          itemCount: widget.tags.length,
          itemBuilder: (context, index) {
            var tag = widget.tags[index];
            var images = imageAlbums[tag] ?? [];
            var imageCount = images.length; // Number of images for this tag

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        tag,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '($imageCount images)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: images.map((imagePath) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewerScreen(
                                imageFiles: images,
                                initialIndex: images.indexOf(imagePath),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(imagePath),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
