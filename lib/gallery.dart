import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:picsee/image.dart";

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiOverlay.values as SystemUiMode);
}

List<ImageDetails> _images = [
  ImageDetails(
    imagepath: 'images/1.jpg',
  ),
  ImageDetails(
    imagepath: 'images/2.jpg',
  ),
  ImageDetails(
    imagepath: 'images/3.jpg',
  ),
  ImageDetails(
    imagepath: 'images/4.jpg',
  ),
  ImageDetails(
    imagepath: 'images/5.jpg',
  ),
  ImageDetails(
    imagepath: 'images/6.jpg',
  ),
];

class gallery extends StatelessWidget {
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MyWidget(
                                  imagepath: _images[index].imagepath,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: AssetImage(_images[index].imagepath),
                                  fit: BoxFit.cover,
                                )),
                          ));
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
  final String imagepath;
  ImageDetails({
    required this.imagepath,
  });
}
