import 'package:flutter/material.dart';
import 'package:shopping_list/models/section.dart';

class SectionDialog extends StatefulWidget {
  SectionDialog({
    required this.sections,
    this.section,
  });

  /// If this is not null, the contents of the section dialog will be filled with the section's properties.
  final Section? section;

  /// This is required so you can check for duplicates and generate an ID. Query the database to get sections from it.
  final List<Section> sections;

  @override
  _SectionDialogState createState() => _SectionDialogState();
}

class _SectionDialogState extends State<SectionDialog> {
  late final controller = TextEditingController(
    text: widget.section != null ? widget.section!.title : '',
  );

  late Color currentColor =
      widget.section != null ? widget.section!.color : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Section'),
            TextField(
              onTap: () => print('tappy'),
              controller: controller,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                      currentColor.value == Colors.red.value
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: Colors.red),
                  onPressed: () {
                    setState(() {
                      currentColor = Colors.red;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                      currentColor.value == Colors.blue.value
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      currentColor = Colors.blue;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                      currentColor.value == Colors.green.value
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: Colors.green),
                  onPressed: () {
                    setState(() {
                      currentColor = Colors.green;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                      currentColor.value == Colors.orange.value
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: Colors.orange),
                  onPressed: () {
                    setState(() {
                      currentColor = Colors.orange;
                    });
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    // check for duplicates and empty strings, case insensitive
                    // but only if a section is being added, not edited

                    // will also check if the character limit (16) isn't breached
                    bool isValid = true;

                    if (widget.section == null) {
                      for (final section in widget.sections) {
                        if (section.title.toLowerCase() ==
                                controller.text.toLowerCase() ||
                            controller.text.isEmpty) {
                          isValid = false;
                          controller.clear();
                        }
                      }
                    }

                    if (controller.text.length > 16) {
                      isValid = false;
                      controller.clear();
                    }

                    if (isValid)
                      Navigator.pop(
                          context,
                          Section(
                            id: widget.section != null
                                ? widget.section!.id
                                : widget.sections.length,
                            title: controller.text,
                            color: currentColor,
                          ));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
