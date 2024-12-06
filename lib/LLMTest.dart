import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LLMTest extends StatefulWidget {
  @override
  State<LLMTest> createState() => _LLMTestState();
}

class _LLMTestState extends State<LLMTest> {
  final TextEditingController _controller = TextEditingController();
  String? responseMessage;

  Future<void> sendTextToCloudFunction(String text) async {
  final url = Uri.parse("https://process-text-ypakisdn3a-uc.a.run.app");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"text": text}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        responseMessage = responseData["reply"];
      });
    } else {
      setState(() {
        responseMessage = "Error: ${response.body}";
      });
    }
  } catch (e) {
    setState(() {
      responseMessage = "An error occurred: $e";
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("SLC"),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Write a message to the LLM:"),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Enter your message",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String enteredValue = _controller.text;
                  if (enteredValue.isNotEmpty) {
                    sendTextToCloudFunction(enteredValue);
                  } else {
                    setState(() {
                      responseMessage = "Please enter a message.";
                    });
                  }
                },
                child: Text("Send"),
              ),
              SizedBox(height: 20),
              if (responseMessage != null)
                Text(
                  responseMessage!, 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
