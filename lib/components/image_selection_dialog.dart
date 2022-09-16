import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laser_engraving_client/main.dart';

class ImageSelectionDialog extends StatelessWidget {
  const ImageSelectionDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 175,
      padding: const EdgeInsets.fromLTRB(10, 12.5, 10, 5),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Selecting image from :',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _ImagePickingOption(
                    title: 'Gallery',
                    icon: const Icon(Icons.image_outlined),
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowCompression: false,
                        type: FileType.image,
                        dialogTitle: 'Please choose an image',
                        allowMultiple: false,
                      );
                      if (result != null && result.files.single.path != null) {
                        navKey.currentState!.pop(result.files.single.path!);
                      } else {
                        navKey.currentState!.pop(null);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _ImagePickingOption(
                    title: 'Camera',
                    icon: const Icon(Icons.camera),
                    onTap: () async {
                      final image = await ImagePicker()
                          .pickImage(
                            source: ImageSource.camera,
                            imageQuality: 70,
                            preferredCameraDevice: CameraDevice.rear,
                            maxHeight: 1000,
                            maxWidth: 1000,
                          )
                          .onError((error, stackTrace) => null);

                      if (image != null && image.path.isNotEmpty) {
                        navKey.currentState!.pop(image.path);
                      } else {
                        navKey.currentState!.pop(null);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePickingOption extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback? onTap;
  const _ImagePickingOption({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          IconTheme(
            data: IconThemeData(
              color: Theme.of(context).colorScheme.secondary,
              size: 60,
            ),
            child: icon,
          ),
          const SizedBox(
            height: 5,
          ),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black,
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
