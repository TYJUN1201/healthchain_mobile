import 'package:flutter/material.dart';

class Confirmation extends StatelessWidget {
  final String title;
  final Widget body; // Change from String to Widget

  Confirmation({Key? key, required this.title, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: body, // Use the provided Widget for the content
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // User cancelled
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // User confirmed
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  static Future<bool?> showConfirmationDialog(
      BuildContext context,
      String title,
      Widget body, // Change from String to Widget
      ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Confirmation(title: title, body: body);
      },
    );
  }
}
