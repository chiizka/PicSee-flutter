import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
  Map<String, List<String>> cachedImageAlbums = {};
  Map<String, List<String>> filteredImageAlbums = {};
  StreamController<Map<String, List<String>>> _filteredAlbumsController = StreamController.broadcast();
  static Map<String, List<String>> _memoryCache = {};

  @override
  void initState() {
    super.initState();
    print('Number of labels passed to this screen: ${widget.tags.length}');
    print('Labels passed to this screen: ${widget.tags.keys}');
    loadCachedImageAlbums();
  }

  @override
  void dispose() {
    _filteredAlbumsController.close();
    super.dispose();
  }

  Future<void> loadCachedImageAlbums() async {
    try {
      if (_memoryCache.isNotEmpty) {
        cachedImageAlbums = _memoryCache;
      } else {
        cachedImageAlbums = await readCachedImageAlbums();
        _memoryCache = cachedImageAlbums;
      }
      print('Number of labels read from cache: ${cachedImageAlbums.length}');
      print('Labels read from cache: ${cachedImageAlbums.keys}');
      filterCachedImageAlbums();
    } catch (e) {
      print('Error loading cached image albums: $e');
    }
  }

  void filterCachedImageAlbums() {
    filteredImageAlbums.clear();
    for (var passedTag in widget.tags.keys) {
      var cleanedPassedTag = passedTag.trim();
      for (var cachedTag in cachedImageAlbums.keys) {
        var cleanedCachedTag = cachedTag.trim();
        if (cleanedPassedTag.toLowerCase() == cleanedCachedTag.toLowerCase()) {
          filteredImageAlbums[passedTag] = cachedImageAlbums[cachedTag]!;
          break;
        }
      }
    }
    _filteredAlbumsController.add(filteredImageAlbums);
  }

  Future<Map<String, List<String>>> readCachedImageAlbums() async {
    int retries = 5;
    while (retries > 0) {
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
        break;
      } catch (e) {
        print('Error reading cached image albums from file: $e');
        await Future.delayed(Duration(milliseconds: 500)); // Retry after delay
        retries--;
      }
    }
    return {};
  }

  Future<File?> _getCachedImageAlbumsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/cached_image_albums.json');
  }

  Future<void> _navigateToViewerScreen(List<String> images, int initialIndex) async {
    try {
      await Future.wait(images.map((imagePath) => precacheImage(FileImage(File(imagePath)), context)));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewerScreen(
            imageFiles: images,
            initialIndex: initialIndex,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to viewer screen: $e');
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: StreamBuilder<Map<String, List<String>>>(
          stream: _filteredAlbumsController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading images: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No images found'));
            }

            var filteredImageAlbums = snapshot.data!;
            return ListView.builder(
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
                    PaginatedGrid(images: images),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class PaginatedGrid extends StatefulWidget {
  final List<String> images;

  PaginatedGrid({required this.images});

  @override
  _PaginatedGridState createState() => _PaginatedGridState();
}

class _PaginatedGridState extends State<PaginatedGrid> {
  ScrollController _scrollController = ScrollController();
  List<String> _displayedImages = [];
  int _currentMax = 20;

  @override
  void initState() {
    super.initState();
    _loadMoreImages();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreImages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreImages() {
    setState(() {
      int nextMax = _currentMax + 20;
      if (nextMax > widget.images.length) {
        nextMax = widget.images.length;
      }
      _displayedImages = widget.images.sublist(0, nextMax);
      _currentMax = nextMax;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: _displayedImages.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            await _navigateToViewerScreen(_displayedImages, index);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(
              File(_displayedImages[index]),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text('Error loading image'));
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToViewerScreen(List<String> images, int initialIndex) async {
    try {
      await Future.wait(images.map((imagePath) => precacheImage(FileImage(File(imagePath)), context)));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewerScreen(
            imageFiles: images,
            initialIndex: initialIndex,
          ),
        ),
      );
    } catch (e) {
      print('Error navigating to viewer screen: $e');
    }
  }
}
