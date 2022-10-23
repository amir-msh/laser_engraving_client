import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laser_engraving_client/components/image_selection_dialog.dart';
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'package:laser_engraving_client/main.dart';
import 'package:laser_engraving_client/pages/engraving.dart';
import 'package:laser_engraving_client/riverpod/editable_image/editable_image_notifier.dart';
import 'package:laser_engraving_client/utils/constants.dart';

class ImageEngravingPage extends ConsumerStatefulWidget {
  const ImageEngravingPage({Key? key}) : super(key: key);

  @override
  ImageEngravingPageState createState() => ImageEngravingPageState();
}

class ImageEngravingPageState extends ConsumerState<ImageEngravingPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _imagePreviewBuilder(
    BuildContext context,
    AsyncSnapshot<Uint8List> snapshot,
  ) {
    if (snapshot.hasData &&
        snapshot.data != null &&
        snapshot.connectionState != ConnectionState.waiting) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Image.memory(
          snapshot.data!,
          key: UniqueKey(),
          fit: BoxFit.contain,
          width: double.infinity,
        ),
      );
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          snapshot.error!.toString(),
          style: const TextStyle(fontSize: 19),
        ),
      );
    } else if (snapshot.connectionState == ConnectionState.none) {
      return const Center(
        child: Material(
          color: Colors.transparent,
          child: Text(
            'Select an image',
            style: TextStyle(fontSize: 19),
          ),
        ),
      );
    } else {
      return const CircularProgressIndicator.adaptive();
    }
  }

  @override
  Widget build(BuildContext context) {
    //  final counter = ref.watch(counterProvider);
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
                  await Future.delayed(
                    const Duration(milliseconds: 750),
                  );
                  ref
                      .read(editableImageProvider.notifier)
                      .setImageFromFile(io.File(result!));
                }
              },
              child: FutureBuilder<Uint8List>(
                initialData: null,
                future: ref.watch(editableImageProvider).imagePreviewBytes,
                builder: (context, snapshot) => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 360),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: _imagePreviewBuilder(context, snapshot),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints.expand(),
              padding: const EdgeInsets.all(8),
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
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                      child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                        child: ElevatedButtonTheme(
                          data: ElevatedButtonThemeData(
                            style: Theme.of(context)
                                .elevatedButtonTheme
                                .style!
                                .copyWith(
                                  minimumSize: MaterialStatePropertyAll<Size>(
                                    const Size(200, 45),
                                  ),
                                ),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: ref
                                                .read(editableImageProvider)
                                                .imagePreview ==
                                            null
                                        ? null
                                        : () {
                                            ref
                                                .read(editableImageProvider
                                                    .notifier)
                                                .applyRidgeFilter();
                                          },
                                    child: const Text('Ridge Detection'),
                                  ),
                                  const SizedBox(height: 6),
                                  ElevatedButton(
                                    onPressed: ref
                                                .read(editableImageProvider)
                                                .imagePreview ==
                                            null
                                        ? null
                                        : () {
                                            ref
                                                .read(editableImageProvider
                                                    .notifier)
                                                .applyEdgeFilter();
                                          },
                                    child: const Text('Edge Detection'),
                                  ),
                                  const SizedBox(height: 6),
                                  ElevatedButton(
                                    onPressed: ref
                                                .read(editableImageProvider)
                                                .imagePreview ==
                                            null
                                        ? null
                                        : () {
                                            ref
                                                .read(editableImageProvider
                                                    .notifier)
                                                .applyReversionFilter();
                                          },
                                    child: const Text('Revert'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: SizedBox(
                      height: 55,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 17.5),
                        ),
                        onPressed: ref
                                    .read(editableImageProvider)
                                    .imagePreview ==
                                null
                            ? null
                            : () async {
                                final image = await reshapeToSquare(
                                  await fitImageToSize(
                                    await ref
                                        .read(editableImageProvider)
                                        .imagePreview!,
                                    Size.square(defaultImageWidth.toDouble()),
                                  ),
                                );
                                navKey.currentState!.push(
                                  MaterialPageRoute(
                                    builder: (context) => EngravingPage(
                                      image: image,
                                    ),
                                  ),
                                );
                              },
                        child: const Text('Engrave Image'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
