import 'dart:typed_data';

import 'package:image/image.dart' as img;

class EditableImageState {
  final Future<Uint8List>? imagePreviewBytes;
  final Future<img.Image>? imagePreview;
  final img.Image? imageSource;
  EditableImageState({
    this.imagePreviewBytes,
    this.imagePreview,
    this.imageSource,
  });
}
