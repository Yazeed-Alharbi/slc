import 'package:flutter/material.dart';

class LLMTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("SLC"),
      ),
      body: Center(
        child: Text("Hello!"),
        )
      );
    throw UnimplementedError();
  }
}
