import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiOverlay.values as SystemUiMode);
}

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late List<ImageDetails> _images;

  @override
  void initState() {
    super.initState();
    _images = [];
    loadImages();
  }

  Future<void> loadImages() async {
    // Use image_picker to get images from the device
    final List<XFile>? imageFiles = await ImagePicker().pickMultiImage();

    if (imageFiles != null) {
      setState(() {
        _images = imageFiles
            .map((file) => ImageDetails(imageFile: File(file.path)))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                'Gallery',
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
                          topRight: Radius.circular(30))),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return RawMaterialButton(
                        onPressed: () {
                          // Handle image tap
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                              image: FileImage(_images[index].imageFile),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: _images.length,
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

class ImageDetails {
  final File imageFile;

  ImageDetails({
    required this.imageFile,
  });
}
