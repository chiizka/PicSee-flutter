
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:picsee/show_search.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> suggestedWords = [];
  late TextEditingController _searchController;
  Set<String> selectedTags = Set<String>();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    getSuggestedWords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getSuggestedWords() async {
    try {
      final String data = await rootBundle.loadString('assets/labels.txt');
      final List<String> lines = data.split('\n');
      setState(() {
        suggestedWords = lines;
      });
    } catch (e) {
      print('Error reading file: $e');
    }
  }

  void toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
      _updateSearchBar();
    });
  }

  void _updateSearchBar() {
    String searchQuery = selectedTags.join(' ');
    _searchController.text = searchQuery;
  }

  void _searchImages() {
  // Ensure selectedTags is a Map<String, List<String>>
  Map<String, List<String>> selectedTagsMap = {
    for (var tag in selectedTags) tag: []
  };

  // Navigate to the screen where you want to show the search results
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShowSearchScreen(tags: selectedTagsMap),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: false,
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: _searchImages,
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Update selectedTags based on the content of the TextField
                  List<String> updatedTags = value.split(' ');
                  setState(() {
                    selectedTags.clear();
                    selectedTags
                        .addAll(updatedTags.where((tag) => tag.isNotEmpty));
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ), // Add some space between the search bar and the "Sample Tags" text
              Text(
                'Sample Tags',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 10,
              ), // Add some space between the "Sample Tags" text and the tag buttons
              Expanded(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: suggestedWords.map((tag) {
                    bool isSelected = selectedTags.contains(tag);
                    return ElevatedButton(
                      onPressed: () {
                        toggleTag(tag);
                      },
                      style: ButtonStyle(
                        backgroundColor: isSelected
                            ? MaterialStateProperty.all<Color>(Colors.blue)
                            : null,
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}