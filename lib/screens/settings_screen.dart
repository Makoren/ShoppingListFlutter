import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shopping_list/models/editable_sections_brain.dart';
import 'package:shopping_list/models/section.dart';
import 'package:shopping_list/screens/section_dialog.dart';
import 'package:shopping_list/utilities/database_helper.dart';
import 'package:shopping_list/screens/sections_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          await EditableSectionsBrain.run();
          Navigator.pop(context);
          return false;
        },
        child: SettingsList(sections: [
          SettingsSection(
            title: 'Section Test',
            tiles: [
              SettingsTile(
                title: 'About',
                leading: Icon(Icons.info),
                onPressed: (context) {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Shopping List',
                    applicationVersion: '0.0.1',
                    // TODO: needs icon and legalese
                  );
                },
              ),
            ],
          )
        ]),
      ),
    );
  }
}
