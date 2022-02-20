import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopping_list/screens/main_screen.dart';
import 'package:shopping_list/screens/new_main_screen.dart';
import 'package:shopping_list/utilities/ad_state.dart';
import 'package:shopping_list/utilities/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdState.initStatusFuture = MobileAds.instance.initialize();

  // wont work on iOS, should have UIInterfaceOrientationPortrait in your info.plist
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await DatabaseHelper.open();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NewMainScreen(),
    );
  }
}
