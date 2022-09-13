import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/main.dart';
import 'package:laser_engraving_client/pages/engraving.dart';

class PaintingEngravingPage extends StatefulWidget {
  const PaintingEngravingPage({Key? key}) : super(key: key);

  @override
  State<PaintingEngravingPage> createState() => _PaintingEngravingPageState();
}

class _PaintingEngravingPageState extends State<PaintingEngravingPage> {
  final offsets = <List<Offset>>[[]];
  final _canvasKey = GlobalKey();
  Uint8List? imagedCanvasBytes;

  Future<img.Image> _canvasToImage() async {
    final renderObject = _canvasKey.currentContext!.findRenderObject()!;

    final boundary = renderObject as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final byteData = await image.toByteData();

    return img.copyResize(
      img.Image.fromBytes(
        image.width,
        image.height,
        byteData!.buffer.asUint8List().toList(),
      ),
      width: 512,
    );
  }

  void onDrawing(Offset offset) {
    setState(() {
      if (offsets.isEmpty) {
        offsets.add([]);
      }
      offsets.last.add(offset);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painting Engraving'),
        actions: [
          IconButton(
            onPressed: () {
              if (offsets.isEmpty) return;
              while (true) {
                if (offsets.last.isEmpty) {
                  offsets.removeLast();
                } else {
                  break;
                }
              }
              offsets.removeLast();
              setState(() {});
            },
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            onPressed: () {
              offsets.clear();
              setState(() {});
            },
            icon: const Icon(Icons.cleaning_services),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 9 / 11,
            child: Container(
              constraints: const BoxConstraints.expand(),
              child: GestureDetector(
                onPanEnd: (details) {
                  offsets.add([]);
                },
                onPanStart: (details) => onDrawing(details.localPosition),
                onPanDown: (details) => onDrawing(details.localPosition),
                onPanUpdate: (details) => onDrawing(details.localPosition),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: ColoredBox(
                    color: Colors.white,
                    child: CustomPaint(
                      painter: DrawingPainter(
                        offsets: offsets,
                      ),
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
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      final image = await _canvasToImage();
                      navKey.currentState!.push(
                        MaterialPageRoute(
                          builder: (context) => EngravingPage(image: image),
                        ),
                      );
                    },
                    child: const Text('Start engraving'),
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

class DrawingPainter extends CustomPainter {
  final List<List<Offset>> offsets;
  const DrawingPainter({
    required this.offsets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var offsetPacket in offsets) {
      canvas.drawPoints(
        ui.PointMode.polygon,
        offsetPacket,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = false,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
