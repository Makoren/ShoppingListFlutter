import 'package:flutter/material.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/shopping_list_tile.dart';
import 'package:shopping_list/utilities/util.dart';

class ItemList extends StatelessWidget {
  ItemList({this.isCompletedList = false});

  final bool isCompletedList;
  final List<Widget> listTiles = [];

  // Item list is being passed by reference, so this doesn't need a return value.
  void _sortItemsAlphabetically(List<Item> items) {
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void _buildSection(Section? section, List<Item> items) {
    Widget header;

    if (section != null) {
      header = Center(
        child: Text(
          section.title.capitalize(),
          style: TextStyle(
            fontSize: 32,
            color: section.color,
          ),
        ),
      );
    } else {
      header = Divider();
    }

    listTiles.add(header);

    final sectionItems =
        items.where((item) => item.section == section?.title).toList();
    for (final item in sectionItems) {
      listTiles.add(ShoppingListTile(
        key: ObjectKey(item),
        item: item,
      ));
    }
  }

  Widget _buildItems(List<Item> items, List<Section> sections) {
    listTiles.clear();

    for (var i = 0; i < sections.length + 1; i++) {
      if (i < sections.length) {
        _buildSection(sections[i], items);
      } else {
        _buildSection(null, items);
      }
    }

    return ListView.builder(
      itemCount: items.length + sections.length + 1,
      itemBuilder: (context, index) {
        try {
          return listTiles[index];
        } catch (e) {
          print(e);
          return Text(
              'Oops something broke! Contact the developer if you see this.');
        }
      },
    );
  }

  Widget _buildList(List<Item> items, List<Section> sections) {
    List<Item> sortedItems;
    if (!isCompletedList) {
      sortedItems = items.where((item) => !item.isCompleted).toList();
    } else {
      sortedItems = items.where((item) => item.isCompleted).toList();
    }

    _sortItemsAlphabetically(sortedItems);
    print('New items:');
    sortedItems.forEach((item) => print(item.name));

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _buildItems(sortedItems, sections),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Section>>(
      stream: DatabaseHelper.sectionsStream,
      builder: (context, sectionsSnapshot) {
        switch (sectionsSnapshot.connectionState) {
          case ConnectionState.active:
          case ConnectionState.done:
            return StreamBuilder<List<Item>>(
              stream: DatabaseHelper.itemBankStream,
              builder: (context, itemBankSnapshot) {
                switch (itemBankSnapshot.connectionState) {
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return _buildList(itemBankSnapshot.data ?? [],
                        sectionsSnapshot.data ?? []);

                  case ConnectionState.waiting:
                    DatabaseHelper.updateItemBankStream();
                    return Center(child: Text('Waiting for item bank...'));

                  case ConnectionState.none:
                    return Center(child: Text('Error!'));
                }
              },
            );
          case ConnectionState.waiting:
            DatabaseHelper.updateSectionsStream();
            return Center(child: Text('Waiting for sections...'));
          case ConnectionState.none:
            return Center(child: Text('Error!'));
        }
      },
    );
  }
}
