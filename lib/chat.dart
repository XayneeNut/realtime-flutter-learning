import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:webscoket_learning/model/message_data.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  IOWebSocketChannel? ioWebSocketChannel;
  bool? connected;

  List<MessageData> data = [];
  String name = "gusanta";

  TextEditingController userMessage = TextEditingController();

  @override
  void initState() {
    connected = false;
    userMessage.text = "";
    channelConnect();
    super.initState();
  }

  @override
  void dispose() {
    userMessage.dispose();
    super.dispose();
  }

  channelConnect() {
    try {
      ioWebSocketChannel =
          IOWebSocketChannel.connect('ws://10.0.2.2:8126/chat/$name');
      ioWebSocketChannel!.stream.listen(
        (message) {
          print(message);
          setState(
            () {
              if (message == "User $name as logged in") {
                connected = true;
                setState(() {});
                print("connection establised");
                print(message);
                print(connected);
              } else if (message == "$name : ${userMessage.text}") {
                print("message send success");
                var jsonData = json.decode(message);

                data.add(MessageData(message: jsonData, username: name));
                setState(() {});
              } else if (message == "User $name left on error :") {
                print("message send error");
              }
            },
          );
        },
      );
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> sendMessage(String sendMessage, String username) async {
    if (connected == true) {
      String message = "$name : ${userMessage.text}";
      setState(() {
        userMessage.text = "";
        data.add(MessageData(message: message, username: name));
      });
      ioWebSocketChannel!.sink.add(message);
    } else {
      channelConnect();
      print("Websocket is not connected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(" Chat App Example"),
          leading: Icon(
            Icons.circle,
          ),
          //if app is connected to node.js then it will be gree, else red.
          titleSpacing: 0,
        ),
        body: Container(
            child: Stack(
          children: [
            Positioned(
                top: 0,
                bottom: 70,
                left: 0,
                right: 0,
                child: Container(
                    padding: EdgeInsets.all(15),
                    child: SingleChildScrollView(
                        child: Column(
                      children: [
                        Container(
                          child: Text("Your Messages",
                              style: TextStyle(fontSize: 20)),
                        ),
                        Container(
                            child: Column(
                          children: data.map((onemsg) {
                            return Container(
                                child: Card(
                                    //if its my message then, blue background else red background
                                    child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text("Message: " + onemsg.message,
                                        style: TextStyle(fontSize: 17)),
                                  ),
                                ],
                              ),
                            )));
                          }).toList(),
                        ))
                      ],
                    )))),
            Positioned(
              //position text field at bottom of screen

              bottom: 0, left: 0, right: 0,
              child: Container(
                  color: Colors.black12,
                  height: 70,
                  child: Row(
                    children: [
                      Expanded(
                          child: Container(
                        margin: EdgeInsets.all(10),
                        child: TextField(
                          controller: userMessage,
                          decoration:
                              InputDecoration(hintText: "Enter your Message"),
                        ),
                      )),
                      Container(
                          margin: EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: Icon(Icons.send),
                            onPressed: () {
                              if (userMessage.text != "") {
                                sendMessage(userMessage.text,
                                    name); //send message with webspcket
                              } else {
                                print("Enter message");
                              }
                            },
                          ))
                    ],
                  )),
            )
          ],
        )));
  }
}
