import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/components/drawing_painter.dart';
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'package:laser_engraving_client/main.dart';
import 'package:laser_engraving_client/pages/engraving.dart';

class PaintingEngravingPage extends StatefulWidget {
  const PaintingEngravingPage({Key? key}) : super(key: key);

  @override
  State<PaintingEngravingPage> createState() => _PaintingEngravingPageState();
}

class _PaintingEngravingPageState extends State<PaintingEngravingPage> {
  static const double minStrokeWidth = 20;
  static const double maxStrokeWidth = 40;
  static const double defaultStrokeWidth =
      minStrokeWidth + (maxStrokeWidth - minStrokeWidth) / 2;

  final _canvasKey = GlobalKey();
  final _paintingNotifier = PaintingNotifier();
  final _strokeWidthNotifier = ValueNotifier<double>(defaultStrokeWidth);

  Future<img.Image> _canvasToImage() async {
    final renderObject = _canvasKey.currentContext!.findRenderObject()!;

    final boundary = renderObject as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData();

    return img.invert(
      await reshapeToSquare(
        await fitImageToSize(
          img.copyResize(
            img.Image.fromBytes(
              image.width,
              image.height,
              byteData!.buffer.asUint8List().toList(),
            ),
            width: 512,
          ),
          const Size.square(64),
        ),
      ),
    );
  }

  void onDrawing(Offset offset) {
    _paintingNotifier.addPoint(
      offset,
      _strokeWidthNotifier.value,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _paintingNotifier.dispose();
    _strokeWidthNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painting Engraving'),
        actions: [
          IconButton(
            onPressed: _paintingNotifier.undo,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: _paintingNotifier.clear,
            icon: const Icon(Icons.cleaning_services),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              constraints: const BoxConstraints.expand(),
              child: GestureDetector(
                onPanStart: (details) => onDrawing(details.localPosition),
                onPanDown: (details) {
                  _paintingNotifier.addNewSession(
                    _strokeWidthNotifier.value,
                  );
                  onDrawing(details.localPosition);
                },
                onPanUpdate: (details) => onDrawing(details.localPosition),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: ValueListenableBuilder<PaintingData>(
                    valueListenable: _paintingNotifier,
                    builder: (context, data, child) {
                      return CustomPaint(
                        painter: DrawingPainter(
                          sessions: data.paintingSessions,
                          invert: data.invert,
                        ),
                      );
                    },
                  ),
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
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Pen Width :',
                                style: TextStyle(),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 15),
                              ValueListenableBuilder<double>(
                                valueListenable: _strokeWidthNotifier,
                                builder: (context, strokeWidth, child) =>
                                    SliderTheme(
                                  data: Theme.of(context).sliderTheme.copyWith(
                                        thumbShape: RoundSliderThumbShape(
                                          disabledThumbRadius: strokeWidth / 2,
                                          enabledThumbRadius: strokeWidth / 2,
                                        ),
                                        overlayShape:
                                            SliderComponentShape.noThumb,
                                        trackHeight: 7.5,
                                      ),
                                  child: Slider.adaptive(
                                    min: minStrokeWidth,
                                    max: maxStrokeWidth,
                                    value: strokeWidth,
                                    label:
                                        _strokeWidthNotifier.value.toString(),
                                    onChanged: (val) {
                                      _strokeWidthNotifier.value = val;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7.5),
                              const Divider(),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text(
                                    'Painting Mode :',
                                    style: TextStyle(),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    onPressed: () {
                                      _paintingNotifier.invert = false;
                                    },
                                    icon: Icon(Icons.brightness_1),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    onPressed: () {
                                      _paintingNotifier.invert = true;
                                    },
                                    icon: Icon(Icons.brightness_1_outlined),
                                  ),
                                ],
                              ),
                            ],
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
                          onPressed: () async {
                            final image = await _canvasToImage();
                            navKey.currentState!.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EngravingPage(image: image),
                              ),
                            );
                          },
                          child: const Text('Start engraving'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
