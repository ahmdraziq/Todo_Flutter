import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/Configuration/theme_config.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: themeMode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(
          brightness: Brightness.dark, accentColor: Colors.amber[100]),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDone;

  @override
  void initState() {
    // TODO: implement initState
    isDone = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                margin: EdgeInsets.fromLTRB(size.width * 0.03,
                    size.height * 0.08, size.width * 0.03, 0.0),
                height: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xff262626)),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: "Search",
                      border: InputBorder.none,
                      icon: Icon(Icons.search)),
                ),
              ),
              SizedBox(
                height: size.height * 0.04,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    size.width * 0.06, 0.0, size.width * 0.06, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "My Lists",
                      style: TextStyle(fontSize: 24),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        height: size.height * 0.045,
                        width: size.width * 0.3,
                        child: FlatButton(
                          child: Text("Add New List"),
                          color: Colors.blue,
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.04,
              ),
              FutureBuilder(
                future: getTodoList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      height: size.height * 0.7,
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              snapshot.data[index]['todotitle'],
                            ),
                            subtitle: Text(
                              snapshot.data[index]['description'],
                            ),
                            trailing: Checkbox(
                              value: isDone,
                              onChanged: (value) {
                                setState(() {
                                  isDone = value;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> getTodoList() async {
    var response = await http.get("http://192.168.1.67:5000/list");
    var json = jsonDecode(response.body);
    return json;
  }
}
