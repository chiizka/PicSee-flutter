import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ShowSearchScreen extends StatefulWidget {
  final List<String> tags;

  ShowSearchScreen({Key? key, required this.tags}) : super(key: key);

  @override
  _ShowSearchScreenState createState() => _ShowSearchScreenState();
}

class _ShowSearchScreenState extends State<ShowSearchScreen> {
  Map<String, List<String>> cachedImageAlbums = {}; // Store the cached image albums here
  int cachedLabelCount = 0;

  @override
  void initState() {
    super.initState();
    print('Number of labels passed to this screen: ${widget.tags.length}');
    print('Labels passed to this screen: ${widget.tags}');
    loadCachedImageAlbums();
  }

  Future<void> loadCachedImageAlbums() async {
    try {
      cachedImageAlbums = await readCachedImageAlbums();
      cachedLabelCount = cachedImageAlbums.length;
      print('Number of labels read from cache: $cachedLabelCount');
      print('Labels read from cache: ${cachedImageAlbums.keys}');
      setState(() {}); // Trigger a rebuild to display the labels
    } catch (e) {
      print('Error loading cached image albums: $e');
    }
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cachedImageAlbums.keys.map((tag) {
            return Padding(
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
                    '(${cachedImageAlbums[tag]?.length ?? 0} images)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
