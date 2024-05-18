import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picsee/viewer_screen.dart';

class ShowSearchScreen extends StatefulWidget {
  final Map<String, List<String>> tags;

  ShowSearchScreen({Key? key, required this.tags}) : super(key: key);

  @override
  _ShowSearchScreenState createState() => _ShowSearchScreenState();
}

class _ShowSearchScreenState extends State<ShowSearchScreen> {
  Map<String, List<String>> cachedImageAlbums = {}; // Store the cached image albums here
  Map<String, List<String>> filteredImageAlbums = {}; // Store the filtered image albums here

  @override
  void initState() {
    super.initState();
    print('Number of labels passed to this screen: ${widget.tags.length}');
    print('Labels passed to this screen: ${widget.tags.keys}');
    loadCachedImageAlbums();
  }

  Future<void> loadCachedImageAlbums() async {
    try {
      cachedImageAlbums = await readCachedImageAlbums();
      print('Number of labels read from cache: ${cachedImageAlbums.length}');
      print('Labels read from cache: ${cachedImageAlbums.keys}');
      filterCachedImageAlbums();
      setState(() {}); // Trigger a rebuild to display the labels
    } catch (e) {
      print('Error loading cached image albums: $e');
    }
  }

  void filterCachedImageAlbums() {
    filteredImageAlbums.clear(); // Clear the filtered albums first
    for (var passedTag in widget.tags.keys) {
      // Remove whitespace from the passed tag
      var cleanedPassedTag = passedTag.trim();
      // Check if the cleaned tag exists in the cached image albums
      for (var cachedTag in cachedImageAlbums.keys) {
        // Remove whitespace from the cached tag
        var cleanedCachedTag = cachedTag.trim();
        if (cleanedPassedTag.toLowerCase() == cleanedCachedTag.toLowerCase()) {
          // Perform case-insensitive comparison
          filteredImageAlbums[passedTag] = cachedImageAlbums[cachedTag]!;
          break; // Stop searching once a match is found
        }
      }
    }

    print('Number of labels after filtering: ${filteredImageAlbums.length}');
    print('Labels after filtering: ${filteredImageAlbums.keys}');
  }

  Future<Map<String, List<String>>> readCachedImageAlbums() async {
    try {
      final file = await _getCachedImageAlbumsFile();
      if (file != null && file.existsSync()) {
        String content = await file.readAsString();
        final decodedData = json.decode(content);
        if (decodedData is Map<String, dynamic>) {
          return decodedData.map((key, value) => MapEntry(key, List<String>.from(value)));
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

  Future<void> _navigateToViewerScreen(List<String> images, int initialIndex) async {
    // Load images asynchronously before navigating to the viewer screen
    await Future.wait(images.map((imagePath) => precacheImage(FileImage(File(imagePath)), context)));
    // Navigate to the viewer screen after images are loaded
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewerScreen(
          imageFiles: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          itemCount: filteredImageAlbums.length,
          itemBuilder: (context, index) {
            var tag = filteredImageAlbums.keys.elementAt(index);
            var images = filteredImageAlbums[tag] ?? [];
            var imageCount = images.length;

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
                SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        await _navigateToViewerScreen(images, index);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
