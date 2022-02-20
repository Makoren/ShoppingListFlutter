import 'package:flutter/material.dart';
import 'package:shopping_list/models/editable_sections_brain.dart';
import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/screens/section_dialog.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/reorderable_section.dart';

class SectionsScreen extends StatefulWidget {
  @override
  _SectionsScreenState createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  List<Section>? sectionState;

  void initSections() async {
    final query = await DatabaseHelper.getSections();
    final sections = List<Section>.from(query);
    EditableSectionsBrain.setInitialSections(sections);
    setState(() {
      sectionState = List<Section>.from(query);
    });
  }

  @override
  void initState() {
    super.initState();
    initSections();
  }

  @override
  Widget build(BuildContext context) {
    if (sectionState != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Sections'),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            final resultingSection = await showDialog<Section>(
              context: context,
              builder: (context) => SectionDialog(sections: sectionState!),
            );

            if (resultingSection != null) {
              setState(() {
                sectionState!.add(resultingSection);
              });
              // add an operation to the brain
              EditableSectionsBrain.addOperation([resultingSection],
                  (args) async {
                EditableSectionsBrain.addSection(args[0] as Section);
              });
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: WillPopScope(
          onWillPop: () async {
            await EditableSectionsBrain.run();
            Navigator.pop(context);
            return false;
          },
          child: ReorderableListView.builder(
            itemCount: sectionState!.length,
            itemBuilder: (context, index) {
              return ReorderableSection(
                listIndex: index,
                reorderableSections: List.from(sectionState!),
                key: ObjectKey(sectionState![index]),
                section: sectionState![index],
                onChangeState: (newSections) {
                  // this will run after editing the section happens
                  setState(() {
                    sectionState = List<Section>.from(newSections);
                  });
                },
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              setState(() {
                sectionState!
                    .insert(newIndex, sectionState!.removeAt(oldIndex));
              });

              EditableSectionsBrain.addOperation(
                [oldIndex, newIndex],
                (args) async {
                  final oldIndex = args[0] as int;
                  var newIndex = args[1] as int;
                  EditableSectionsBrain.reorderSectionsAt(oldIndex, newIndex);
                },
              );
            },
          ),
        ),
      );
    } else {
      return Center(child: Text('Loading...'));
    }
  }
}
