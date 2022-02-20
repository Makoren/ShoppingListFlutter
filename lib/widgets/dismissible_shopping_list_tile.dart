import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/warning_dialog.dart';
import 'package:shopping_list/widgets/shopping_list_tile.dart';

class DismissibleShoppingListTile extends StatelessWidget {
  const DismissibleShoppingListTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) {
            return WarningDialog(
              content: 'Deleting an item is irreversible!',
              buttonText: 'Delete',
              isDestructive: true,
            );
          },
        );
      },
      onDismissed: (direction) {
        DatabaseHelper.deleteItem(item);
      },
      child: ShoppingListTile(
        item: item,
        undoPromptText: 'Sent to your list',
      ),
    );
  }
}
