import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'package:shopping_list/models/item.dart';
import 'package:shopping_list/screens/item_bottom_sheet.dart';
import 'package:shopping_list/screens/item_dialog.dart';
import 'package:shopping_list/screens/settings_screen.dart';
import 'package:shopping_list/utilities/ad_state.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/widgets/item_list.dart';
import 'package:shopping_list/screens/sections_screen.dart';
import 'package:shopping_list/widgets/shopping_list_tile.dart';
import 'package:shopping_list/widgets/warning_dialog.dart';

// If you ever want to go back to the old look, change main.dart to redirect to MainScreen instead of this one.

class NewMainScreen extends StatefulWidget {
  @override
  _NewMainScreenState createState() => _NewMainScreenState();
}

class _NewMainScreenState extends State<NewMainScreen> {
  BannerAd? banner;

  TextEditingController _searchQueryController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdState.initStatusFuture.then((status) {
      setState(() {
        banner = BannerAd(
          adUnitId: AdState.bannerAdUnitId,
          size: AdSize.banner,
          request: AdRequest(),
          listener: AdState.adListener,
        )..load();
      });
    });
  }

  void _addItem() async {
    final items = await DatabaseHelper.getItemBank();
    Item? item = await showMaterialModalBottomSheet(
        context: context,
        builder: (context) => ItemBottomSheet(
              title: 'Add Item',
              items: items,
            ));

    if (item != null) {
      DatabaseHelper.insertIntoItemBank(item);
    }
  }

  void _displayUndoButton(List<Item> items) {
    final sm = ScaffoldMessenger.of(context);
    sm.removeCurrentSnackBar();
    sm.showSnackBar(SnackBar(
      content: Text('Generated items'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          for (final item in items) {
            item.isCompleted = true;
          }
          DatabaseHelper.updateItems(items);
        },
      ),
    ));
  }

  void _generateItems() async {
    final query = await DatabaseHelper.getItemBank();
    final items = query
        .where((item) => item.isCompleted && item.isMarkedForGenerate)
        .toList();

    for (final item in items) {
      item.isCompleted = false;
    }

    DatabaseHelper.updateItems(items);
    _displayUndoButton(items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              showSearch(
                context: context,
                delegate: _ItemSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: banner != null ? AdWidget(ad: banner!) : null,
          ),
          Expanded(
            child: ScrollSnapList(
              itemCount: 2,
              itemSize: MediaQuery.of(context).size.width,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child:
                      index == 0 ? ItemList() : ItemList(isCompletedList: true),
                );
              },
              onItemFocus: (_) {},
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addItem(),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.format_color_fill_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Fill List', style: TextStyle(color: Colors.white)),
                  ],
                ),
                onPressed: () async {
                  bool? result = await showDialog(
                    context: context,
                    builder: (context) {
                      return WarningDialog(
                        content:
                            'Are you sure you want to fill the list with items?',
                        buttonText: 'Fill',
                        isDestructive: false,
                      );
                    },
                  );
                  if (result ?? false) _generateItems();
                },
              ),
              TextButton(
                child: Row(
                  children: [
                    Text('Sections', style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                    Icon(Icons.list, color: Colors.white),
                  ],
                ),
                onPressed: () async {
                  showMaterialModalBottomSheet(
                    enableDrag: false,
                    context: context,
                    builder: (context) => SectionsScreen(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.chevron_left),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.getItemBank(),
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          final items = snapshot.data as List<Item>;
          final results = items
              .where((item) => item.name.toLowerCase().contains(query))
              .toList();
          results.sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          return ListView(
            children: results.map((item) {
              return ShoppingListTile(item: item);
            }).toList(),
          );
        } else {
          return Text('Loading...');
        }
      },
    );
  }
}
