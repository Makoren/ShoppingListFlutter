import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/screens/section_dialog.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/section_dropdown.dart';

class ItemDialog extends StatefulWidget {
  ItemDialog({required this.title, this.item, required this.items});

  final String title;
  final Item? item;
  final List<Item> items;

  @override
  _ItemDialogState createState() => _ItemDialogState();
}

class _ItemDialogState extends State<ItemDialog> {
  // If an item has been passed in, fill the form with its contents
  late final _descController = TextEditingController(
    text: widget.item != null ? widget.item!.description : '',
  );

  late final _nameController = TextEditingController(
    text: widget.item != null ? widget.item!.name : '',
  );

  late final _quantityController = TextEditingController(
    text: widget.item != null ? widget.item!.quantity.toString() : '',
  );

  late String? _selectedSection =
      widget.item != null ? widget.item!.section : null;

  late bool _isCompleted =
      widget.item != null ? widget.item!.isCompleted : false;

  late bool _isMarkedForGenerate =
      widget.item != null ? widget.item!.isMarkedForGenerate : false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(hintText: 'Enter an item name...'),
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(hintText: 'Enter a description...'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(hintText: 'Quantity...'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            Row(
              children: [
                Expanded(
                  child: SectionDropdown(
                    initialSection: _selectedSection,
                    onChanged: (newValue) {
                      // newValue can be null if the user selects "no section".
                      // Do not use setState! It's already being called in SectionDropdown, and AddItemScreen's UI does not need to be rebuilt.
                      _selectedSection = newValue;
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () async {
                    final sections = await DatabaseHelper.getSections();
                    final resultingSection = await showDialog<Section>(
                      context: context,
                      builder: (context) => SectionDialog(sections: sections),
                    );

                    // Should only ever be null if the alert is cancelled.
                    if (resultingSection != null) {
                      await DatabaseHelper.insertIntoSections(resultingSection);
                      setState(() {});
                    }
                  },
                )
              ],
            ),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    Text('Mark for Generate?'),
                    Checkbox(
                      value: _isMarkedForGenerate,
                      onChanged: (newValue) {
                        setState(() {
                          _isMarkedForGenerate = !_isMarkedForGenerate;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            TextButton(
              child: Text('Done'),
              onPressed: () async {
                final quantityNum = int.tryParse(_quantityController.text);
                bool isValid = true;

                // Check if correctly parsed, and check that it doesn't go over the maximum limit
                if (quantityNum == null) {
                  _quantityController.clear();
                  return;
                } else if (quantityNum >= 1000) {
                  _quantityController.clear();
                  return;
                }

                for (final item in widget.items) {
                  if (item.name.toLowerCase() ==
                          _nameController.text.toLowerCase() ||
                      _nameController.text.isEmpty) {
                    isValid = false;
                    if (widget.item != null &&
                        widget.item!.name.toLowerCase() ==
                            _nameController.text.toLowerCase()) {
                      isValid = true;
                    } else {
                      _nameController.clear();
                    }
                  }
                }

                if (isValid) {
                  Navigator.pop(
                    context,
                    Item(
                      id: widget.item != null
                          ? widget.item!.id
                          : DateTime.now().millisecondsSinceEpoch,
                      name: _nameController.text,
                      description: _descController.text,
                      quantity: quantityNum,
                      section: _selectedSection,
                      isCompleted: _isCompleted,
                      isMarkedForGenerate: _isMarkedForGenerate,
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
