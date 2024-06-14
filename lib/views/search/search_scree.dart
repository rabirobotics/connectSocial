import 'package:connect/models/post_model.dart';
import 'package:connect/utils/constant.dart';
import 'package:connect/views/search/search_post_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Make sure to import your Post model

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<Post>>? _searchStream;

  @override
  void initState() {
    super.initState();
    _searchStream = null; // Initially, no stream is set
  }

  void _performSearch(String query) {
    setState(() {
      _searchStream = FirebaseFirestore.instance
          .collection('posts')
          .where('content', isGreaterThanOrEqualTo: query)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _searchStream == null
          ? const Center(child: Text('Search Anything..'))
          : StreamBuilder<List<Post>>(
              stream: _searchStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final searchResults = snapshot.data;

                if (searchResults == null || searchResults.isEmpty) {
                  return const Center(child: Text('No results found'));
                }

                return ListView.builder(
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => SearchPostView(
                                    post: searchResults[index]))),
                        child: Card(
                          child: ListTile(
                            title: Text(
                              searchResults[index].content,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle:
                                Text("by ${searchResults[index].username}"),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: searchResults.length,
                );
              },
            ),
    );
  }
}
