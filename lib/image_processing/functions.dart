import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'dart:io' as io;
import 'package:laser_engraving_client/image_processing/convolution_kernels.dart';

Future<img.Image> convertToEditableImage(ui.Image image) async {
  return img.Image.fromBytes(
    image.width,
    image.height,
    await image.toByteData().then(
          (value) => value!.buffer.asUint8List(),
        ),
    channels: img.Channels.rgb,
  );
}

Future<ui.Image> convertFileToUiImage(io.File file) async {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(
    file.readAsBytesSync(),
    (result) => completer.complete(result),
  );
  return completer.future;
}

Future<img.Image> convertFileToEditableImage(io.File file) async {
  if (file.uri.pathSegments.last.endsWith('.heic')) {
    return convertToEditableImage(await convertFileToUiImage(file));
  }
  return img.decodeImage(file.readAsBytesSync())!;
}

Future<Uint8List> convertToViewableBytes(img.Image image) async {
  return Uint8List.fromList(img.encodeBmp(image));
}

int setBitInByte(int byte, int bitIndex, bool value) {
  if (value) return byte | (1 << bitIndex);
  return byte & (~(1 << bitIndex));
}

bool isWhite(int color) => (color | 0xff000000) == 0xffffffff;
bool isBlack(int color) => (color | 0xff000000) == 0xff000000;

Future<Uint8List> imageToBlackAndWhiteBytes(img.Image image) async {
  final imgWidth = image.width;
  final imgPixels = imgWidth * imgWidth;
  final imageBytes = Uint8List(imgPixels ~/ 8);
  int bitIndex = 0;

  for (int y = 0; y < imgWidth; y++) {
    for (int x = 0; x < imgWidth; x++) {
      if (isBlack(image.getPixel(x, y))) {
        imageBytes[bitIndex ~/ 8] = setBitInByte(
          imageBytes[bitIndex ~/ 8],
          7 - (bitIndex % 8),
          true,
        );
      }
      bitIndex++;
    }
  }

  return imageBytes;
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

Future<img.Image> convertToRidgeDetected(
  img.Image image, [
  double luminanceThreshold = 0.1,
]) async {
  img.grayscale(image);
  img.contrast(image, 110);
  img.gaussianBlur(image, 1);
  img.convolution(image, ridgeDetection3Kernel);

  await maskUsingLuminance(image, luminanceThreshold);

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
  final int backgroundColor = 0xFFFFFFFF,
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
  final double luminanceThreshold = 0.07,
]) async {
  img.grayscale(image);
  img.vignette(image, start: 0.5, end: 0.9);
  img.contrast(image, 120);
  img.gaussianBlur(image, 1);
  img.sobel(image, amount: 1);
  await maskUsingLuminance(image, luminanceThreshold);

  return image;
}

Future<img.Image> convertToCustomEdgeDetected(img.Image image) async {
  const filter = [0, -1, 0, -1, 4, -1, 0, -1, 0];

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

// Engraving functions :

Future<img.Image> applyRidgeEngravingFilter(
  img.Image image, {
  final double power = 0.1,
}) async {
  return convertToRidgeDetected(
    image,
    power,
  );
}

Future<img.Image> applyEdgeEngravingFilter(
  img.Image image, {
  final double power = 0.07,
}) async {
  return convertToEdgeDetected(
    image,
    power,
  );
}

Future<img.Image> reshapeToSizedSquare(
  img.Image image,
  int imageWidth, {
  int backgroundColor = 0xffffffff,
}) async {
  image = await reshapeToSquare(
    image,
    backgroundColor: backgroundColor,
  );
  image = img.copyResize(
    image,
    width: imageWidth,
    height: imageWidth,
  );
  return image;
}
