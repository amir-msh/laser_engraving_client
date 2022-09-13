import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:laser_engraving_client/pages/home.dart';
import 'package:laser_engraving_client/pages/splash_screen.dart';
import 'package:laser_engraving_client/utils/theme.dart';

final navKey = GlobalKey<NavigatorState>();

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
    // timeDilation = 2;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      theme: ThemeData(
        cardColor: Color.alphaBlend(
          Colors.amber.withOpacity(0.5),
          accentColor,
        ),
        shadowColor: secondaryColor.withOpacity(0.75),
        // primaryColor: const Color(0xff112537),
        // colorSchemeSeed: const Color(0xffF37410),
        backgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          background: Colors.white,
          seedColor: primaryColor,
          error: Colors.red,
          primary: primaryColor,
          secondary: secondaryColor,
          outline: secondaryColor,
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(
            fontSize: 18,
            color: secondaryColor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 30,
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
      home: SplashScreenPage(), // const HomePage(),
    );
  }
}
