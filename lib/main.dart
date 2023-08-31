import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'screens/singleTile.dart';

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
  int currentPage=1;
  final listViewController= ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(delay: const Duration(seconds: 3));
  String _searchQuery = 'john'; // Default value
  bool _isLoading = false;
  bool _isTextFieldCleared = false;
  bool _isReachedEnd=false;
  bool _isTextChanged=false;

  List<dynamic> items = [];

  Future<void> fetchData() async {
    setState(() {
      if(_isReachedEnd==true){
        _isLoading = false;
      }
      else{
        if(_isTextChanged==true){
          _isLoading = true;
        }
      }

    });
    try {
      final response = await http
          .get(
          Uri.parse('https://api.github.com/search/users?q=$_searchQuery&page=$currentPage'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if(_isTextFieldCleared==true || _isTextChanged==true){
            currentPage=1;
            items = data['items'];
          }
          else {
            items.addAll(data['items']);
          }
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    }
    catch (error) {
      print(error);
    }
    finally{
      setState(() {
        _isLoading = false;
        currentPage++;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    listViewController.addListener(() {
      if(listViewController.position.maxScrollExtent==listViewController.offset){
        setState(() {
          _isReachedEnd=true;
          _isTextChanged=false;
          _isTextFieldCleared=false;
        });
        fetchData();
      }
    });
  }

  @override
  void dispose(){
    listViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inputBoxOutlineWidth=1.0;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Github Users Finder'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (text) {
                    _debouncer.run(() {
                      setState(() {
                        _isTextChanged=true;
                        currentPage=1;
                        _isLoading = true;
                        _searchQuery = text;
                        fetchData();
                      });
                    });
                  },
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: inputBoxOutlineWidth),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: inputBoxOutlineWidth),
                    ),
                    hintText: 'Search here',
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _isTextFieldCleared=true;
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: _isLoading? const Center(child: CircularProgressIndicator()):

                  items.isNotEmpty
                      ? ListView.builder(
                    controller: listViewController,
                          itemCount: items.length+1,
                          itemBuilder: (context, index) {
                            if(index<items.length){
                            return Card(
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
                                  style: const TextStyle(color: Colors.black)),
                              subtitle: Text(
                                  items[index]["html_url"].toString(),
                                  style: const TextStyle(color: Colors.black)),
                              trailing: const Icon(Icons.arrow_circle_right_outlined),
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
                          );
  }
                            else{
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(child: CircularProgressIndicator())
                              ) ;
                            }
                            },
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
