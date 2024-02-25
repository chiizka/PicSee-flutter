import 'dart:io';
import 'package:flutter/material.dart';
import 'package:picsee/viewer_screen.dart';
import 'package:tflite/tflite.dart';

class Sort extends StatefulWidget {
  @override
  _Sort createState() => _Sort();
}

class _Sort extends State<Sort> {
  List<String> imageFiles = [];
  String root = '/storage/emulated/0';
  List<dynamic>? _outputs; // Make _outputs nullable by adding ?
  bool _loading = false;
  late File _image; // Declare _image variable

  @override
  void initState() {
    super.initState();
    initApp();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
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
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future<void> classifyImage(File image) async {
    List<dynamic>? output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context); // Store the Navigator instance
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
                        onPressed: () async {
                          if (!_loading) {
                            final selectedImageIndex = index;
                            setState(() {
                              _image = File(imageFiles[selectedImageIndex]);
                              _loading = true;
                            });
                            await classifyImage(_image);
                          }
                          final selectedImageIndex = index;
                          navigator.push(
                            MaterialPageRoute(
                              builder: (context) => ViewerScreen(
                                imageFiles: imageFiles,
                                initialIndex: selectedImageIndex,
                                tfliteOutputs: _outputs,
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
