import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'package:rive/rive.dart';

class EngravingPage extends StatefulWidget {
  final img.Image image;
  const EngravingPage({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  State<EngravingPage> createState() => _EngravingPageState();
}

class _EngravingPageState extends State<EngravingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engraving the subject'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: RiveAnimation.asset(
                'assets/rive/laser.riv',
                artboard: 'engraving',
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Center(
                child: FutureBuilder<Uint8List>(
                  future: convertToViewableBytes(widget.image),
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 360),
                      child: (!snapshot.hasData)
                          ? const Center(child: CircularProgressIndicator())
                          : Image.memory(snapshot.data!),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
