import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img;
import 'package:laser_engraving_client/components/image_selection_dialog.dart';

class ImageEngravingPage extends StatefulWidget {
  const ImageEngravingPage({Key? key}) : super(key: key);

  @override
  State<ImageEngravingPage> createState() => _ImageEngravingPageState();
}

class _ImageEngravingPageState extends State<ImageEngravingPage> {
  final _imagePreviewNotifier = ValueNotifier<Uint8List?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image '),
        toolbarHeight: 55,
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 10 / 12,
            child: InkWell(
              onTap: () async {
                final result = await showModalBottomSheet<String>(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => const ImageSelectionDialog(),
                );

                if (result?.isNotEmpty ?? false) {
                  _imagePreviewNotifier.value = Uint8List.fromList(
                    await io.File(result!).readAsBytes(),
                  );
                }
              },
              child: ValueListenableBuilder<Uint8List?>(
                valueListenable: _imagePreviewNotifier,
                builder: (context, value, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 360),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: value == null
                        ? child
                        : Padding(
                            key: UniqueKey(),
                            padding: const EdgeInsets.all(10),
                            child: Image.memory(value),
                          ),
                  );
                },
                child: const Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Select an image',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints.expand(),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
