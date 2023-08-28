import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import './followersScreen.dart';
import 'package:intl/intl.dart';

class DetailsScreen extends StatefulWidget {
  final String login;
  final String htmlUrl;

  DetailsScreen({required this.login, required this.htmlUrl});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final apiURL = 'https://api.github.com/users/${widget.login}';
      final response = await http.get(Uri.parse(apiURL));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          String isoDateString = data!['updated_at'];
          DateTime dateTime = DateTime.parse(isoDateString);
          String formattedDate =
              DateFormat('dd-MM-yyyy, HH:mm | EEEE').format(dateTime);
          data!['updated_at'] = formattedDate;
          userData = data;
        });
        // Process the data or update the state
      } else {
        // Handle API error
      }
    } catch (error) {
      // Handle exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Details'),
        ),
        body: userData == null
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage('${userData!['avatar_url']}'),
                          radius: 120.0,
                        ),
                      ),
                      SizedBox(height: 40.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Name: ${userData!['name'] ?? "NA"}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Company: ${userData!['company'] ?? "NA"}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Blog: ${userData!['blog'] ?? "NA"}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Bio: ${userData!['bio'] ?? "NA"}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Public Repos: ${userData!['public_repos'].toString()}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Public Gists: ${userData!['public_gists'].toString()}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Location: ${userData!['location'] ?? "NA"}',
                            style: TextStyle(fontSize: 18.0)),
                      ),

                      ListTile(
                        title: Text(
                            'Followers: ${userData!['followers'].toString()}',
                            style:
                                TextStyle(color: Colors.black, fontSize: 18.0)),
                        trailing: Icon(Icons.arrow_circle_right_outlined),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FollowersDetailsScreen(
                                userID: userData!['login'],
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Following: ${userData!['following'].toString()}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Last Updated: ${userData!['updated_at']}',
                            style: TextStyle(fontSize: 18.0)),
                      ),
                      SizedBox(height: 20.0)
                      // Text('Surname: ${userData!['blog']}', style: TextStyle(fontSize: 18.0)),
                      // ),
                    ],
                  ),
                ),
              ));
  }
}
