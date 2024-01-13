import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'dart:ui' as ui;
import 'package:laser_engraving_client/main.dart';
import 'package:laser_engraving_client/pages/engraving.dart';

class PatternCard extends StatelessWidget {
  final String imageAssetPath;
  final Radius innerBorderRadius;
  const PatternCard({
    required this.imageAssetPath,
    this.innerBorderRadius = const Radius.circular(20),
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                clipBehavior: Clip.none,
                constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: innerBorderRadius,
                  ),
                ),
                child: Image.asset(
                  imageAssetPath,
                  color: Colors.white,
                  colorBlendMode: BlendMode.dstATop,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                    return ClipRRect(
                      clipBehavior: Clip.hardEdge,
                      borderRadius: BorderRadius.vertical(
                        top: innerBorderRadius,
                      ),
                      child: child,
                    );
                  },
                ),
              ),
            ),
            // const SizedBox(height: 8),
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                        shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: innerBorderRadius,
                        ),
                      ),
                    )),
                onPressed: () async {
                  // final assetImage = AssetImage(imageAssetPath);
                  // assetImage.

                  final bytes = await rootBundle.load(imageAssetPath);
                  final completer = Completer<ui.Image>();
                  ui.decodeImageFromList(
                    bytes.buffer.asUint8List(),
                    (result) => completer.complete(result),
                  );
                  final uiImage = await completer.future;

                  var image = img.Image.fromBytes(
                    uiImage.width,
                    uiImage.height,
                    (await uiImage.toByteData())!.buffer.asUint8List(),
                  );

                  image = await reshapeToSizedSquare(image, 128);

                  navKey.currentState!.push(
                    MaterialPageRoute(
                      builder: (context) => EngravingPage(image: image),
                    ),
                  );
                  // img.Image.fromBytes(
                  //   width,
                  //   height,
                  //   bytes,
                  // );
                },
                child: const Text('Engrave it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
