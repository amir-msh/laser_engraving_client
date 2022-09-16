import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'package:laser_engraving_client/riverpod/bluetooth/bluetooth_notifier.dart';
import 'package:rive/rive.dart';

class EngravingPage extends ConsumerStatefulWidget {
  final img.Image image;
  const EngravingPage({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  ConsumerState<EngravingPage> createState() => _EngravingPageState();
}

class _EngravingPageState extends ConsumerState<EngravingPage> {
  late final Future<Uint8List> _imageLoadingFuture;

  @override
  void initState() {
    ref.read(bluetoothComProvider.notifier)
      ..initialize().then(
        (value) {
          return ref
              .read(bluetoothComProvider.notifier)
              .sendImage(widget.image);
        },
      )
      ..addListener(
        (state) {
          log(state.toString());
        },
      );

    _imageLoadingFuture = convertToViewableBytes(widget.image);

    super.initState();
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bluetoothComProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engraving the subject'),
      ),
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: RiveAnimation.asset(
                'assets/rive/laser.riv',
                artboard: 'engraving',
                fit: BoxFit.contain,
              ),
            ),
            Text(
              state.toString(),
            ),
            Expanded(
              child: Center(
                child: FutureBuilder<Uint8List>(
                  future: _imageLoadingFuture,
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 360),
                      child: (!snapshot.hasData)
                          ? const Center(child: CircularProgressIndicator())
                          : Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
