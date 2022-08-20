import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:laser_engraving_client/image_processing/image_processing.dart';

class ImageConversionTestPage extends StatefulWidget {
  const ImageConversionTestPage({Key? key}) : super(key: key);

  @override
  State<ImageConversionTestPage> createState() =>
      _ImageConversionTestPageState();
}

class _ImageConversionTestPageState extends State<ImageConversionTestPage> {
  String imageText = '';
  io.File? picFile;
  Uint8List? editedImageBytes;

  Widget imageFrameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    return Center(
      child: child,
    );
    // return Center(
    //   child: Container(
    //     constraints: const BoxConstraints.tightFor(),
    //     padding: const EdgeInsets.all(0),
    //     decoration: BoxDecoration(
    //       border: Border.all(
    //         color: Colors.orange,
    //         width: 5,
    //       ),
    //     ),
    //     child: child,
    //   ),
    // );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              children: [
                if (picFile != null)
                  Expanded(
                    child: Image.file(
                      picFile!,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      frameBuilder: imageFrameBuilder,
                    ),
                  ),
                if (editedImageBytes != null)
                  Expanded(
                    child: Image.memory(
                      editedImageBytes!,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      frameBuilder: imageFrameBuilder,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (imageText.isNotEmpty) Text(imageText),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                allowCompression: false,
                type: FileType.image,
                dialogTitle: 'Please choose an image',
                allowMultiple: false,
              );
              if (result != null && result.files.single.path != null) {
                setState(() {
                  picFile = io.File(result.files.single.path!);
                });
              }
            },
            child: const Text('Select an image'),
          ),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: () async {
              if (picFile == null) return;
              final sw = Stopwatch()..start();
              editedImageBytes = Uint8List.fromList(
                img.encodeBmp(
                  await convertToEdgeDetected(
                    await fileToEditableImage(picFile!),
                  ),
                ),
              );
              sw.stop();
              imageText = '${sw.elapsedMilliseconds} ms';

              setState(() {});
            },
            child: const Text('Process the current image'),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
