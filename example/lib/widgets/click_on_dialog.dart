import 'package:flutter/material.dart';

class ClickOnDialog extends StatelessWidget {
  const ClickOnDialog({
    required this.content,
    Key? key,
  }) : super(key: key);

  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const Text(
            'You clicked on:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            content,
            style: const TextStyle(color: Colors.deepOrange),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Ok',
            style: TextStyle(color: Colors.deepOrange),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
