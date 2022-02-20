import 'package:flutter/material.dart';
import 'package:shopping_list/screens/item_bank_screen.dart';
import 'package:shopping_list/widgets/item_list.dart';
import 'package:shopping_list/widgets/warning_dialog.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
        actions: [
          IconButton(
            icon: Icon(Icons.build),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) {
                  return WarningDialog(
                    content:
                        'Generating a list will not remove existing items.',
                    buttonText: 'Generate',
                    isDestructive: false,
                  );
                },
              );
              //if (result) _generateItems();
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemBankScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: ItemList(),
    );
  }
}
