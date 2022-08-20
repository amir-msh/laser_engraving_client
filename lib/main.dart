import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laser_engraving_client/pages/home.dart';
import 'package:laser_engraving_client/utils/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // primaryColor: const Color(0xff112537),
        // colorSchemeSeed: const Color(0xffF37410),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          background: Colors.white,
          
          seedColor: primaryColor,
          error: Colors.red,
          primary: primaryColor,
          secondary: accentColor,
          outline: secondaryColor,
        ),
        iconTheme: const IconThemeData(
          color: secondaryColor,
        ),
        primaryIconTheme: const IconThemeData(
          color: secondaryColor,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            // foregroundColor: secondaryColor,
            ),
        // colorScheme: ColorScheme(
        //   brightness: Brightness.light,
        //   primary: Color(0xffF37410),
        //   onPrimary: onPrimary,
        //   secondary: secondary,
        //   onSecondary: onSecondary,
        //   error: error,
        //   onError: onError,
        //   background: background,
        //   onBackground: onBackground,
        //   surface: surface,
        //   onSurface: onSurface,
        // ),
      ),
      home: const HomePage(),
    );
  }
}
