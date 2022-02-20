import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/models/editable_sections_brain.dart';
import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/screens/section_dialog.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/utilities/util.dart';
import 'package:shopping_list/widgets/warning_dialog.dart';

class ReorderableSection extends StatefulWidget {
  ReorderableSection({
    required this.listIndex,
    required this.reorderableSections,
    required this.key,
    required this.section,
    required this.onChangeState,
  });

  final int listIndex;
  final List<Section> reorderableSections;
  final Key key;
  final Section section;
  final Function(List<Section>) onChangeState;

  @override
  _ReorderableSectionState createState() => _ReorderableSectionState();
}

class _ReorderableSectionState extends State<ReorderableSection> {
  Future<void> editSection() async {
    // As a post mortem note, you could have offloaded all this functionality to
    // the editable sections brain.
    final sections = widget.reorderableSections;

    Section? section = await showDialog(
      context: context,
      builder: (context) => SectionDialog(
        section: widget.section,
        sections: sections,
      ),
    );

    if (section != null) {
      sections.removeAt(widget.listIndex);
      sections.insert(widget.listIndex, section);

      EditableSectionsBrain.addOperation(
        [widget.section, section, widget.listIndex],
        (args) async {
          final query = await DatabaseHelper.getItemBank();
          final oldSection = args[0] as Section;
          final newSection = args[1] as Section;
          final index = args[2] as int;
          final items =
              query.where((item) => item.section == oldSection.title).toList();

          await DatabaseHelper.updateSectionPropertyOf(items, newSection);

          EditableSectionsBrain.addSectionAt(index, section);
          EditableSectionsBrain.removeSectionAt(index + 1);
        },
      );

      widget.onChangeState(sections);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.key,
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) {
            return WarningDialog(
              content:
                  'Deleting the ${widget.section.title.capitalize()} section will not delete the items in that section.',
              buttonText: 'Delete',
              isDestructive: true,
            );
          },
        );
      },
      onDismissed: (_) {
        final sections = widget.reorderableSections;

        sections.removeAt(widget.listIndex);

        EditableSectionsBrain.addOperation(
          [widget.listIndex],
          (args) async {
            final sections = EditableSectionsBrain.sections;
            final index = args[0] as int;
            EditableSectionsBrain.addDeletedSection(sections[index]);
            EditableSectionsBrain.removeSectionAt(index);
          },
        );

        widget.onChangeState(sections);
      },
      child: GestureDetector(
        onLongPress: () async {
          await editSection();
        },
        child: ListTile(
          key: ObjectKey(widget.section),
          title: Row(
            children: [
              Icon(Icons.circle, color: widget.section.color),
              SizedBox(width: 20),
              Text(widget.section.title.capitalize()),
            ],
          ),
          trailing: ReorderableDragStartListener(
            index: widget.listIndex,
            child: Icon(Icons.menu),
          ),
        ),
      ),
    );
  }
}
