import 'dart:async';
import 'dart:developer';
import 'package:dough/dough.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:laser_engraving_client/components/bluetooth_connection_state_viewer.dart';
import 'package:laser_engraving_client/components/labeled_duration.dart';
import 'package:laser_engraving_client/image_processing/functions.dart';
import 'package:laser_engraving_client/main.dart';
import 'package:laser_engraving_client/riverpod/bluetooth/bluetooth_notifier.dart';
import 'package:laser_engraving_client/riverpod/bluetooth/bluetooth_state.dart';
import 'package:rive/rive.dart';
import 'package:intl/intl.dart';
import 'package:wakelock/wakelock.dart';

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
  static const double imageBorderRadius = 17.5;
  static const double imageBorderWidth = 12.5;
  late final Timer _timer;
  final _timerNotifier = ValueNotifier<Duration>(Duration.zero);
  late final String _startTime;

  Future<Uint8List> generatePreviewBytes(img.Image image) async {
    return convertToViewableBytes(
      img.copyResize(
        img.Image.from(image),
        width: 512,
        interpolation: img.Interpolation.nearest,
      ),
    );
  }

  Widget stateViewerBuilder(BluetoothComState state) {
    if (state is BluetoothComDiscoveryState) {
      return CircularProgressIndicator.adaptive();
    } else if (state is BluetoothComErrorState) {
      return Icon(
        Icons.error,
        color: Theme.of(context).errorColor,
      );
    } else if (state is BluetoothComDiscoveryState) {
      return CircularProgressIndicator.adaptive();
    } else if (state is BluetoothComSendingDataState) {
      return Icon(
        Icons.send_to_mobile_sharp,
        color: Theme.of(context).errorColor,
      );
    } else {
      return CircularProgressIndicator.adaptive();
    }
  }

  Future<bool> _showAlertDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  const Text('Attention'),
                ],
              ),
              content: const Text(
                'Do you want to cancel the engraving?',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

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

    _imageLoadingFuture = Future.delayed(
      const Duration(milliseconds: 500),
      () => generatePreviewBytes(widget.image),
    );

    _startTime = DateFormat('HH:mm:ss').format(DateTime.now());
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        _timerNotifier.value =
            _timerNotifier.value + const Duration(seconds: 1);
      },
    );

    Wakelock.enable();

    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _timer.cancel();
    _timerNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(bluetoothComProvider.notifier);
    return WillPopScope(
      onWillPop: () async {
        final result = await _showAlertDialog();
        if (result) {
          await state.disconnect();
        }
        return result;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Engraving'),
          actions: const [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 15, 5),
              child: BluetoothConnectionStateViewer(),
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: GyroDough(
                child: RiveAnimation.asset(
                  'assets/rive/laser.riv',
                  artboard: 'engraving',
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Expanded(
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                child: Center(
                  child: PressableDough(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 230),
                      clipBehavior: Clip.none,
                      margin: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 50,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          imageBorderRadius + imageBorderWidth,
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: imageBorderWidth,
                          strokeAlign: StrokeAlign.outside,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor,
                            blurRadius: 7.5,
                            spreadRadius: imageBorderWidth,
                          ),
                        ],
                      ),
                      child: FutureBuilder<Uint8List>(
                        future: _imageLoadingFuture,
                        builder: (context, snapshot) {
                          late final Widget widget;
                          if (!snapshot.hasData) {
                            widget = const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            widget = Image.memory(
                              snapshot.data!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              isAntiAlias: false,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.error,
                                  color: Theme.of(context).errorColor,
                                );
                              },
                              frameBuilder: (
                                context,
                                child,
                                frame,
                                wasSynchronouslyLoaded,
                              ) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    imageBorderRadius,
                                  ),
                                  child: child,
                                );
                              },
                            );
                          }
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: widget,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 230),
              child: Column(
                children: [
                  LabeledDuration(
                    label: 'Start Time : ',
                    durationText: _startTime,
                  ),
                  const SizedBox(height: 6),
                  ValueListenableBuilder(
                    valueListenable: _timerNotifier,
                    builder: (context, value, child) {
                      return LabeledDuration(
                        label: 'Elapsed Time : ',
                        duration: _timerNotifier.value,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size(110, 46),
                    ),
                  ),
              onPressed: () async {
                final result = await _showAlertDialog();
                if (result) {
                  await state.disconnect();
                  navKey.currentState!.pop();
                }
              },
              child: Text('Stop'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
