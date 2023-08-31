import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FollowersDetailsScreen extends StatefulWidget {
  final String userID;

  FollowersDetailsScreen({required this.userID});

  @override
  _FollowersDetailsScreenState createState() => _FollowersDetailsScreenState();
}

class _FollowersDetailsScreenState extends State<FollowersDetailsScreen> {
  List<dynamic> followers = [];

  @override
  void initState() {
    super.initState();
    fetchFollowersData();
  }

  Future<void> fetchFollowersData() async {
    final response = await http.get(
        Uri.parse('https://api.github.com/users/${widget.userID}/followers'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        followers = data;
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
      ),
      body: followers == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: followers.isNotEmpty
                        ? ListView.builder(
                            itemCount: followers.length,
                            itemBuilder: (context, index) => Card(
                              key: ValueKey(followers[index]["id"]),
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      followers[index]['avatar_url']),
                                ),
                                title: Text(followers[index]['login'],
                                    style: const TextStyle(color: Colors.black)),
                                subtitle: Text(
                                    followers[index]["html_url"].toString(),
                                    style: const TextStyle(color: Colors.black)),
                              ),
                            ),
                          )

                        : const Center(child: CircularProgressIndicator()),
                  )
                ],
              )),
    );
  }
}
