import 'package:dough/dough.dart';
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
    return DoughRecipe(
      data: DoughRecipeData(
        expansion: 0.9725,
        adhesion: 15,
        viscosity: 8000,
        exitDuration: const Duration(milliseconds: 750),
        entryDuration: const Duration(milliseconds: 50),
        perspectiveWarpDepth: 0.012,
        usePerspectiveWarp: true,
        gyroPrefs: GyroDoughPrefs(
          sampleCount: 25,
          gyroMultiplier: 15,
        ),
      ),
      child: ProviderScope(
        child: MaterialApp(
          navigatorKey: navKey,
          theme: ThemeData(
            cardColor: Color.alphaBlend(
              Colors.amber.withOpacity(0.5),
              accentColor,
            ),
            shadowColor: secondaryColor.withOpacity(0.5),

            appBarTheme: const AppBarTheme(
              backgroundColor: primaryColor,
              titleTextStyle: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
                size: 27,
              ),
            ),

            // primaryColor: const Color(0xff112537),
            // colorSchemeSeed: const Color(0xffF37410),

            scaffoldBackgroundColor: Colors.white,
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
              bodySmall: TextStyle(
                fontSize: 17.5,
                color: secondaryColor,
              ),
              labelSmall: TextStyle(
                fontSize: 17.5,
                color: secondaryColor,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(85, 43),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                backgroundColor: secondaryColor,
                disabledBackgroundColor: secondaryColor.withOpacity(0.5),
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 17.5,
                  color: Colors.white,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                minimumSize: const Size(85, 43),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                backgroundColor: secondaryColor.withOpacity(0.125),
                disabledBackgroundColor: secondaryColor.withOpacity(0.0666),
                disabledForegroundColor: Colors.white38,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(
                  fontSize: 17,
                  color: secondaryColor.withOpacity(0.75),
                ),
              ),
            ),
            dialogTheme: DialogTheme(
              actionsPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              alignment: Alignment.center,
              elevation: 20,
              titleTextStyle: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w500,
                color: secondaryColor,
              ),
              contentTextStyle: const TextStyle(
                fontSize: 19,
                color: secondaryColor,
              ),
              iconColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            cardTheme: CardTheme(
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
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
      ),
    );
  }
}
