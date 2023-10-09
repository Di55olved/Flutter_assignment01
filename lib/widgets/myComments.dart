// ignore_for_file: prefer_const_constructors, avoid_types_as_parameter_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyComments extends StatefulWidget {
  const MyComments({super.key});

  @override
  State<MyComments> createState() => _MyCommentsState();
}

class Comments {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  const Comments({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comments.fromJson(Map<String, dynamic> json) {
    return Comments(
      postId: json['postId'],
      id: json['id'],
      name: json['name'],
      email: json['email'],
      body: json['body'],
    );
  }
}

class _MyCommentsState extends State<MyComments> {
  late Future<List<Comments>> futureComments;

  @override
  void initState() {
    super.initState();
    futureComments = fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Center(child: const Text('Comments')),
        ),
        body: Center(
          child: FutureBuilder<List<Comments>>(
              future: futureComments,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, i) {
                        var item = snapshot.data![i];
                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return ClipRRect(
                                    clipBehavior: Clip.hardEdge,
                                    child: SizedBox(
                                      width: MediaQuery.sizeOf(context).width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: [
                                            Text('Name: ${item.name}'),
                                            Text('Email: ${item.email}'),
                                            Text('Body: ${item.body}'),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '${item.id}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(item.name),
                            ),
                          ),
                        );
                      });
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return const CircularProgressIndicator();
              }),
        ));
  }
}

Future<List<Comments>> fetchComments() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

  if (response.statusCode == 200) {
    List<dynamic> _parseListJson = jsonDecode(response.body);
    List<Comments> _commentsList = List<Comments>.from(
        _parseListJson.map<Comments>((dynamic i) => Comments.fromJson(i)));
    return _commentsList;
  } else {
    throw Exception('Failed to load comments');
  }
}
