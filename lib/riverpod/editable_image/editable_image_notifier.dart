import 'dart:developer';
import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'package:laser_engraving_client/riverpod/editable_image/editable_image_state.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/utils/constants.dart';

final editableImageProvider = StateNotifierProvider.autoDispose<
    EditableImageNotifier, EditableImageState>(
  (_) => EditableImageNotifier(),
);

class EditableImageNotifier extends StateNotifier<EditableImageState> {
  EditableImageNotifier() : super(EditableImageState());
  static const int difaultImageWidth = defaultImageWidth;

  Future<img.Image> _edgeFilter(
    img.Image image, [
    int imageWidth = difaultImageWidth,
  ]) async {
    return reshapeToSizedSquare(
      await applyEdgeEngravingFilter(
        img.Image.from(image),
      ),
      imageWidth,
    );
  }

  Future<img.Image> _ridgeFilter(
    img.Image image, [
    int imageWidth = difaultImageWidth,
  ]) async {
    return reshapeToSizedSquare(
      await applyRidgeEngravingFilter(
        img.Image.from(image),
      ),
      imageWidth,
    );
  }

  Future<void> setImageFromFile(io.File file) async {
    final imageSource = await convertFileToEditableImage(file).then(
      (image) => fitImageToSize(
        image,
        const ui.Size.square(512),
      ),
    );
    final editedImage = _edgeFilter(imageSource);
    final editedImageBytes = editedImage.then(
      (image) => Uint8List.fromList(img.encodePng(image)),
    );

    state = EditableImageState(
      imageSource: imageSource,
      imagePreview: editedImage,
      imagePreviewBytes: editedImageBytes,
    );
  }

  Future<void> applyReversionFilter() async {
    final editedImage = Future<img.Image>.sync(
      () async => img.invert(await state.imagePreview!),
    );

    final editedImageBytes = Future<Uint8List>.sync(
      () async => Uint8List.fromList(
        img.encodePng(await editedImage),
      ),
    );

    state = EditableImageState(
      imageSource: state.imageSource,
      imagePreview: editedImage,
      imagePreviewBytes: editedImageBytes,
    );
  }

  Future<void> applyEdgeFilter() async {
    final editedImage = _edgeFilter(state.imageSource!);
    final editedImageBytes = editedImage.then(
      (image) => Uint8List.fromList(img.encodePng(image)),
    );

    state = EditableImageState(
      imageSource: state.imageSource,
      imagePreview: editedImage,
      imagePreviewBytes: editedImageBytes,
    );
  }

  Future<void> applyRidgeFilter() async {
    final editedImage = _ridgeFilter(state.imageSource!);
    final editedImageBytes = editedImage.then(
      (image) => Uint8List.fromList(img.encodePng(image)),
    );

    state = EditableImageState(
      imageSource: state.imageSource,
      imagePreview: editedImage,
      imagePreviewBytes: editedImageBytes,
    );
  }

  // void increase() => state = state.copyWith(count: state.value + 1);
  // void decrease() => state = state.copyWith(count: state.value - 1);
}
