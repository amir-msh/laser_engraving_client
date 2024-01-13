import 'dart:async';
import 'package:flutter/material.dart';
import 'package:laser_engraving_client/main.dart';
import 'package:laser_engraving_client/pages/home.dart';
import 'package:rive/rive.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints.expand(),
        color: Theme.of(context).colorScheme.background,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(width: 200),
              child: RiveAnimation.asset(
                'assets/rive/laser.riv',
                artboard: 'logo',
                animations: const ['entrance'],
                onInit: (Artboard artboard) {
                  Future.delayed(
                    const Duration(milliseconds: 1750),
                    () {
                      navKey.currentState!.pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                  );
                },
                placeHolder: Image.asset(
                  'assets/launcher_icons/foreground-windows.png',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
