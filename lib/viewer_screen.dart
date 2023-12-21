import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ViewerScreen extends StatefulWidget {
  final List<String> imageFiles;
  final int initialIndex;

  const ViewerScreen({
    required this.imageFiles,
    required this.initialIndex,
  });

  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late Future<FileStat> _currentImageStat;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentImageStat = _getImageStat(widget.initialIndex);
  }

  Future<FileStat> _getImageStat(int index) async {
    File imageFile = File(widget.imageFiles[index]);
    return await imageFile.stat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageFiles.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _currentImageStat = _getImageStat(index);
              });
            },
            itemBuilder: (context, index) {
              return FutureBuilder<FileStat>(
                future: _currentImageStat,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Image.file(
                      File(widget.imageFiles[index]),
                      fit: BoxFit.contain,
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              title: FutureBuilder<FileStat>(
                future: _currentImageStat,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    DateTime creationDate = snapshot.data!.modified;
                    String formattedDate =
                        DateFormat('MMMM d, yyyy').format(creationDate);
                    String formattedTime =
                        DateFormat('h:mm a').format(creationDate);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          formattedTime,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    );
                  } else {
                    return Text('Image Viewer');
                  }
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
