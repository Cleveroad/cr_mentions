import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    required this.title,
    required this.child,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
