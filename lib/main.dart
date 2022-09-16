import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return ProviderScope(
      child: MaterialApp(
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
          textTheme: const TextTheme(
            bodyText1: TextStyle(
              fontSize: 17.5,
              color: secondaryColor,
            ),
            bodyText2: TextStyle(
              fontSize: 17.5,
              color: secondaryColor,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 30,
          ),
          primaryIconTheme: const IconThemeData(
            color: secondaryColor,
          ),
          dividerTheme: const DividerThemeData(
            color: Colors.white30,
            thickness: 1.75,
            space: 25,
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: secondaryColor,
            thumbColor: Colors.white,
            trackHeight: 5,
            inactiveTrackColor: Color.alphaBlend(
              Colors.white30,
              secondaryColor,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(),
        ),
        home: const SplashScreenPage(), // const HomePage(),
      ),
    );
  }
}
