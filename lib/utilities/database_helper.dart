import 'dart:async';

import 'package:shopping_list/models/editable_sections_brain.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/models/section.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static late final Database _db;
  // Constants
  static const String _dbName = 'database.db';

  static final _itemBankController = StreamController<List<Item>>.broadcast();
  static const String _itemBankDescription = 'description';
  static const String _itemBankId = 'id';
  static const String _itemBankIsCompleted = 'isCompleted';
  static const String _itemBankIsMarkedForGenerate = 'isMarkedForGenerate';
  // Other properties
  static int _itemBankLength = 0;

  static const String _itemBankName = 'name';
  static const String _itemBankQuantity = 'quantity';
  static const String _itemBankSection = 'section';
  static const String _itemBankTableName = 'itemBank';
  static const String _sectionsColor = 'color';
  static final _sectionsController =
      StreamController<List<Section>>.broadcast();

  static const String _sectionsId = 'id';
  static int _sectionsLength = 0;
  static const String _sectionsTableName = 'sections';
  static const String _sectionsTitle = 'title';

  // Always use this after a query, not before it.
  static int get itemBankLength => _itemBankLength;

  // Always use this after a query, not before it.
  static int get sectionsLength => _sectionsLength;

  static Future<void> open() async {
    try {
      _db = await openDatabase(
        join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async {
          await db.execute('''
      CREATE TABLE $_itemBankTableName(
        $_itemBankId INTEGER PRIMARY KEY,
        $_itemBankName TEXT,
        $_itemBankDescription TEXT,
        $_itemBankQuantity INTEGER,
        $_itemBankSection TEXT,
        $_itemBankIsCompleted INTEGER(1),
        $_itemBankIsMarkedForGenerate INTEGER(1)
      )
      ''');

          await db.execute('''
      CREATE TABLE $_sectionsTableName(
        $_sectionsId INTEGER PRIMARY KEY,
        $_sectionsTitle TEXT,
        $_sectionsColor INTEGER
      )
      ''');
        },
        version: 1,
      );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> insertIntoItemBank(Item item) async {
    try {
      await _db.insert(
        _itemBankTableName,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      updateItemBankStream();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> insertIntoSections(Section section) async {
    try {
      await _db.insert(
        _sectionsTableName,
        section.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      updateSectionsStream();
    } catch (e) {
      print(e);
    }
  }

  // Querying
  static Future<List<Item>> getItemBank() async {
    try {
      final query = await _db.query(_itemBankTableName);
      final newList = List<Item>.generate(
        query.length,
        (index) => Item.fromMap(query[index]),
      );
      return Future.value(newList);
    } catch (e) {
      print(e);
      print(
          'Unknown error when querying the $_itemBankTableName table. Returning an empty list.');
    }
    return [];
  }

  static Future<List<Section>> getSections() async {
    try {
      final query =
          await _db.query(_sectionsTableName, orderBy: '$_sectionsId ASC');
      final newList = List<Section>.generate(
        query.length,
        (index) => Section.fromMap(query[index]),
      );
      return Future.value(newList);
    } catch (e) {
      print(e);
      print(
          'Unknown error when querying the $_sectionsTableName table. Returning an empty list.');
    }
    return [];
  }

  /// Adds a new query to the [itemBankStream] stream.
  ///
  /// As a rule of thumb, put this in any DatabaseHelper method that modifies the database contents so that the main screen is properly updated.
  static void updateItemBankStream() async {
    try {
      final query = await getItemBank();
      _itemBankLength = query.length;
      _itemBankController.sink.add(query);
    } catch (e) {
      print(e);
    }
  }

  /// Adds a new query to the [sectionsStream] stream.
  ///
  /// As a rule of thumb, put this in any DatabaseHelper method that modifies the database contents so that the main screen is properly updated.
  static void updateSectionsStream() async {
    try {
      final query = await getSections();
      _sectionsLength = query.length;
      _sectionsController.sink.add(query);
    } catch (e) {
      print(e);
    }
  }

  static Stream<List<Item>> get itemBankStream => _itemBankController.stream;

  static Stream<List<Section>> get sectionsStream => _sectionsController.stream;

  // Updating

  /// Removes all content from the sections table and inserts a new list of sections.
  ///
  /// Some sections may be deleted in the process. If they are, provide them in the [deletedSections] argument so they are deleted properly.
  ///
  /// These sections will have a primary key based on their order in the list argument.
  static Future<void> replaceSectionsWith(List<Section> newSections,
      {List<Section>? deletedSections}) async {
    try {
      if (deletedSections != null && deletedSections.isNotEmpty) {
        await _handleDeletedSectionItems(deletedSections);
      }
      await _db.delete(_sectionsTableName);

      // Ensure the ID order matches the list order
      for (var i = 0; i < newSections.length; i++) {
        newSections[i].id = i;
      }

      for (final section in newSections) {
        _db.insert(_sectionsTableName, section.toMap());
      }

      updateSectionsStream();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> updateItem(Item item) async {
    try {
      await _db.update(
        _itemBankTableName,
        item.toMap(),
        where: '$_itemBankId = ?',
        whereArgs: [item.id],
      );
      updateItemBankStream();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> updateItems(List<Item> items) async {
    try {
      final batch = _db.batch();
      for (final item in items) {
        batch.update(
          _itemBankTableName,
          item.toMap(),
          where: '$_itemBankId = ?',
          whereArgs: [item.id],
        );
      }
      batch.commit();
      updateItemBankStream();
    } catch (e) {
      print(e);
    }
  }

  // Deleting
  static Future<void> deleteItem(Item item) async {
    try {
      _db.delete(_itemBankTableName,
          where: '$_itemBankId = ?', whereArgs: [item.id]);
      _itemBankLength--;
      updateItemBankStream();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteSection(Section section) async {
    try {
      await _handleDeletedSectionItems([section]);
      await _db.delete(_sectionsTableName,
          where: '$_sectionsId = ?', whereArgs: [section.id]);

      updateItemBankStream();
      updateSectionsStream();
    } catch (e) {
      print(e);
    }
  }

  /// If a section is deleted, the items that belonged to that section should not be deleted, instead they should have their "section" property set to null so they don't disappear into the dark corners of the database, never to be seen again.
  ///
  /// This DOES NOT delete sections! This should be used alongside operations that delete sections to ensure they are deleted properly.
  ///
  /// There are some situations where you need to delete multiple sections at once, so this requires a list.
  static Future<void> _handleDeletedSectionItems(List<Section> sections) async {
    try {
      final batch = _db.batch();
      for (final section in sections) {
        batch.update(
          _itemBankTableName,
          {_itemBankSection: null},
          where: '$_itemBankSection = ?',
          whereArgs: [section.title.toLowerCase()],
        );
      }
      await batch.commit();
      updateItemBankStream();
    } catch (e) {
      print(e);
    }
  }

  /// Changes the "section" property of [items] to the title of [section].
  static Future<void> updateSectionPropertyOf(
      List<Item> items, Section section) async {
    try {
      final batch = _db.batch();
      for (final item in items) {
        item.section = section.title;
        batch.update(
          _itemBankTableName,
          {_itemBankSection: item.section},
          where: '$_itemBankId = ?',
          whereArgs: [item.id],
        );
      }
      await batch.commit();
      updateItemBankStream();
    } catch (e) {
      print(e);
    }
  }

  // TODO: Comment out in release builds.
  static Future<void> deleteEverything() async {
    try {
      await deleteDatabase(join(await getDatabasesPath(), _dbName));
      print('$_dbName has been deleted.');
    } catch (e) {
      print(e);
    }
  }

  // Other
  static void closeStreams() {
    _itemBankController.close();
    _sectionsController.close();
  }
}
