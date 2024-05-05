import 'package:flutter/material.dart';

class ShowSearchScreen extends StatelessWidget {
  final List<String> tags;

  const ShowSearchScreen({Key? key, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Selected Tags:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
