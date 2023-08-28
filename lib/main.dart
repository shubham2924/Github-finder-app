import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/singleTile.dart';
import 'package:debounce_throttle/debounce_throttle.dart';

void main() {
  runApp(const MyApp());
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter App Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(delay: Duration(seconds: 3));
  String _searchQuery = 'shubham'; // Default value

  List<dynamic> items = [];

  Future<void> fetchData() async {
    final response = await http
        .get(Uri.parse('https://api.github.com/search/users?q=$_searchQuery'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        items = data['items'];
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Github Users Finder'),
        ),
        //     body: Center(
        // ), // This trailing comma makes auto-formatting nicer for build methods.
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    _debouncer.run(() {
                      setState(() {
                        _searchQuery = text;
                        fetchData();
                      });
                    });
                  },
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    hintText: 'Search here',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            icon: Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: items.isNotEmpty
                      ? ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) => Card(
                            key: ValueKey(items[index]["id"]),
                            color: Colors.white,
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage:
                                    NetworkImage(items[index]['avatar_url']),
                              ),
                              title: Text(items[index]['login'],
                                  style: TextStyle(color: Colors.black)),
                              subtitle: Text(
                                  '${items[index]["html_url"].toString()}',
                                  style: TextStyle(color: Colors.black)),
                              trailing: Icon(Icons.arrow_circle_right_outlined),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(
                                      login: items[index]["login"],
                                      htmlUrl: items[index]["html_url"],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )

                      : const Text(
                          'No results found!',
                          style: TextStyle(fontSize: 24),
                        ),
                )
              ],
            )));
  }
}
