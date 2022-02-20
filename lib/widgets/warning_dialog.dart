import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class WarningDialog extends StatelessWidget {
  WarningDialog({
    required this.content,
    required this.buttonText,
    required this.isDestructive,
  });

  final String content;
  final String buttonText;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    // TODO: Need material design on Android
    return CupertinoAlertDialog(
      title: Text('Are you sure?'),
      content: Text(content),
      actions: [
        CupertinoDialogAction(
          child: Text('Cancel'),
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        CupertinoDialogAction(
            child: Text(buttonText),
            isDestructiveAction: isDestructive,
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              Navigator.of(context).pop(true);
            }),
      ],
    );
  }
}
