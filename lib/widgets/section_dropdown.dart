import 'package:flutter/material.dart';
import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/utilities/util.dart';

/// A dropdown list that queries the "section" table in the database when built.
class SectionDropdown extends StatefulWidget {
  SectionDropdown({
    this.initialSection,
    required this.onChanged,
  });

  final String? initialSection;
  final void Function(String?) onChanged;

  @override
  _SectionDropdownState createState() => _SectionDropdownState();
}

class _SectionDropdownState extends State<SectionDropdown> {
  String? _selectedSection;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Section>>(
      future: DatabaseHelper.getSections(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
          case ConnectionState.active:
            final dropdownMenuItems = snapshot.data!
                .map(
                  (section) => DropdownMenuItem<String>(
                    // The "value" property is the only thing that needs to conform to the type of String.
                    // The child can be any widget that you want to represent that value.
                    child: Row(
                      children: [
                        Text(section.title.capitalize()),
                        Icon(Icons.circle, color: section.color),
                      ],
                    ),
                    value: section.title,
                  ),
                )
                .toList();

            // Add a button for users to click even if no sections have been made yet
            dropdownMenuItems.add(DropdownMenuItem<String>(
              child: Text('No Section'),
              value: null,
            ));

            _selectedSection = widget.initialSection;

            // set initial value on the parent if needed
            widget.onChanged(_selectedSection);

            // This needs to be here otherwise _selectedSection gets reset after changing the dropdown value.
            return StatefulBuilder(
              builder: (context, setState) {
                return DropdownButton<String>(
                  items: dropdownMenuItems,
                  value: _selectedSection,
                  disabledHint: Text('Create a section...'),
                  onChanged: (newValue) {
                    setState(() {
                      widget.onChanged(newValue);
                      _selectedSection = newValue;
                    });
                  },
                );
              },
            );

          case ConnectionState.waiting:
            return Text('Loading...');

          case ConnectionState.none:
            return Text('Error!');
        }
      },
    );
  }
}
