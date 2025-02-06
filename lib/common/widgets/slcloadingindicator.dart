import 'package:flutter/material.dart';

class SLCLoadingIndicator extends StatelessWidget {
  final String? text;

  const SLCLoadingIndicator({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 20),
          if (text != null)
            Text(
              text!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }
}