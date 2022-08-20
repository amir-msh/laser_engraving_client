import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'package:laser_engraving_client/image_processing/convolution_kernels.dart';

Future<img.Image> convertToEditableImage(ui.Image image) async {
  return img.Image.fromBytes(
    image.width,
    image.height,
    (await image.toByteData())!.buffer.asUint8List(),
    channels: img.Channels.rgb,
  );
}

Future<img.Image> fileToEditableImage(io.File file) async {
  return img.decodeImage(file.readAsBytesSync())!;
}

/// [luminanceThreshold] should be a value between 0.0 and 1.0
Future<img.Image> maskUsingLuminance(
  final img.Image image, [
  double luminanceThreshold = 0.5,
]) async {
  int lum = 0;
  for (var x = 0; x < image.width; x++) {
    for (var y = 0; y < image.height; y++) {
      final luminance = ui.Color(image.getPixel(x, y)).computeLuminance();

      lum = luminance < luminanceThreshold ? 0 : 255;
      image.setPixel(
        x,
        y,
        0xff000000 | (lum << 16) | (lum << 8) | lum,
      );
    }
  }
  return image;
}

Future<img.Image> convertToLaplacianMasked(img.Image image) async {
  img.grayscale(image);
  img.contrast(image, 110);
  img.gaussianBlur(image, 1);
  img.convolution(image, laplacian2Kernel, div: 0.75);

  await maskUsingLuminance(image, 0.06);

  return image;
}

Future<img.Image> convertToRidgeDetected(img.Image image) async {
  img.grayscale(image);
  img.contrast(image, 110);
  img.gaussianBlur(image, 1);
  img.convolution(image, ridgeDetection3Kernel);

  await maskUsingLuminance(image, 0.1);

  return image;
}

Future<img.Image> fitImageToSize(
  img.Image image,
  final Size size, {
  final BoxFit fit = BoxFit.contain,
  final img.Interpolation interpolation = img.Interpolation.nearest,
}) async {
  final dstSize = applyBoxFit(
    fit,
    Size(image.width.toDouble(), image.height.toDouble()),
    size,
  ).destination;

  return img.copyResize(
    image,
    width: dstSize.width.floor(),
    height: dstSize.height.toInt(),
    interpolation: interpolation,
  );
}

Future<img.Image> reshapeToSquare(
  img.Image image, {
  int backgroundColor = 0xFFFFFFFF,
}) async {
  final longestSize = max(image.width, image.height);
  final background = img.Image.rgb(
    longestSize,
    longestSize,
  ).fill(backgroundColor);
  image = img.copyInto(
    background,
    image,
    center: true,
  );
  return image;
}

Future<img.Image> convertToEdgeDetected(
  img.Image image, [
  final bool invert = false,
]) async {
  image = await fitImageToSize(image, const Size.square(1000));

  img.grayscale(image);
  img.vignette(image, start: 0.5, end: 0.9);
  img.contrast(image, 120);
  img.gaussianBlur(image, 1);
  img.sobel(image, amount: 1);
  await maskUsingLuminance(image, 0.07);
  image = img.copyCrop(image, 1, 1, image.width - 2, image.height - 2);

  if (invert) {
    img.invert(image);
    image = await reshapeToSquare(
      image,
      backgroundColor: 0xFFFFFFFF,
    );
  } else {
    image = await reshapeToSquare(
      image,
      backgroundColor: 0xFF000000,
    );
  }
  image = img.copyResize(image, width: 300, height: 300);
  return image;
}

Future<img.Image> convertToCustomEdgeDetected(img.Image image) async {
  const filter = [0, -1, 0, -1, 4, -1, 0, -1, 0];

  image = img.copyResizeCropSquare(image, 500);

  img.contrast(image, 400);
  img.grayscale(image);
  img.contrast(image, 120);
  img.gaussianBlur(image, 2);
  img.vignette(image, start: 0.5, end: 0.9);
  img.convolution(image, filter, div: 0.027);

  return image;
}

const mapResolution = 64;
const mapSteps = 255.0 / (mapResolution - 1);
const arraySteps = mapResolution == 2 ? 255 ~/ 2 : mapSteps;
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

Future<img.Image> convertToMappedGrayscale(img.Image image) async {
  for (var x = 0; x < image.width; x++) {
    for (var y = 0; y < image.height; y++) {
      final pixelBytes = image.getPixel(x, y);

      int lum = mapColorToGrayscale(ui.Color(pixelBytes));
      image.setPixel(
        x,
        y,
        0xff000000 | (lum << 16) | (lum << 8) | lum,
      );
    }
  }
  return image;
}
