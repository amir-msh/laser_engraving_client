import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laser_engraving_client/components/option_card.dart';
import 'package:laser_engraving_client/pages/image_engraving.dart';
import 'package:laser_engraving_client/pages/painting_engraving.dart';
import 'package:rive/rive.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: AppBar(
            title: const Text('Laser Client'),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Center(
                child: PressableDough(
                  child: RiveAnimation.asset(
                    'assets/rive/laser.riv',
                    artboard: 'logo',
                    animations: ['loading'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              // crossAxisCount: 2,
              children: [
                OptionCard(
                  icon: const Icon(Icons.image_outlined),
                  title: 'Gallery',
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ImageEngravingPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                OptionCard(
                  icon: const Icon(Icons.draw_outlined),
                  title: 'Painting',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PaintingEngravingPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                OptionCard(
                  icon: const Icon(Icons.pattern),
                  title: 'Ready Patterns',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => const ImageConversionTestPage(),
      //       ),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
