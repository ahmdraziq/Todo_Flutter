import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                          onPressed: () {
                            displayFormDialog();
                          },
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
                          bool isDone = snapshot.data[index]['done'];
                          return GestureDetector(
                            onTap: () => displayInfo(snapshot.data[index]),
                            child: ListTile(
                              leading: Text(
                                (index + 1).toString(),
                              ),
                              title: Text(
                                snapshot.data[index]['id'],
                              ),
                              subtitle: Text(
                                snapshot.data[index]['todotitle'],
                              ),
                              trailing: Checkbox(
                                value: isDone,
                                onChanged: (value) {
                                  var json = {
                                    "id": snapshot.data[index]['id'],
                                    "done": value,
                                  };
                                  changeTodoStatus(json);

                                  setState(() {
                                    isDone = value;
                                  });
                                },
                              ),
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

  displayInfo(snapshot) {
    String id = snapshot['id'],
        title = snapshot['todotitle'],
        desc = snapshot['description'];
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 34.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: size.height * 0.35,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Identifier',
                        icon: Icon(
                          Icons.insert_drive_file,
                          color: Colors.white60,
                        ),
                      ),
                      controller: TextEditingController(text: id),
                      onChanged: (value) {
                        id = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(
                          Icons.title,
                          color: Colors.white60,
                        ),
                        border: InputBorder.none,
                        hintText: 'Todo-Title',
                      ),
                      controller: TextEditingController(text: title),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.description,
                            color: Colors.white60,
                          ),
                          border: OutlineInputBorder(),
                          hintText: "Description",
                        ),
                        controller: TextEditingController(text: desc),
                        onChanged: (value) {
                          desc = value;
                        },
                      ),
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: RaisedButton(
                        onPressed: () {
                          var json = {
                            "id": id,
                            "todotitle": title,
                            "description": desc,
                            "done": false,
                          };
                          updateTodoList(json);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  displayFormDialog() {
    String id = "", title = "", desc = "";
    Size size = MediaQuery.of(context).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            elevation: 34.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: Container(
              height: size.height * 0.35,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Identifier',
                        icon: Icon(Icons.insert_drive_file),
                      ),
                      onChanged: (value) {
                        id = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        border: InputBorder.none,
                        hintText: 'Todo-Title',
                      ),
                      onChanged: (value) {
                        title = value;
                      },
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        border: InputBorder.none,
                        hintText: "Description",
                      ),
                      onChanged: (value) {
                        desc = value;
                      },
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    SizedBox(
                      width: size.width * 0.9,
                      child: RaisedButton(
                        onPressed: () {
                          var json = {
                            "id": id,
                            "todotitle": title,
                            "description": desc,
                            "done": false,
                          };
                          createTodoList(json);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void changeTodoStatus(json) async {
    await http.put(
      "http://192.168.1.67:5000/update",
      headers: <String, String>{"Content-Type": "application/json"},
      body: jsonEncode(json),
    );
  }

  Future<dynamic> getTodoList() async {
    var response = await http.get("http://192.168.1.67:5000/list");
    var json = jsonDecode(response.body);
    return json;
  }

  void createTodoList(json) async {
    await http
        .post(
      "http://192.168.1.67:5000/add",
      headers: <String, String>{"Content-Type": "application/json"},
      body: jsonEncode(json),
    )
        .then((value) {
      var res = jsonDecode(value.body);
      if (value.statusCode == 201)
        showToast(res['status'].toString(), true);
      else
        showToast(res.toString(), false);

      (context as Element).reassemble();
    });
  }

  void updateTodoList(json) async {
    await http
        .put(
      "http://192.168.1.67:5000/update",
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(json),
    )
        .then((value) async {
      var res = jsonDecode(value.body);
      if (value.statusCode == 200)
        showToast(res['status'].toString(), true);
      else
        showToast(res.toString(), false);

      (context as Element).reassemble();
    });
  }

  showToast(String text, bool status) {
    FToast fToast = new FToast(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: status ? Colors.greenAccent : Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          status
              ? Icon(
                  Icons.check,
                  color: Colors.black87,
                )
              : Icon(
                  Icons.error_outline,
                  color: Colors.black87,
                ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 4),
    );
  }
}
