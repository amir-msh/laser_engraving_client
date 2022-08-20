import 'dart:async';
import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:laser_engraving_client/utils/convolution_kernels.dart';

// img.decodeImage(data)

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

  Future<img.Image> convertToEditableImage(ui.Image image) async {
    return img.Image.fromBytes(
      image.width,
      image.height,
      (await image.toByteData())!.buffer.asUint8List(),
    );
  }

  Future<ui.Image> fileToImage(io.File file) async {
    final fileBytes = await file.readAsBytes();
    // late final ui.Image image;
    final imageCompleter = Completer<ui.Image>();
    ui.decodeImageFromList(fileBytes, (result) {
      imageCompleter.complete(result);
    });
    return await imageCompleter.future;
  }

  Future<img.Image> maskImageUsingLuminance(
    img.Image editableImage, [
    double luminanceThreshold = 0.5,
  ]) async {
    for (var x = 0; x < editableImage.width; x++) {
      for (var y = 0; y < editableImage.height; y++) {
        final pixelBytes = editableImage.getPixel(x, y);

        int lum = ui.Color(pixelBytes).computeLuminance() < luminanceThreshold
            ? 0
            : 255;
        editableImage.setPixel(
          x,
          y,
          Color.fromARGB(255, lum, lum, lum).value,
        );
      }
    }
    return editableImage;
  }

  Future<Uint8List> convertToCustomEdgeDetected(ui.Image image) async {
    var editableImage = await convertToEditableImage(image);
    const filter = [0, -1, 0, -1, 4, -1, 0, -1, 0];

    editableImage = img.copyResizeCropSquare(editableImage, 500);

    img.contrast(editableImage, 400);
    img.grayscale(editableImage);
    img.contrast(editableImage, 120);
    img.gaussianBlur(editableImage, 2);
    img.vignette(editableImage, start: 0.5, end: 0.9);
    img.convolution(editableImage, filter, div: 0.027);

    return Uint8List.fromList(img.encodeBmp(editableImage));
  }

  Future<Uint8List> convertToEdgeDetected(
    final ui.Image image, [
    final bool invert = false,
  ]) async {
    var editableImage = await convertToEditableImage(image);
    final processingSize = applyBoxFit(
      BoxFit.contain,
      Size(editableImage.width.toDouble(), editableImage.height.toDouble()),
      const Size.square(1000),
    ).destination;

    editableImage = img.copyResize(
      editableImage,
      width: processingSize.width.toInt(),
      height: processingSize.height.toInt(),
    );
    img.grayscale(editableImage);
    img.vignette(editableImage, start: 0.5, end: 0.9);
    img.contrast(editableImage, 120);
    img.gaussianBlur(editableImage, 1);
    img.sobel(editableImage, amount: 1);
    await maskImageUsingLuminance(editableImage, 0.07);
    editableImage = img.copyCrop(
      editableImage,
      1,
      1,
      processingSize.width.floor() - 2,
      processingSize.height.floor() - 2,
    );
    final background = img.Image.rgb(1000, 1000);
    if (invert) {
      img.invert(editableImage);
      background.fill(0xFFFFFFFF);
    } else {
      background.fill(0xFF000000);
    }
    editableImage = img.copyInto(
      background,
      editableImage,
      center: true,
    );
    editableImage = img.copyResize(editableImage, width: 300, height: 300);
    imageText = '${image.width} * ${image.height}';

    return Uint8List.fromList(img.encodeBmp(editableImage));
  }

  Future<Uint8List> convertToRidgeDetected(ui.Image image) async {
    var editableImage = await convertToEditableImage(image);
    img.grayscale(editableImage);
    img.contrast(editableImage, 110);
    img.gaussianBlur(editableImage, 1);
    img.convolution(editableImage, ridgeDetection3Kernel);

    await maskImageUsingLuminance(editableImage, 0.1);

    return Uint8List.fromList(img.encodeBmp(editableImage));
  }

  Future<Uint8List> convertToLaplacianMasked(ui.Image image) async {
    var editableImage = await convertToEditableImage(image);
    img.grayscale(editableImage);
    img.contrast(editableImage, 110);
    img.gaussianBlur(editableImage, 1);
    img.convolution(editableImage, laplacian2Kernel, div: 0.75);

    await maskImageUsingLuminance(editableImage, 0.06);

    return Uint8List.fromList(img.encodeBmp(editableImage));
  }

  Future<Uint8List> convertToMappedGrayscale(ui.Image image) async {
    final editableImage = await convertToEditableImage(image);
    for (var x = 0; x < image.width; x++) {
      for (var y = 0; y < image.height; y++) {
        final pixelBytes = editableImage.getPixel(x, y);

        int lum = mapColorToGrayscale(ui.Color(pixelBytes));
        editableImage.setPixel(
          x,
          y,
          Color.fromARGB(255, lum, lum, lum).value,
        );
      }
    }
    return Uint8List.fromList(img.encodeBmp(editableImage));
  }

  static const mapResolution = 64;
  static const mapSteps = 255.0 / (mapResolution - 1);
  static const arraySteps = mapResolution == 2 ? 255 ~/ 2 : mapSteps;
  final mapValues = List.generate(
    mapResolution,
    (i) => (mapSteps * i.toDouble()).round(),
  );

  int mapColorToGrayscale(Color color) {
    int lum = (color.red + color.blue + color.green) ~/ 3;

    if (mapResolution == 2) {
      return mapValues[min(lum ~/ arraySteps, 1)];
    } else {
      return mapValues[lum ~/ arraySteps];
    }
  }

  Widget imageFrameBuilder(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    return Center(
      child: Container(
        constraints: const BoxConstraints.tightFor(),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.orange,
            width: 5,
          ),
        ),
        child: child,
      ),
    );
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
              final result = await FilePicker.platform.pickFiles();
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

              editedImageBytes = await convertToLaplacianMasked(
                await fileToImage(picFile!),
              );

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
