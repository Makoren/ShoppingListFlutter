import 'package:flutter/material.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/screens/item_dialog.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/warning_dialog.dart';

class ShoppingListTile extends StatefulWidget {
  ShoppingListTile({
    this.key,
    required this.item,
    this.undoPromptText = 'Item completed',
  }) : super(key: key);

  final Key? key;
  final Item item;

  /// This is the text that gets displayed on the SnackBar next to the button.
  final String undoPromptText;

  @override
  _ShoppingListTileState createState() => _ShoppingListTileState();
}

class _ShoppingListTileState extends State<ShoppingListTile> {
  late bool _isCompleted;
  Item? _newItem;
  late Item _oldItem;
  Offset? _touchPos;

  void _showContextMenu() async {
    showMenu(
      context: context,
      items: [
        PopupMenuItem(
          value: _PopupItemValue.edit,
          child: Text('Edit'),
        ),
        PopupMenuItem(
          value: _PopupItemValue.delete,
          child: Text('Delete'),
        ),
      ],
      position: RelativeRect.fromLTRB(
        _touchPos!.dx,
        _touchPos!.dy,
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height,
      ),
    ).then((value) async {
      switch (value) {
        case _PopupItemValue.edit:
          await _editItem();
          break;
        case _PopupItemValue.delete:
          await _deleteItem();
          break;
        case null:
          break;
      }
    });
  }

  Future<void> _editItem() async {
    final items = await DatabaseHelper.getItemBank();
    Item? item = await showDialog(
      context: context,
      builder: (context) => ItemDialog(
        title: 'Edit Item',
        item: widget.item,
        items: items,
      ),
    );

    if (item != null) {
      DatabaseHelper.updateItem(item);
    }
  }

  Future<void> _deleteItem() async {
    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return WarningDialog(
          content: 'Deleting an item is irreversible!',
          buttonText: 'Delete',
          isDestructive: true,
        );
      },
    );
    if (result ?? false) DatabaseHelper.deleteItem(widget.item);
  }

  void _toggleCompleted() async {
    setState(() {
      _isCompleted = !_isCompleted;
    });

    _oldItem = widget.item;
    _newItem = _oldItem.copyWith(isCompleted: _isCompleted);

    await DatabaseHelper.updateItem(_newItem!);
    _displayUndoButton();
  }

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.item.isCompleted;
    _oldItem = widget.item;
  }

  void _displayUndoButton() {
    final sm = ScaffoldMessenger.of(context);
    sm.removeCurrentSnackBar();
    sm.showSnackBar(SnackBar(
      content: Text(widget.undoPromptText),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Undo functionality
          if (_newItem != null) {
            _newItem!.isCompleted = _oldItem.isCompleted;
            DatabaseHelper.updateItem(_newItem!);
          }
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _toggleCompleted(),
      onLongPress: () => _showContextMenu(),
      onTapDown: (details) => _touchPos = details.globalPosition,
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('${widget.item.quantity}'),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.name, style: TextStyle(fontSize: 24)),
                    Text(widget.item.description),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(widget.item.section ?? 'No section',
                    textAlign: TextAlign.center),
              ),
              Expanded(
                flex: 1,
                child: Visibility(
                  visible: widget.item.isMarkedForGenerate,
                  child: Icon(Icons.format_color_fill_rounded),
                ),
              ),
              Expanded(
                flex: 1,
                child: Visibility(
                  visible: !widget.item.isCompleted,
                  child: Icon(Icons.check),
                ),
              ),
            ],
          ),
        ),
      ),
      // child: ListTile(
      //   key: widget.key,
      //   title: Text('${widget.item.name} (${widget.item.quantity})'),
      //   subtitle: Text(widget.item.description),
      //   isThreeLine: true,
      //   trailing: widget.item.isMarkedForGenerate
      //       ? Icon(Icons.build, color: Colors.green)
      //       : null,
      // ),
    );
  }
}

enum _PopupItemValue { edit, delete }
