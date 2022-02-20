import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/screens/settings_screen.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/dismissible_shopping_list_tile.dart';

import 'item_dialog.dart';

class ItemBankScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item Bank'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final items = await DatabaseHelper.getItemBank();
              Item? item = await showDialog(
                context: context,
                builder: (context) => ItemDialog(
                  title: 'Add Item',
                  items: items,
                ),
              );

              if (item != null) {
                DatabaseHelper.insertIntoItemBank(item);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              showMaterialModalBottomSheet(
                enableDrag: false,
                context: context,
                builder: (context) => SettingsScreen(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Item>>(
        stream: DatabaseHelper.itemBankStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.done:
              List<Item> completedItems =
                  snapshot.data?.where((item) => item.isCompleted).toList() ??
                      [];

              return ListView.builder(
                itemBuilder: (context, index) =>
                    DismissibleShoppingListTile(item: completedItems[index]),
                itemCount: completedItems.length,
              );

            case ConnectionState.waiting:
              DatabaseHelper.updateItemBankStream();
              return Center(child: Text('Loading...'));

            case ConnectionState.none:
              return Center(child: Text('what'));
          }
        },
      ),
    );
  }
}
