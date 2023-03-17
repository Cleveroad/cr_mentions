import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    required this.onSaved,
    Key? key,
  }) : super(key: key);

  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onSaved,
      child: const Text(
        'Save',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
      ),
    );
  }
}
