import 'dart:collection';

import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/utilities/database_helper.dart';

/// Static class in charge of handling the state of the settings screen.
/// This should not be used outside of the settings screen or its children.
///
/// Anything that changes in the settings screen and its children should be added
/// to this object as an operation. Once the settings screen is popped, this
/// object will run all of its operations at once. This makes sure that the database
/// saves everything and the user doesn't lose their data.
class EditableSectionsBrain {
  static List<Section> _sections = [];
  static List<Section> get sections => _sections;

  /// This contains the sections that have been deleted in this set of operations.
  /// Adding objects to this list is optional.
  ///
  /// When run() is called, this property will be passed in, and any items that belong
  /// to any of these sections will have their "section" property nulled out.
  static List<Section> _deletedSections = [];
  static final Queue<_Operation> _operations = Queue();

  /// Runs all queued operations in order.
  ///
  /// Once the operations are run, the brain is reset so it can take new operations.
  /// The old operations queue will be cleared.
  static Future<void> run() async {
    // Do not use forEach here, these functions need to be awaited.
    for (final op in _operations) {
      await op.function(op.arguments);
    }

    if (_operations.isNotEmpty) {
      await DatabaseHelper.replaceSectionsWith(
        _sections,
        deletedSections: _deletedSections,
      );
    }

    _operations.clear();
    _sections.clear();
    _deletedSections.clear();
  }

  /// Adds a new operation to the queue, which will only be run once run() is called.
  ///
  /// The first argument is a list of arguments for the function in the second argument.
  static void addOperation(
      List<Object> arguments, Future<void> Function(List<Object>) function) {
    _operations.add(_Operation(function: function, arguments: arguments));
  }

  static void setInitialSections(List<Section> initSections) {
    _sections = initSections;
  }

  /// This and [addDeletedSection] are needed since Dart will only pass by value.
  /// So you can't pass the lists in this class to other parts of the codebase and
  /// have changes affect the original.
  static void addSection(Section section) {
    _sections.add(section);
  }

  static void addSectionAt(int index, Section section) {
    _sections.insert(index, section);
  }

  /// This and [addSection] are needed since Dart will only pass by value.
  /// So you can't pass the lists in this class to other parts of the codebase and
  /// have changes affect the original.
  static void addDeletedSection(Section section) {
    _deletedSections.add(section);
  }

  static void removeSectionAt(int index) {
    _sections.removeAt(index);
  }

  /// Shortcut for inserting and removing at the specified indices.
  static void reorderSectionsAt(int oldIndex, int newIndex) {
    _sections.insert(newIndex, _sections.removeAt(oldIndex));
  }
}

/// Contains a set of arguments and a function to run them in. This is designed
/// to be used with the EditableSectionsBrain class.
class _Operation {
  _Operation({required this.function, required this.arguments});

  final Future<void> Function(List<Object>) function;
  final List<Object> arguments;
}

// Reordering
// setState(() {
//   // From the docs at https://api.flutter.dev/flutter/widgets/ReorderCallback.html:
//   // If oldIndex is before newIndex, removing the item at oldIndex
//   // from the list will reduce the list's length by one.
//   // Implementations will need to account for this when inserting
//   // before newIndex.
//   if (newIndex > oldIndex) newIndex--;
//   newSections.insert(newIndex, sections.removeAt(oldIndex));
// });

// Deleting (items must have a null section after this)
// setState(() {
//   final newSections = oldSections;
//   deletedSections.add(oldSections[index]);
//   newSections.removeAt(index);
// });

// Editing (items that belong to a section being edited must change their section property to the new section's title)
// items = oldItems
//       .where((item) => item.section == oldSection.title)
//       .toList();

// DatabaseHelper.updateSectionPropertyOf(items, newSection);
// setState(() {
//   newSections.removeAt(index);
//   newSections.insert(index, newSection);
// });

// call DatabaseHelper.replaceSectionsWith(sections, deletedSections) to complete the changes
// also call setState where needed!

// consider making all queued operations async so that they complete in order
