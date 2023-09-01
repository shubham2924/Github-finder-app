import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test_flutter_app/screens/webViewScreen.dart';
import 'dart:convert';
import './followersScreen.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatefulWidget {
  final String login;
  final String htmlUrl;

  DetailsScreen({required this.login, required this.htmlUrl});

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  Map<String, dynamic>? userData;

  void _handleURLButtonPress(BuildContext context, String url) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }

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
    const fontSize=18.0;
    const sizedBoxHeight=20.0;
    return Scaffold(
        appBar: AppBar(
          title: const Text('User Details'),
            actions: [
        IconButton(
        icon: const Icon(
        Icons.ios_share,
            color: Color(0xFF2F2F2F),
            size: 34.0),
        onPressed: (){
          Share.share('${userData!['html_url']}', subject: 'User Profile');
          //subject is optional, and it is required for Email App.
        }
    )]
        ),
        body: userData == null
            ? const Center(child: CircularProgressIndicator())
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
                      const SizedBox(height: 40.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Name: ${userData!['name'] ?? "NA"}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Company: ${userData!['company'] ?? "NA"}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Blog: ${userData!['blog'] ?? "NA"}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Bio: ${userData!['bio'] ?? "NA"}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Public Repos: ${userData!['public_repos'].toString()}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Public Gists: ${userData!['public_gists'].toString()}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                            'Location: ${userData!['location'] ?? "NA"}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),

                      ListTile(
                        title: Text(
                            'Followers: ${userData!['followers'].toString()}',
                            style:
                                const TextStyle(color: Colors.black, fontSize: 18.0)),
                        trailing: const Icon(Icons.arrow_circle_right_outlined),
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
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text('Last Updated: ${userData!['updated_at']}',
                            style: const TextStyle(fontSize: fontSize)),
                      ),
                      const SizedBox(height: sizedBoxHeight),
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                            onPressed: () => _handleURLButtonPress(context, userData!['html_url']),
                            child: const Text("Open in Web")),
                      )
                    ],
                  ),
                ),
              ));
  }
}
