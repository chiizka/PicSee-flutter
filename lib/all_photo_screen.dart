import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picsee/viewer_screen.dart';

class AllPhotoScreen extends StatefulWidget {
  @override
  _AllPhotoScreenState createState() => _AllPhotoScreenState();
}

class _AllPhotoScreenState extends State<AllPhotoScreen>
    with AutomaticKeepAliveClientMixin<AllPhotoScreen> {
  List<String> imageFiles = [];
  String root = '/storage/emulated/0';
  bool _initialized = false;
  bool _initializedBefore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    checkInitializationFlag();
  }

  Future<void> checkInitializationFlag() async {
    print('Checking initialization flag...');
    await _readInitializationFlag();
    print('Initialized before: $_initializedBefore');
    if (!_initializedBefore) {
      print('App has not been initialized before. Initializing app...');
      await initApp();
    } else {
      print('App has been initialized before. Loading cached images...');
      imageFiles = await _readImagePathsFromFile();
      setState(() {
        _initialized = true;
      });
    }
  }

  Future<void> initApp() async {
    print('Initializing app...');
    await _findImageFilesRecursive(Directory(root));
    imageFiles.sort((a, b) {
      File fileA = File(a);
      File fileB = File(b);
      return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
    });
    await _writeImagePathsToFile(imageFiles);
    await _writeInitializationFlag(true);
    _initializedBefore = true;
    setState(() {
      _initialized = true;
    });
    print('Initialization complete.');
    print('Image files: $imageFiles');
  }

  Future<void> _findImageFilesRecursive(Directory directory) async {
    List<FileSystemEntity> entities = directory.listSync();
    for (FileSystemEntity entity in entities) {
      if (entity is File && _isImageFile(entity.path)) {
        imageFiles.add(entity.path);
      } else if (entity is Directory) {
        if (entity.path.endsWith('Android')) {
          continue;
        }
        await _findImageFilesRecursive(entity);
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

  Future<void> _writeImagePathsToFile(List<String> imagePaths) async {
    try {
      final file = await _getImagePathsFile();
      if (file != null) {
        file.writeAsStringSync(jsonEncode(imagePaths));
      }
    } catch (e) {
      print('Error writing image paths to file: $e');
    }
  }

  Future<List<String>> _readImagePathsFromFile() async {
    try {
      final file = await _getImagePathsFile();
      if (file != null && file.existsSync()) {
        String content = file.readAsStringSync();
        return List<String>.from(jsonDecode(content));
      }
    } catch (e) {
      print('Error reading image paths from file: $e');
    }
    return [];
  }

  Future<File?> _getImagePathsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/image_paths.json');
  }

  Future<void> _writeInitializationFlag(bool initialized) async {
    try {
      final file = await _getInitializationFlagFile();
      if (file != null) {
        file.writeAsStringSync(initialized ? '1' : '0');
      }
    } catch (e) {
      print('Error writing initialization flag to file: $e');
    }
  }

  Future<void> _readInitializationFlag() async {
    try {
      final file = await _getInitializationFlagFile();
      if (file != null && file.existsSync()) {
        String content = file.readAsStringSync();
        _initializedBefore = content.trim() == '1';
      }
    } catch (e) {
      print('Error reading initialization flag from file: $e');
    }
  }

  Future<File?> _getInitializationFlagFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/initialization_flag.txt');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 174, 106, 208),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 10,
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
              child: Builder(
                builder: (BuildContext context) {
                  if (!_initialized) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                        right: 10,
                      ),
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
                          final reversedIndex = imageFiles.length - 1 - index;
                          return RawMaterialButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewerScreen(
                                    imageFiles: imageFiles,
                                    initialIndex: reversedIndex,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  image: FileImage(File(imageFiles[reversedIndex])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: imageFiles.length,
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
