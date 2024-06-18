//import 'dart:ffi';

import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<StatefulWidget> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  ChatUser myself = ChatUser(id: "1", firstName: 'sarthak');
  ChatUser bot = ChatUser(id: "2", firstName: 'Gemini');
  List<ChatMessage> allMessages = [];
  List<ChatUser> typing = [];
  final oururl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=AIzaSyD2pHg79JrW3hNYJAsthysbmUcDnNWffP0';

  final header = {'Content-Type': 'application/json'};

  getdata(ChatMessage m) async {
    typing.add(bot);
    allMessages.insert(0, m);
    setState(() {});

    var data = {
      "contents": [
        {
          "parts": [
            {"text": m.text}
          ]
        }
      ]
    };

    await http
        .post(Uri.parse(oururl), headers: header, body: jsonEncode(data))
        .then((value) {
      if (value.statusCode == 200) {
        var result = jsonDecode(value.body);
        print(result['candidates'][0]['content']['parts'][0]['text']);

        ChatMessage m1 = ChatMessage(
            text: result['candidates'][0]['content']['parts'][0]['text'],
            user: bot,
            createdAt: DateTime.now());
        allMessages.insert(0, m1);
        setState(() {});
      } else {
        print("error occured");
      }
    }).catchError((e) {});
    typing.remove(bot);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ChatBot",
          style: TextStyle(
              fontSize: 25, color: Colors.white, fontWeight: FontWeight.w400),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple, // Customize background color
      ),
      body: DashChat(
          typingUsers: typing,
          currentUser: myself,
          onSend: (ChatMessage m) {
            getdata(m);
          },
          messages: allMessages),
    );
  }
}
